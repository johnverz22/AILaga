import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma_litertlm/flutter_gemma_litertlm.dart';

import '../local_ai_engine.dart';
import '../proposals/proposal_models.dart';
import '../ask/ask_tools.dart';

/// One raw function call emitted by the model, before validation.
class RawToolCall {
  final String name;
  final Map<String, dynamic> args;
  const RawToolCall(this.name, this.args);
}

/// Maps a [RawToolCall] to a [ProposedRecord]. Unknown/malformed calls
/// return null — the caller drops them (never corrects, never invents).
ProposedRecord? mapToolCallToProposal(RawToolCall call) {
  final a = call.args;
  String? s(String k) => a[k] is String ? a[k] as String : null;
  num? n(String k) => a[k] is num ? a[k] as num : null;

  switch (call.name) {
    case 'propose_medication_taken':
      final med = s('medication_name');
      final quote = s('source_quote');
      if (med == null || quote == null) return null;
      return ProposedMedicationTaken(
          medicationName: med, timePhrase: s('time_phrase'), sourceQuote: quote);
    case 'propose_medication_skipped':
      final med = s('medication_name');
      final quote = s('source_quote');
      if (med == null || quote == null) return null;
      return ProposedMedicationSkipped(
          medicationName: med,
          reasonText: s('reason_text'),
          sourceQuote: quote);
    case 'propose_measurement':
      final type = s('type');
      final value1 = n('value1');
      final unit = s('unit');
      final quote = s('source_quote');
      if (type == null || value1 == null || unit == null || quote == null) {
        return null;
      }
      return ProposedMeasurement(
          type: type,
          value1: value1,
          value2: n('value2'),
          unit: unit,
          timePhrase: s('time_phrase'),
          sourceQuote: quote);
    case 'propose_care_note':
      final text = s('text');
      final quote = s('source_quote');
      if (text == null || quote == null) return null;
      return ProposedCareNote(
          text: text, timePhrase: s('time_phrase'), sourceQuote: quote);
    case 'propose_appointment':
      final when = s('datetime_phrase');
      final quote = s('source_quote');
      if (when == null || quote == null) return null;
      return ProposedAppointment(
          provider: s('provider'),
          purpose: s('purpose'),
          datetimePhrase: when,
          sourceQuote: quote);
    case 'propose_medication_schedule':
      final name = s('name');
      final quote = s('source_quote');
      if (name == null || quote == null) return null;
      return ProposedMedicationSchedule(
          name: name,
          strength: s('strength'),
          instructionText: s('instruction_text'),
          timesHhmm: (a['times_hhmm'] as List?)
              ?.map((e) => e.toString())
              .toList(),
          sourceQuote: quote);
    default:
      return null;
  }
}

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
  bool _initialized = false;
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
    if (!_initialized) {
      await FlutterGemma.initialize(inferenceEngines: [LiteRtLmEngine()]);
      _initialized = true;
    }
    if (!FlutterGemma.hasActiveModel()) {
      await FlutterGemma.installModel(
        modelType: ModelType.gemma4,
        fileType: ModelFileType.litertlm,
      ).fromFile(modelPath).install();
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
  Stream<ExtractionEvent> extractFromText(
      String text, ExtractionContext ctx) {
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
    yield ExtractionComplete(modelId: modelId, latencyMs: sw.elapsedMilliseconds);
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
          text: _extractionInstruction(ctx, intent: intent),
          audioBytes: bytes,
        ));
      } else if (image is FileImageInput) {
        final bytes = await File(image.path).readAsBytes();
        await session.addQueryChunk(Message.withImage(
          text: _extractionInstruction(ctx, intent: intent),
          imageBytes: bytes,
        ));
      } else {
        await session.addQueryChunk(Message.text(
          text:
              '${_extractionInstruction(ctx, intent: intent)}\n\nHeard text: "${text ?? ''}"',
          isUser: true,
        ));
      }
      final out = await session.getResponse();
      return _InferenceOut(
        transcript: _readJsonString(out, 'transcript'),
        calls: _parseToolCalls(out),
      );
    } finally {
      await session.close();
      _touch();
    }
  }

  /// §6.3 tool schema, rendered into the prompt. Output contract: a JSON
  /// object {"transcript": "...", "calls": [{"name": ..., "parameters": {...}}]}.
  String _extractionInstruction(ExtractionContext ctx,
      {ImageIntent? intent}) {
    final meds = ctx.activeMeds.join(', ');
    final target = switch (intent) {
      ImageIntent.reseta => 'a photo of a handwritten prescription',
      ImageIntent.label => 'a photo of a pill bottle label',
      ImageIntent.monitor => 'a photo of a BP/glucose monitor screen',
      null => 'the caregiver\'s spoken sentence',
    };
    return '''
You convert $target into structured record proposals for a caregiving app.

Rules:
- Copy numbers EXACTLY as written/said. Never invent or correct values.
- Include source_quote: a verbatim substring of the heard text (or "" for images).
- If nothing recordable is present, return an empty calls array.
- Known medications: [${meds.isEmpty ? 'none' : meds}]
- Now: ${ctx.now.toIso8601String()} (${ctx.timezone})

Output ONLY this JSON object, no prose:
{"transcript":"<heard or read text>","calls":[{"name":"<tool>","parameters":{...}}]}

Tools:
- propose_medication_taken {medication_name, time_phrase|null, source_quote}
- propose_medication_skipped {medication_name, reason_text|null, source_quote}
- propose_measurement {type: blood_pressure|pulse|temperature|weight|blood_glucose, value1, value2|null, unit, time_phrase|null, source_quote}
- propose_care_note {text, time_phrase|null, source_quote}
- propose_appointment {provider|null, purpose|null, datetime_phrase, source_quote}
- propose_medication_schedule {name, strength|null, instruction_text|null, times_hhmm|null, source_quote}
''';
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

    var conversation = _askPrompt(req.query, tools.toolNames);
    try {
      for (var round = 0; round < maxRounds; round++) {
        final out = await _serialized(() async {
          final session = await _model!.createSession(
            temperature: 0.2,
            topK: 1,
            maxOutputTokens: 384,
          );
          try {
            await session.addQueryChunk(
                Message.text(text: conversation, isUser: true));
            return await session.getResponse();
          } finally {
            await session.close();
            _touch();
          }
        });

        final toolName = _readJsonString(out, 'tool');
        if (toolName == null || !tools.toolNames.contains(toolName)) {
          // Not a tool call → treat as the final answer.
          final answer = _readJsonString(out, 'answer') ?? out.trim();
          yield AskAnswer(answer,
              sourceIds: _readJsonStringList(out, 'source_ids'));
          return;
        }
        final args = _readJsonMap(out, 'args');
        final result = await tools.call(toolName, args);
        conversation =
            '$conversation\n\nTool $toolName returned:\n${jsonEncode(result)}\nNow answer the question, or call another tool.';
      }
      yield AskFailed('max_tool_rounds');
    } catch (e) {
      yield AskFailed(e.toString());
    }
  }

  String _askPrompt(String query, List<String> toolNames) => '''
You answer questions about an elder's care records using read-only tools.
Tools: ${jsonEncode(AskTools.toolDescriptors)}

To call a tool output ONLY: {"tool":"<name>","args":{...}}
To answer output ONLY: {"answer":"<short plain answer>","source_ids":["<record ids used>"]}
Question: "$query"
''';

  // -------------------------------------------------------------------------
  // Output parsing (shared, also unit-tested)
  // -------------------------------------------------------------------------

  /// Extracts the calls array from model output; tolerates prose around the
  /// JSON object.
  static List<RawToolCall> parseToolCalls(String output) =>
      _parseToolCalls(output);

  static List<RawToolCall> _parseToolCalls(String output) {
    final obj = _decodeJsonObject(output);
    if (obj == null) return const [];
    final calls = obj['calls'];
    if (calls is! List) return const [];
    return calls
        .whereType<Map>()
        .map((c) => RawToolCall(
              c['name']?.toString() ?? '',
              (c['parameters'] as Map?)?.cast<String, dynamic>() ?? const {},
            ))
        .where((c) => c.name.isNotEmpty)
        .toList();
  }

  static Map<String, dynamic>? _decodeJsonObject(String output) {
    final start = output.indexOf('{');
    final end = output.lastIndexOf('}');
    if (start < 0 || end <= start) return null;
    try {
      final decoded = jsonDecode(output.substring(start, end + 1));
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  static String? _readJsonString(String output, String key) {
    final obj = _decodeJsonObject(output);
    final v = obj?[key];
    return v is String && v.isNotEmpty ? v : null;
  }

  static List<String> _readJsonStringList(String output, String key) {
    final obj = _decodeJsonObject(output);
    final v = obj?[key];
    return v is List ? v.map((e) => e.toString()).toList() : const [];
  }

  static Map<String, Object?> _readJsonMap(String output, String key) {
    final obj = _decodeJsonObject(output);
    final v = obj?[key];
    return v is Map ? v.cast<String, Object?>() : const {};
  }
}

class _InferenceOut {
  final String? transcript;
  final List<RawToolCall> calls;
  const _InferenceOut({this.transcript, required this.calls});
}
