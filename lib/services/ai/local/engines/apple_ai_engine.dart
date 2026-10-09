import 'dart:async';
import 'dart:convert';

import '../local_ai_engine.dart';
import '../proposals/proposal_models.dart';
import '../ask/ask_tools.dart';
import '../platform/apple_channels.dart';
import 'model_output.dart';

typedef AppleRespondFn = Future<String> Function(String prompt,
    {double? temperature});
typedef AppleTranscribeFn = Future<String?> Function(String path);
typedef AppleOcrFn = Future<String?> Function(String path);
typedef AppleAvailabilityFn = Future<Map<String, Object?>> Function();

/// iOS engine: Apple Intelligence (FoundationModels, iOS 26+) for inference,
/// Apple Speech for on-device ASR, Apple Vision for on-device OCR.
///
/// Same contract as [GemmaLiteRtEngine] (spec §6.2): failures degrade the
/// session to Basic, model output is parsed into proposals — validation and
/// persistence stay outside. All channels are injectable for tests.
///
/// Nothing is kept resident: FoundationModels sessions are per-call and the
/// OS manages the model, so [unloadIfIdle] is a no-op by design.
class AppleAiEngine implements LocalAiEngine {
  final AiTier deviceTier;

  final AppleRespondFn _respond;
  final AppleTranscribeFn _transcribe;
  final AppleOcrFn _ocr;
  final AppleAvailabilityFn _availability;

  bool _degraded = false;
  Future<void> _inflight = Future.value();

  AppleAiEngine({
    this.deviceTier = AiTier.lite,
    AppleRespondFn? respond,
    AppleTranscribeFn? transcribe,
    AppleOcrFn? ocr,
    AppleAvailabilityFn? availability,
  })  : _respond = respond ?? AppleAiChannel.respond,
        _transcribe = transcribe ?? AppleSpeechChannel.transcribe,
        _ocr = ocr ?? AppleVisionChannel.recognizeText,
        _availability = availability ?? AppleAiChannel.availability;

  @override
  String get engineId => 'apple_foundationmodels';

  @override
  Future<AiTier> tier() async => _degraded ? AiTier.basic : deviceTier;

  @override
  Future<void> ensureLoaded() async {
    final avail = await _availability();
    if (avail['available'] != true) {
      throw AiUnavailable('apple_ai unavailable: ${avail['reason']}');
    }
  }

  /// FoundationModels is OS-managed — nothing to unload. Kept for the
  /// engine contract; the lifecycle heartbeat just calls through harmlessly.
  @override
  Future<void> unloadIfIdle(Duration idle) async {}

  Future<T> _serialized<T>(Future<T> Function() fn) {
    final prev = _inflight;
    final completer = Completer<void>();
    _inflight = completer.future;
    return prev.then((_) => fn()).whenComplete(completer.complete);
  }

  void _degrade() => _degraded = true;

  // -------------------------------------------------------------------------
  // Extraction
  // -------------------------------------------------------------------------

  /// Audio → on-device ASR transcript → text extraction.
  @override
  Stream<ExtractionEvent> extractFromAudio(
      AudioClip clip, ExtractionContext ctx) async* {
    String? path;
    if (clip is WavAudioClip) path = clip.path;
    if (path == null) {
      yield ExtractionFailed('unsupported_audio: ${clip.runtimeType}');
      return;
    }
    final transcript = await _transcribe(path);
    if (transcript == null || transcript.trim().isEmpty) {
      yield ExtractionFailed('asr_unavailable_or_empty');
      return;
    }
    yield TranscriptUpdated(transcript);
    yield* _extractText(transcript, ctx);
  }

  /// Image → on-device OCR → text extraction.
  @override
  Stream<ExtractionEvent> extractFromImage(
      ImageInput img, ImageIntent intent, ExtractionContext ctx) async* {
    String? path;
    if (img is FileImageInput) path = img.path;
    if (path == null) {
      yield ExtractionFailed('unsupported_image: ${img.runtimeType}');
      return;
    }
    final text = await _ocr(path);
    if (text == null || text.trim().isEmpty) {
      yield ExtractionFailed('ocr_unavailable_or_empty');
      return;
    }
    yield TranscriptUpdated(text);
    yield* _extractText(text, ctx, intent: intent);
  }

  @override
  Stream<ExtractionEvent> extractFromText(
      String text, ExtractionContext ctx) =>
      _extractText(text, ctx);

  Stream<ExtractionEvent> _extractText(String input, ExtractionContext ctx,
      {ImageIntent? intent}) async* {
    final sw = Stopwatch()..start();
    try {
      await _serialized(ensureLoaded);
    } catch (e) {
      _degrade();
      yield ExtractionFailed('engine_unavailable: $e');
      return;
    }

    const maxAttempts = 3; // initial + 2 retries per spec
    List<ProposedRecord> records = const [];
    String? transcript;

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final prompt =
            '${extractionInstruction(ctx, intent: intent)}\n\nHeard text: "$input"';
        final out =
            await _serialized(() => _respond(prompt, temperature: 0.1));
        transcript = readJsonString(out, 'transcript') ?? input;
        records = parseToolCalls(out)
            .map(mapToolCallToProposal)
            .whereType<ProposedRecord>()
            .toList();
        break;
      } catch (e) {
        if (attempt == maxAttempts - 1) {
          _degrade();
          yield ExtractionFailed('inference_failed: $e');
          return;
        }
      }
    }

    yield TranscriptUpdated(transcript ?? input);
    for (final r in records) {
      yield ProposalEmitted(r);
    }
    yield ExtractionComplete(
        modelId: engineId, latencyMs: sw.elapsedMilliseconds);
  }

  // -------------------------------------------------------------------------
  // Narration (§6.4) — verified downstream by NarrationVerifier.
  // -------------------------------------------------------------------------

  @override
  Future<String> narrate(NarrationRequest req) {
    return _serialized(() async {
      try {
        await ensureLoaded();
        final prompt = req.prompt ??
            'Summarize these care facts for ${req.audience} in ${req.language}.\n'
                '${req.facts.join('\n')}';
        return await _respond(prompt, temperature: 0.4);
      } catch (e) {
        _degrade();
        throw AiUnavailable('narrate failed: $e');
      }
    });
  }

  // -------------------------------------------------------------------------
  // Ask (§6.5) — ≤3 tool rounds, same JSON contract as the Gemma path.
  // -------------------------------------------------------------------------

  @override
  Stream<AskEvent> ask(AskRequest req, ToolExecutor tools) async* {
    const maxRounds = 3;
    try {
      await _serialized(ensureLoaded);
    } catch (e) {
      _degrade();
      yield AskFailed('engine_unavailable: $e');
      return;
    }

    var conversation =
        askPrompt(req.query, jsonEncode(AskTools.toolDescriptors));
    try {
      for (var round = 0; round < maxRounds; round++) {
        final out = await _serialized(
            () => _respond(conversation, temperature: 0.2));

        final toolName = readJsonString(out, 'tool');
        if (toolName == null || !tools.toolNames.contains(toolName)) {
          final answer = readJsonString(out, 'answer') ?? out.trim();
          yield AskAnswer(answer,
              sourceIds: readJsonStringList(out, 'source_ids'));
          return;
        }
        final args = readJsonMap(out, 'args');
        final result = await tools.call(toolName, args);
        conversation =
            '$conversation\n\nTool $toolName returned:\n${jsonEncode(result)}\nNow answer the question, or call another tool.';
      }
      yield AskFailed('max_tool_rounds');
    } catch (e) {
      yield AskFailed(e.toString());
    }
  }
}
