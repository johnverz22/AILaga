import 'package:flutter_test/flutter_test.dart';
import 'package:ailaga/services/ai/local/ask/ask_agent.dart';
import 'package:ailaga/services/ai/local/engines/null_engine.dart';
import 'package:ailaga/services/ai/local/engines/scripted_engine.dart';
import 'package:ailaga/services/ai/local/local_ai_engine.dart';

/// In-memory read-only tool executor; returns canned rows per tool name.
class _StubTools implements ToolExecutor {
  final Map<String, Object?> canned;
  _StubTools(this.canned);

  @override
  List<String> get toolNames => canned.keys.toList();

  @override
  Future<Object?> call(String name, Map<String, Object?> args) async =>
      canned[name] ?? <Map<String, Object?>>[];
}

class _AskEngine extends ScriptedEngine {
  final List<AskEvent> events;
  _AskEngine(this.events);

  @override
  Stream<AskEvent> ask(AskRequest req, ToolExecutor tools) async* {
    for (final e in events) {
      yield e;
    }
  }
}

class _SlowAskEngine extends ScriptedEngine {
  @override
  Stream<AskEvent> ask(AskRequest req, ToolExecutor tools) async* {
    await Future.delayed(const Duration(seconds: 5));
    yield AskAnswer('too late');
  }
}

void main() {
  final stubTools = _StubTools({
    'get_medication_occurrences': [
      {'id': 'occ1', 'medication': 'Amlodipine', 'status': 'taken'},
      {'id': 'occ2', 'medication': 'Metformin', 'status': 'pending'},
    ],
    'get_measurements': [
      {
        'id': 'm1',
        'type': 'blood_pressure',
        'value1': 128.0,
        'value2': 82.0,
        'unit': 'mmHg',
      },
    ],
    'get_care_notes': [
      {'id': 'n1', 'text': 'Masaya si Lola ngayon.', 'sourceType': 'manual'},
    ],
  });

  group('advice refusal', () {
    final agent = AskAgent(engine: NullEngine(), tools: stubTools);
    final adviceQueries = [
      'Should I give her 2 tablets?',
      'Pwede ba inumin ni lola ang gamot?',
      'Is it safe to double the dose?',
      'What is wrong with lola?',
    ];

    for (final q in adviceQueries) {
      test('refuses: "$q"', () async {
        final res = await agent.ask(q);
        expect(res.refused, isTrue);
        expect(res.text, 'Ask the doctor.');
      });
    }
  });

  group('deterministic fallback (Basic mode)', () {
    final agent = AskAgent(engine: NullEngine(), tools: stubTools);

    test('medication question → taken/total', () async {
      final res = await agent.ask('Did lola take her meds today?');
      expect(res.text, contains('1 of 2'));
      expect(res.sourceIds, contains('occ1'));
      expect(res.usedDeterministicFallback, isTrue);
    });

    test('BP question → last reading', () async {
      final res = await agent.ask('How is her blood pressure?');
      expect(res.text, 'Last BP: 128.0/82.0 mmHg.');
      expect(res.sourceIds, ['m1']);
    });

    test('missed question → weekly count', () async {
      final res = await agent.ask('Any missed doses this week?');
      // canned occurrences have no 'skipped' rows but the stub ignores args
      expect(res.text, isNotEmpty);
      expect(res.usedDeterministicFallback, isTrue);
    });

    test('notes question → recent notes', () async {
      final res = await agent.ask('Any new notes?');
      expect(res.text, contains('Masaya si Lola'));
      expect(res.sourceIds, ['n1']);
    });

    test('unrecognized question → hint', () async {
      final res = await agent.ask('blah blah xyz');
      expect(res.text, contains('Try'));
      expect(res.usedDeterministicFallback, isTrue);
    });
  });

  group('engine path', () {
    test('AskAnswer → text + sources', () async {
      final agent = AskAgent(
        engine: _AskEngine([AskAnswer('2 of 3 doses taken.', sourceIds: ['occ1', 'occ2'])]),
        tools: stubTools,
      );
      final res = await agent.ask('meds today?');
      expect(res.text, '2 of 3 doses taken.');
      expect(res.sourceIds, ['occ1', 'occ2']);
    });

    test('AskTokens accumulate', () async {
      final agent = AskAgent(
        engine: _AskEngine([AskToken('BP '), AskToken('was ok')]),
        tools: stubTools,
      );
      final res = await agent.ask('bp?');
      expect(res.text, 'BP was ok');
    });

    test('engine refusal → fixed refusal', () async {
      final agent = AskAgent(
        engine: _AskEngine([AskRefused()]),
        tools: stubTools,
      );
      final res = await agent.ask('hi');
      expect(res.refused, isTrue);
    });

    test('timeout → deterministic fallback', () async {
      final agent = AskAgent(
        engine: _SlowAskEngine(),
        tools: stubTools,
        timeout: const Duration(milliseconds: 100),
      );
      final res = await agent.ask('did she take meds?');
      expect(res.usedDeterministicFallback, isTrue);
    });
  });
}
