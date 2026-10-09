import 'dart:async';
import '../local_ai_engine.dart';

class ScriptedEngine implements LocalAiEngine {
  final List<ExtractionEvent> extractEvents;
  final String narrationResult;

  ScriptedEngine({
    this.extractEvents = const [],
    this.narrationResult = 'Scripted narration.',
  });

  @override
  String get engineId => 'scripted_engine';

  @override
  Future<AiTier> tier() async => AiTier.full;

  @override
  Future<void> ensureLoaded() async {}

  @override
  Future<void> unloadIfIdle(Duration idle) async {}

  @override
  Stream<ExtractionEvent> extractFromAudio(AudioClip clip, ExtractionContext ctx) async* {
    for (final e in extractEvents) {
      yield e;
    }
  }

  @override
  Stream<ExtractionEvent> extractFromText(String text, ExtractionContext ctx) async* {
    for (final e in extractEvents) {
      yield e;
    }
  }

  @override
  Stream<ExtractionEvent> extractFromImage(ImageInput img, ImageIntent intent, ExtractionContext ctx) async* {
    for (final e in extractEvents) {
      yield e;
    }
  }

  @override
  Future<String> narrate(NarrationRequest req) async {
    return narrationResult;
  }

  @override
  Stream<AskEvent> ask(AskRequest req, ToolExecutor tools) async* {
    yield* const Stream.empty();
  }
}
