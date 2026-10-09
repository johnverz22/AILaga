import 'dart:async';
import '../local_ai_engine.dart';

class NullEngine implements LocalAiEngine {
  @override
  String get engineId => 'null_engine';

  @override
  Future<AiTier> tier() async => AiTier.basic;

  @override
  Future<void> ensureLoaded() async {}

  @override
  Future<void> unloadIfIdle(Duration idle) async {}

  @override
  Stream<ExtractionEvent> extractFromAudio(AudioClip clip, ExtractionContext ctx) {
    return Stream.error(const AiUnavailable('No on-device model installed'));
  }

  @override
  Stream<ExtractionEvent> extractFromText(String text, ExtractionContext ctx) {
    // Text fallback is handled by BasicTextExtractor, not the engine.
    return Stream.error(const AiUnavailable('No on-device model installed'));
  }

  @override
  Stream<ExtractionEvent> extractFromImage(ImageInput img, ImageIntent intent, ExtractionContext ctx) {
    return Stream.error(const AiUnavailable('No on-device model installed'));
  }

  @override
  Future<String> narrate(NarrationRequest req) {
    return Future.error(const AiUnavailable('No on-device model installed'));
  }

  @override
  Stream<AskEvent> ask(AskRequest req, ToolExecutor tools) {
    return Stream.error(const AiUnavailable('No on-device model installed'));
  }
}
