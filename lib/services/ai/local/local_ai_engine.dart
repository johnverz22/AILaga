import 'dart:async';

enum AiTier { full, lite, basic }

abstract class AudioClip {}
abstract class ImageInput {}

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

abstract class ExtractionEvent {}

class NarrationRequest {
  final List<String> facts;
  final String audience;
  final String language;

  NarrationRequest({
    required this.facts,
    required this.audience,
    required this.language,
  });
}

abstract class AskEvent {}

class AskRequest {
  final String query;
  AskRequest({required this.query});
}

abstract class ToolExecutor {}

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
