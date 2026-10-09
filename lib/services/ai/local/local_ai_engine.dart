import 'dart:async';

import 'proposals/proposal_models.dart';

enum AiTier { full, lite, basic }

/// Thrown when an AI capability is requested but no usable model/engine
/// is available. Callers should fall back to deterministic Basic mode.
class AiUnavailable implements Exception {
  final String message;
  const AiUnavailable([this.message = 'Local AI is not available']);
  @override
  String toString() => 'AiUnavailable: $message';
}

// ---------------------------------------------------------------------------
// Inputs
// ---------------------------------------------------------------------------

abstract class AudioClip {}

/// 16 kHz mono WAV recording captured by VoiceCaptureService.
class WavAudioClip extends AudioClip {
  final String path;
  final Duration duration;
  WavAudioClip({required this.path, required this.duration});
}

abstract class ImageInput {}

/// A photo from camera or gallery, for Snap capture.
class FileImageInput extends ImageInput {
  final String path;
  FileImageInput({required this.path});
}

enum ImageIntent { reseta, label, monitor }

class ExtractionContext {
  final List<String> activeMeds;
  final DateTime now;
  final String timezone;

  ExtractionContext({
    required this.activeMeds,
    required this.now,
    required this.timezone,
  });
}

// ---------------------------------------------------------------------------
// Extraction events (Stream<ExtractionEvent>)
// ---------------------------------------------------------------------------

abstract class ExtractionEvent {}

/// Streaming transcript chunk while the model is listening/reading.
class TranscriptUpdated extends ExtractionEvent {
  final String text;
  TranscriptUpdated(this.text);
}

/// One validated-candidate record proposal. Still staged — nothing is
/// written to real tables until the user confirms in the Review tray.
class ProposalEmitted extends ExtractionEvent {
  final ProposedRecord record;
  ProposalEmitted(this.record);
}

/// Extraction finished; [modelId] + [latencyMs] go on the AiCapture row.
class ExtractionComplete extends ExtractionEvent {
  final String modelId;
  final int latencyMs;
  ExtractionComplete({required this.modelId, required this.latencyMs});
}

/// Extraction failed. UI should surface the typed-text fallback path.
class ExtractionFailed extends ExtractionEvent {
  final String reason;
  ExtractionFailed(this.reason);
}

// ---------------------------------------------------------------------------
// Narration (§6.4)
// ---------------------------------------------------------------------------

class NarrationRequest {
  final List<String> facts;
  final String audience;
  final String language;

  /// Fully-rendered prompt per spec §6.4 (built by the Narrator).
  /// Real engines send this verbatim; test engines may ignore it.
  final String? prompt;

  NarrationRequest({
    required this.facts,
    required this.audience,
    required this.language,
    this.prompt,
  });
}

// ---------------------------------------------------------------------------
// Ask the record (§6.5)
// ---------------------------------------------------------------------------

abstract class AskEvent {}

/// Streamed answer token/chunk.
class AskToken extends AskEvent {
  final String text;
  AskToken(this.text);
}

/// Final answer with the record IDs it was grounded on (shown as source chips).
class AskAnswer extends AskEvent {
  final String text;
  final List<String> sourceIds;
  AskAnswer(this.text, {this.sourceIds = const []});
}

/// Fixed refusal for advice/diagnosis questions ("Ask the doctor").
class AskRefused extends AskEvent {
  final String reason;
  AskRefused([this.reason = 'advice']);
}

class AskFailed extends AskEvent {
  final String reason;
  AskFailed(this.reason);
}

class AskRequest {
  final String query;
  AskRequest({required this.query});
}

/// Executes read-only repository lookups on behalf of the model.
/// Implemented by AskTools (lib/services/ai/local/ask/ask_tools.dart).
abstract class ToolExecutor {
  /// Names of the tools this executor exposes to the model.
  List<String> get toolNames;

  /// Runs [name] with decoded JSON [args]; returns a JSON-encodable result.
  /// Must never mutate data — read-only contract.
  Future<Object?> call(String name, Map<String, Object?> args);
}

// ---------------------------------------------------------------------------
// Engine
// ---------------------------------------------------------------------------

abstract interface class LocalAiEngine {
  String get engineId;
  Future<AiTier> tier();
  Future<void> ensureLoaded();
  Future<void> unloadIfIdle(Duration idle);

  Stream<ExtractionEvent> extractFromAudio(AudioClip clip, ExtractionContext ctx);
  Stream<ExtractionEvent> extractFromText(String text, ExtractionContext ctx);
  Stream<ExtractionEvent> extractFromImage(ImageInput img, ImageIntent intent, ExtractionContext ctx);
  Future<String> narrate(NarrationRequest req);
  Stream<AskEvent> ask(AskRequest req, ToolExecutor tools);
}
