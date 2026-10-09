import 'package:flutter_test/flutter_test.dart';
import 'package:ailaga/services/ai/local/narration/narration_verifier.dart';
import 'package:ailaga/services/ai/local/narration/narrator.dart';
import 'package:ailaga/services/ai/local/engines/scripted_engine.dart';
import 'package:ailaga/services/ai/care_summary_models.dart';

void main() {
  final facts = FactSet(
    generatedAt: DateTime(2023, 10, 10, 10, 0),
    facts: const [
      Fact(id: 'bp1', text: 'BP 120/80 at 8:00 AM', entityRef: 'measurement:1'),
      Fact(id: 'med1', text: 'Amlodipine taken at 8:05 AM', entityRef: 'occurrence:2'),
    ],
  );

  group('NarrationVerifier', () {
    test('accepts grounded narration and strips markers', () {
      final v = NarrationVerifier();
      final res = v.verify(
        'BP was 120/80 this morning [r:bp1]. Amlodipine was taken [r:med1].',
        facts,
      );
      expect(res.verified, isTrue);
      expect(res.text, isNot(contains('[r:')));
      expect(res.text, contains('120/80'));
      expect(res.citedFactIds, containsAll({'bp1', 'med1'}));
      expect(res.status, GenerationStatus.success);
    });

    test('falls back when a cited fact ID is invented', () {
      final v = NarrationVerifier();
      final res = v.verify('BP was 999/999 [r:bad_id].', facts);
      expect(res.verified, isFalse);
      expect(res.status, GenerationStatus.fallback);
      expect(res.reason, contains('ungrounded'));
    });

    test('falls back when >40% of citations are ungrounded', () {
      final v = NarrationVerifier();
      final res = v.verify(
        'BP ok [r:bp1]. Took insulin [r:x1]. Took insulin [r:x2].',
        facts,
      );
      // 1 valid of 3 → 66% dropped
      expect(res.verified, isFalse);
      expect(res.status, GenerationStatus.fallback);
    });

    test('falls back on dosing advice ("should take")', () {
      final v = NarrationVerifier();
      final res = v.verify(
        'She should take an extra amlodipine [r:med1].',
        facts,
      );
      expect(res.verified, isFalse);
      expect(res.reason, contains('advice'));
    });

    test('falls back on advice phrased with "take your"', () {
      final v = NarrationVerifier();
      final res = v.verify(
        'Take your medicine twice a day now [r:med1].',
        facts,
      );
      expect(res.verified, isFalse);
    });

    test('falls back on "I recommend" phrasing', () {
      final v = NarrationVerifier();
      final res = v.verify(
        'I recommend she see a doctor soon [r:bp1].',
        facts,
      );
      expect(res.verified, isFalse);
    });
  });

  group('Narrator', () {
    test('verified output is marked AI-generated', () async {
      final narrator = Narrator(
        engine: ScriptedEngine(
          narrationResult: 'BP was 120/80 this morning [r:bp1].',
        ),
        verifier: NarrationVerifier(),
      );
      final out = await narrator.narrate(
        facts: facts,
        audience: 'helper',
        language: 'english',
      );
      expect(out.isAiGenerated, isTrue);
      expect(out.text, contains('120/80'));
      expect(out.fallbackReason, isNull);
    });

    test('advice output falls back to template', () async {
      final narrator = Narrator(
        engine: ScriptedEngine(
          narrationResult: 'She should take 2 tablets [r:med1].',
        ),
        verifier: NarrationVerifier(),
      );
      final out = await narrator.narrate(
        facts: facts,
        audience: 'helper',
        language: 'english',
      );
      expect(out.isAiGenerated, isFalse);
      expect(out.text, contains('Care Update'));
      expect(out.text, contains('120/80'));
      expect(out.fallbackReason, isNotNull);
    });

    test('engine error falls back to template', () async {
      final narrator = Narrator(
        engine: _ThrowingEngine(),
        verifier: NarrationVerifier(),
      );
      final out = await narrator.narrate(
        facts: facts,
        audience: 'sibling',
        language: 'filipino',
      );
      expect(out.isAiGenerated, isFalse);
      expect(out.text, contains('Ulat ng Pag-aalaga'));
    });
  });
}

class _ThrowingEngine extends ScriptedEngine {
  @override
  Future<String> narrate(req) async => throw StateError('engine dead');
}
