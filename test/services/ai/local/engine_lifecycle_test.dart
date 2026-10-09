import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ailaga/services/ai/local/engine_lifecycle.dart';
import 'package:ailaga/services/ai/local/local_ai_engine.dart';

/// Counts unloadIfIdle calls and records the idle durations requested.
class _CountingEngine extends ScriptedEngineStub {
  final List<Duration> unloadCalls = [];

  @override
  Future<void> unloadIfIdle(Duration idle) async {
    unloadCalls.add(idle);
  }
}

/// Minimal stub so the test doesn't depend on ScriptedEngine internals.
class ScriptedEngineStub implements LocalAiEngine {
  @override
  String get engineId => 'stub';
  @override
  Future<AiTier> tier() async => AiTier.full;
  @override
  Future<void> ensureLoaded() async {}
  @override
  Future<void> unloadIfIdle(Duration idle) async {}
  @override
  Stream<ExtractionEvent> extractFromAudio(
          AudioClip clip, ExtractionContext ctx) =>
      const Stream.empty();
  @override
  Stream<ExtractionEvent> extractFromText(
          String text, ExtractionContext ctx) =>
      const Stream.empty();
  @override
  Stream<ExtractionEvent> extractFromImage(
          ImageInput img, ImageIntent intent, ExtractionContext ctx) =>
      const Stream.empty();
  @override
  Future<String> narrate(NarrationRequest req) async => '';
  @override
  Stream<AskEvent> ask(AskRequest req, ToolExecutor tools) =>
      const Stream.empty();
}

void main() {
  group('EngineIdleUnloader', () {
    test('tick calls unloadIfIdle with the configured idle window', () {
      fakeAsync((async) {
        final engine = _CountingEngine();
        final unloader = EngineIdleUnloader(engine,
            idle: const Duration(seconds: 60),
            tick: const Duration(seconds: 15));
        unloader.start();

        async.elapse(const Duration(seconds: 15));
        expect(engine.unloadCalls, [const Duration(seconds: 60)]);

        async.elapse(const Duration(seconds: 30));
        expect(engine.unloadCalls.length, 3);
        unloader.stop();
      });
    });

    test('stop cancels the heartbeat', () {
      fakeAsync((async) {
        final engine = _CountingEngine();
        final unloader = EngineIdleUnloader(engine,
            tick: const Duration(seconds: 15));
        unloader.start();
        unloader.stop();

        async.elapse(const Duration(minutes: 5));
        expect(engine.unloadCalls, isEmpty);
      });
    });

    test('start is idempotent — one timer only', () {
      fakeAsync((async) {
        final engine = _CountingEngine();
        final unloader = EngineIdleUnloader(engine,
            tick: const Duration(seconds: 15));
        unloader.start();
        unloader.start();

        async.elapse(const Duration(seconds: 15));
        expect(engine.unloadCalls.length, 1);
        unloader.stop();
      });
    });

    test('unloadNow unloads immediately (zero idle)', () {
      fakeAsync((async) {
        final engine = _CountingEngine();
        final unloader = EngineIdleUnloader(engine);
        unloader.unloadNow();
        async.flushMicrotasks();
        expect(engine.unloadCalls, [Duration.zero]);
      });
    });

    test('engine unload errors are swallowed, heartbeat continues', () {
      fakeAsync((async) {
        final engine = _ThrowingEngine();
        final unloader = EngineIdleUnloader(engine,
            idle: const Duration(seconds: 60),
            tick: const Duration(seconds: 15));
        unloader.start();
        async.elapse(const Duration(seconds: 30));
        async.flushMicrotasks();
        expect(engine.calls, 2);
        unloader.stop();
      });
    });
  });
}

class _ThrowingEngine extends ScriptedEngineStub {
  int calls = 0;
  @override
  Future<void> unloadIfIdle(Duration idle) async {
    calls++;
    throw StateError('unload failed');
  }
}
