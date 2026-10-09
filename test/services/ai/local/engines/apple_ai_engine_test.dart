import 'package:flutter_test/flutter_test.dart';

import 'package:ailaga/services/ai/local/engines/apple_ai_engine.dart';
import 'package:ailaga/services/ai/local/local_ai_engine.dart';
import 'package:ailaga/services/ai/local/proposals/proposal_models.dart';

ExtractionContext ctx() => ExtractionContext(
      activeMeds: const ['Amlodipine'],
      now: DateTime(2023, 10, 10, 10),
      timezone: 'Asia/Manila',
    );

const _okJson = '{"transcript":"Uminom si Lola ng amlodipine kanina","calls":['
    '{"name":"propose_medication_taken","parameters":{'
    '"medication_name":"Amlodipine","time_phrase":"kanina",'
    '"source_quote":"aminom amlodipine kanina"}}]}';

void main() {
  AppleAiEngine engine({
    AppleRespondFn? respond,
    AppleTranscribeFn? transcribe,
    AppleOcrFn? ocr,
    Map<String, Object?> availability = const {'available': true},
  }) =>
      AppleAiEngine(
        respond: respond ?? (p, {temperature}) async => _okJson,
        transcribe: transcribe ?? (p) async => 'transcribed audio',
        ocr: ocr ?? (p) async => 'ocr text',
        availability: () async => availability,
      );

  group('extractFromText', () {
    test('emits transcript + proposal + complete', () async {
      final events =
          await engine().extractFromText('hello', ctx()).toList();
      expect(events.whereType<TranscriptUpdated>(), isNotEmpty);
      final proposals = events.whereType<ProposalEmitted>().toList();
      expect(proposals.single.record, isA<ProposedMedicationTaken>());
      expect(events.last, isA<ExtractionComplete>());
    });

    test('unavailable engine → ExtractionFailed + degraded to basic',
        () async {
      final e = engine(availability: const {
        'available': false,
        'reason': 'deviceNotEligible'
      });
      final events = await e.extractFromText('x', ctx()).toList();
      expect(events.single, isA<ExtractionFailed>());
      expect(await e.tier(), AiTier.basic);
    });

    test('inference failing 3x → degrade + ExtractionFailed', () async {
      var calls = 0;
      final e = engine(
          respond: (p, {temperature}) async {
            calls++;
            throw StateError('boom');
          });
      final events = await e.extractFromText('x', ctx()).toList();
      expect(calls, 3);
      expect(events.last, isA<ExtractionFailed>());
      expect(await e.tier(), AiTier.basic);
    });

    test('malformed JSON → zero proposals, still completes', () async {
      final e = engine(respond: (p, {temperature}) async => 'not json');
      final events = await e.extractFromText('x', ctx()).toList();
      expect(events.whereType<ProposalEmitted>(), isEmpty);
      expect(events.last, isA<ExtractionComplete>());
    });
  });

  group('extractFromAudio / extractFromImage', () {
    test('audio → ASR transcript → extraction', () async {
      String? seenPrompt;
      final e = engine(
        respond: (p, {temperature}) async {
          seenPrompt = p;
          return _okJson;
        },
        transcribe: (path) async {
          expect(path, '/tmp/a.wav');
          return 'Uminom ng amlodipine';
        },
      );
      final events = await e
          .extractFromAudio(
              WavAudioClip(path: '/tmp/a.wav', duration: Duration.zero),
              ctx())
          .toList();
      expect(events.whereType<TranscriptUpdated>().first.text,
          'Uminom ng amlodipine');
      expect(seenPrompt, contains('Uminom ng amlodipine'));
      expect(events.last, isA<ExtractionComplete>());
    });

    test('ASR unavailable → ExtractionFailed, never invents transcript',
        () async {
      final e = engine(transcribe: (p) async => null);
      final events = await e
          .extractFromAudio(
              WavAudioClip(path: '/tmp/a.wav', duration: Duration.zero),
              ctx())
          .toList();
      expect(events.single, isA<ExtractionFailed>());
    });

    test('image → OCR text → extraction', () async {
      String? seenPrompt;
      final e = engine(
        respond: (p, {temperature}) async {
          seenPrompt = p;
          return _okJson;
        },
        ocr: (path) async => 'BP 120/80 amlodipine',
      );
      final events = await e
          .extractFromImage(
              FileImageInput(path: '/tmp/p.jpg'), ImageIntent.monitor, ctx())
          .toList();
      expect(seenPrompt, contains('monitor'));
      expect(events.last, isA<ExtractionComplete>());
    });

    test('OCR empty → ExtractionFailed', () async {
      final e = engine(ocr: (p) async => null);
      final events = await e
          .extractFromImage(
              FileImageInput(path: '/tmp/p.jpg'), ImageIntent.reseta, ctx())
          .toList();
      expect(events.single, isA<ExtractionFailed>());
    });
  });

  group('narrate / ask', () {
    test('narrate returns model output', () async {
      final e = engine(
          respond: (p, {temperature}) async => 'Si Lola ay okay ngayon.');
      final out = await e.narrate(NarrationRequest(
          facts: const ['[r:1] BP 120/80'],
          audience: 'kapatid',
          language: 'Filipino'));
      expect(out, 'Si Lola ay okay ngayon.');
    });

    test('narrate failure → AiUnavailable + degrade', () async {
      final e = engine(
          respond: (p, {temperature}) async => throw StateError('x'));
      await expectLater(
          e.narrate(NarrationRequest(
              facts: const [], audience: 'a', language: 'en')),
          throwsA(isA<AiUnavailable>()));
      expect(await e.tier(), AiTier.basic);
    });

    test('ask: tool round then answer with source ids', () async {
      var round = 0;
      final tools = _FakeTools();
      final e = engine(respond: (p, {temperature}) async {
        round++;
        if (round == 1) {
          return '{"tool":"get_recent_measurements","args":{"limit":3}}';
        }
        return '{"answer":"BP was 120/80","source_ids":["m-1"]}';
      });
      final events =
          await e.ask(AskRequest(query: 'BP ni Lola?'), tools).toList();
      expect(tools.called, ['get_recent_measurements']);
      final answer = events.whereType<AskAnswer>().single;
      expect(answer.text, 'BP was 120/80');
      expect(answer.sourceIds, ['m-1']);
    });

    test('ask: direct answer without tool call', () async {
      final e = engine(respond: (p, {temperature}) async =>
          '{"answer":"3 notes","source_ids":[]}');
      final events = await e
          .ask(AskRequest(query: 'notes?'), _FakeTools())
          .toList();
      expect(events.single, isA<AskAnswer>());
    });

    test('ask: engine unavailable → AskFailed', () async {
      final e = engine(availability: const {'available': false});
      final events = await e
          .ask(AskRequest(query: 'x'), _FakeTools())
          .toList();
      expect(events.single, isA<AskFailed>());
    });

    test('ask: exceeds 3 tool rounds → AskFailed', () async {
      final e = engine(respond: (p, {temperature}) async =>
          '{"tool":"get_recent_measurements","args":{}}');
      final events = await e
          .ask(AskRequest(query: 'x'), _FakeTools())
          .toList();
      expect(events.last, isA<AskFailed>());
      expect((events.last as AskFailed).reason, 'max_tool_rounds');
    });
  });
}

class _FakeTools implements ToolExecutor {
  final called = <String>[];
  @override
  List<String> get toolNames => ['get_recent_measurements'];
  @override
  Future<Object?> call(String name, Map<String, Object?> args) async {
    called.add(name);
    return {'rows': []};
  }
}
