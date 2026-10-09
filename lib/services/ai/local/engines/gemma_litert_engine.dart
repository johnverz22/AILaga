import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_gemma/flutter_gemma.dart';

import '../local_ai_engine.dart';
import '../proposals/proposal_models.dart';
import '../ask/ask_tools.dart';
import 'model_output.dart';

/// Gemma via LiteRT-LM (flutter_gemma + flutter_gemma_litertlm).
///
/// Contract (spec §6.2): lazy load, 60 s idle unload, one inference at a
/// time, OOM/failure → degrade the session to Basic (never crash the app).
/// All model output is parsed into proposals — validation and persistence
/// stay outside this class.
class GemmaLiteRtEngine implements LocalAiEngine {
  /// Path of the installed model file (from ModelManager).
  final String modelPath;
  final String modelId;
  final AiTier deviceTier;

  InferenceModel? _model;
  DateTime _lastUsed = DateTime.fromMillisecondsSinceEpoch(0);
  bool _degraded = false;
  bool _modelInstalled = false;
  Future<void> _inflight = Future.value();

  GemmaLiteRtEngine({
    required this.modelPath,
    this.modelId = 'gemma4-e2b',
    this.deviceTier = AiTier.full,
  });

  @override
  String get engineId => 'gemma_litert';

  @override
  Future<AiTier> tier() async => _degraded ? AiTier.basic : deviceTier;

  @override
  Future<void> ensureLoaded() async {
    if (_model != null) return;
    if (!_modelInstalled && !FlutterGemma.hasActiveModel()) {
      await FlutterGemma.installModel(
        modelType: ModelType.gemma4,
        fileType: ModelFileType.litertlm,
      ).fromFile(modelPath).install();
      _modelInstalled = true;
    } else {
      _modelInstalled = true; // model was already registered
    }
    _model = await FlutterGemma.getActiveModel(
      maxTokens: 2048,
      supportImage: true,
      supportAudio: true,
    );
    _touch();
  }

  @override
  Future<void> unloadIfIdle(Duration idle) async {
    if (_model == null) return;
    if (DateTime.now().difference(_lastUsed) < idle) return;
    final m = _model;
    _model = null;
    await m?.close();
  }

  /// Serializes inference: one session at a time (the LiteRT runtime also
  /// serializes natively, but we keep the contract explicit).
  Future<T> _serialized<T>(Future<T> Function() fn) {
    final prev = _inflight;
    final completer = Completer<void>();
    _inflight = completer.future;
    return prev.then((_) => fn()).whenComplete(completer.complete);
  }

  void _touch() => _lastUsed = DateTime.now();

  void _degrade() => _degraded = true;

  // -------------------------------------------------------------------------
  // Extraction
  // -------------------------------------------------------------------------

  @override
  Stream<ExtractionEvent> extractFromAudio(
      AudioClip clip, ExtractionContext ctx) {
    return _extract(clip: clip, ctx: ctx);
  }

  @override
  Stream<ExtractionEvent> extractFromText(String text, ExtractionContext ctx) {
    return _extract(text: text, ctx: ctx);
  }

  @override
  Stream<ExtractionEvent> extractFromImage(
      ImageInput img, ImageIntent intent, ExtractionContext ctx) {
    return _extract(image: img, intent: intent, ctx: ctx);
  }

  Stream<ExtractionEvent> _extract({
    String? text,
    AudioClip? clip,
    ImageInput? image,
    ImageIntent? intent,
    required ExtractionContext ctx,
  }) async* {
    final sw = Stopwatch()..start();
    try {
      await _serialized(() async {
        await ensureLoaded();
      });
    } catch (e) {
      _degrade();
      yield ExtractionFailed('engine_unavailable: $e');
      return;
    }

    List<ProposedRecord> records = const [];
    String? transcript;
    const maxAttempts = 3; // initial + 2 retries per spec

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final raw = await _serialized(() => _runExtractionInference(
            text: text, clip: clip, image: image, intent: intent, ctx: ctx));
        transcript = raw.transcript ?? transcript;
        if (transcript != null) {
          yield TranscriptUpdated(transcript);
        }
        records = raw.calls
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

    for (final r in records) {
      yield ProposalEmitted(r);
    }
    yield ExtractionComplete(
        modelId: modelId, latencyMs: sw.elapsedMilliseconds);
    _touch();
  }

