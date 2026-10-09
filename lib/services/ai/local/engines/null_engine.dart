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
  Stream<ExtractionEvent> extractFromAudio(AudioClip clip, ExtractionContext ctx) async* {
    // Basic mode: No audio processing
    yield* const Stream.empty();
  }

  @override
  Stream<ExtractionEvent> extractFromText(String text, ExtractionContext ctx) async* {
    // Bypasses extraction logic; actual text fallback goes through basic text extractor
    yield* const Stream.empty();
  }

  @override
  Stream<ExtractionEvent> extractFromImage(ImageInput img, ImageIntent intent, ExtractionContext ctx) async* {
    yield* const Stream.empty();
  }

  @override
  Future<String> narrate(NarrationRequest req) async {
    return 'Basic mode fallback narration.';
  }

  @override
  Stream<AskEvent> ask(AskRequest req, ToolExecutor tools) async* {
    yield* const Stream.empty();
  }
}