  /// Runs one inference pass; returns transcript + parsed raw tool calls.
  Future<_InferenceOut> _runExtractionInference({
    String? text,
    AudioClip? clip,
    ImageInput? image,
    ImageIntent? intent,
    required ExtractionContext ctx,
  }) async {
    final model = _model;
    if (model == null) throw const AiUnavailable('model not loaded');

    final session = await model.createSession(
      temperature: 0.1,
      topK: 1,
      maxOutputTokens: 512,
      enableVisionModality: image != null ? true : null,
      enableAudioModality: clip != null ? true : null,
    );
    try {
      if (clip is WavAudioClip) {
        final bytes = await File(clip.path).readAsBytes();
        await session.addQueryChunk(Message.withAudio(
          text: extractionInstruction(ctx, intent: intent),
          audioBytes: bytes,
        ));
      } else if (image is FileImageInput) {
        final bytes = await File(image.path).readAsBytes();
        await session.addQueryChunk(Message.withImage(
          text: extractionInstruction(ctx, intent: intent),
          imageBytes: bytes,
        ));
      } else {
        await session.addQueryChunk(Message.text(
          text:
              '${extractionInstruction(ctx, intent: intent)}\n\nHeard text: "${text ?? ''}"',
          isUser: true,
        ));
      }
      final out = await session.getResponse();
      return _InferenceOut(
        transcript: readJsonString(out, 'transcript'),
        calls: parseToolCalls(out),
      );
    } finally {
      await session.close();
      _touch();
    }
  }

  // -------------------------------------------------------------------------
  // Narration (§6.4)
  // -------------------------------------------------------------------------

  @override
  Future<String> narrate(NarrationRequest req) {
    return _serialized(() async {
      try {
        await ensureLoaded();
        final model = _model!;
        final session = await model.createSession(
          temperature: 0.4,
          topK: 1,
          maxOutputTokens: 256,
        );
        try {
          final prompt = req.prompt ??
              'Summarize these care facts for ${req.audience} in ${req.language}.\n'
                  '${req.facts.join('\n')}';
          await session.addQueryChunk(Message.text(text: prompt, isUser: true));
          _touch();
          return await session.getResponse();
        } finally {
          await session.close();
        }
      } catch (e) {
        _degrade();
        throw AiUnavailable('narrate failed: $e');
      }
    });
  }

  // -------------------------------------------------------------------------
  // Ask (§6.5) — ≤3 tool rounds
  // -------------------------------------------------------------------------

  @override
  Stream<AskEvent> ask(AskRequest req, ToolExecutor tools) async* {
    const maxRounds = 3;
    try {
      await _serialized(() => ensureLoaded());
    } catch (e) {
      _degrade();
      yield AskFailed('engine_unavailable: $e');
      return;
    }

    var conversation =
        askPrompt(req.query, jsonEncode(AskTools.toolDescriptors));
    try {
      for (var round = 0; round < maxRounds; round++) {
        final out = await _serialized(() async {
          final session = await _model!.createSession(
            temperature: 0.2,
            topK: 1,
            maxOutputTokens: 384,
          );
          try {
            await session
                .addQueryChunk(Message.text(text: conversation, isUser: true));
            return await session.getResponse();
          } finally {
            await session.close();
            _touch();
          }
        });

        final toolName = readJsonString(out, 'tool');
        if (toolName == null || !tools.toolNames.contains(toolName)) {
          // Not a tool call → treat as the final answer.
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

class _InferenceOut {
  final String? transcript;
  final List<RawToolCall> calls;
  const _InferenceOut({this.transcript, required this.calls});
}
