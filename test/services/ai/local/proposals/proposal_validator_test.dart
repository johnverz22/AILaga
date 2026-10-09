import 'package:flutter_test/flutter_test.dart';
import 'package:ailaga/services/ai/local/proposals/proposal_models.dart';
import 'package:ailaga/services/ai/local/proposals/proposal_validator.dart';
import 'package:ailaga/services/ai/local/proposals/med_matcher.dart';
import 'package:ailaga/services/ai/local/proposals/time_resolver.dart';

void main() {
  group('MedMatcher', () {
    test('exact match', () {
      var res = MedMatcher.match('Amlodipine', ['Amlodipine', 'Losartan']);
      expect(res.status, MatchStatus.sure);
      expect(res.matchedName, 'Amlodipine');
    });

    test('case insensitive exact match', () {
      var res = MedMatcher.match('amlodipine', ['Amlodipine', 'Losartan']);
      expect(res.status, MatchStatus.sure);
      expect(res.matchedName, 'Amlodipine');
    });

    test('typo match >= 0.8', () {
      var res = MedMatcher.match('amlodipin', ['Amlodipine', 'Losartan']);
      expect(res.status, MatchStatus.check);
      expect(res.matchedName, 'Amlodipine');
    });

    test('unmatched', () {
      var res = MedMatcher.match('Vitamin C', ['Amlodipine', 'Losartan']);
      expect(res.status, MatchStatus.unmatched);
    });
  });

  group('TimeResolver', () {
    final now = DateTime(2023, 10, 10, 10, 0); // 10 AM

    test('ngayon', () {
      expect(TimeResolver.resolve('ngayon', now), now);
    });

    test('kaninang umaga', () {
      expect(TimeResolver.resolve('kaninang umaga', now), DateTime(2023, 10, 10, 8, 0));
    });

    test('kagabi', () {
      expect(TimeResolver.resolve('kagabi', now), DateTime(2023, 10, 9, 20, 0));
    });

    test('8am', () {
      expect(TimeResolver.resolve('8am', now), DateTime(2023, 10, 10, 8, 0));
    });
    
    test('8:30pm', () {
      expect(TimeResolver.resolve('8:30pm', now), DateTime(2023, 10, 10, 20, 30));
    });
  });

  group('ProposalValidator', () {
    final now = DateTime(2023, 10, 10, 10, 0);
    final activeMeds = ['Amlodipine', 'Metformin'];
    
    test('drops if quote not in transcript', () {
      final validator = ProposalValidator(
        activeMeds: activeMeds,
        now: now,
        transcript: 'Uminom ng amlodipine',
      );
      final record = ProposedMedicationTaken(
        medicationName: 'Amlodipine',
        sourceQuote: 'losartan',
      );
      expect(validator.validate(record), isNull);
    });

    test('validates valid BP as sure', () {
      final validator = ProposalValidator(
        activeMeds: activeMeds,
        now: now,
        transcript: 'BP ko ay 120/80',
      );
      final record = ProposedMeasurement(
        type: 'blood_pressure',
        value1: 120,
        value2: 80,
        unit: 'mmHg',
        sourceQuote: '120/80',
      );
      final validated = validator.validate(record) as ProposedMeasurement;
      expect(validated.flag, ProposalFlag.sure);
    });

    test('validates out of range BP as check', () {
      final validator = ProposalValidator(
        activeMeds: activeMeds,
        now: now,
        transcript: 'BP ko ay 40/80', // 40 is below min 50
      );
      final record = ProposedMeasurement(
        type: 'blood_pressure',
        value1: 40,
        value2: 80,
        unit: 'mmHg',
        sourceQuote: '40/80',
      );
      final validated = validator.validate(record) as ProposedMeasurement;
      expect(validated.flag, ProposalFlag.check);
    });
    
    test('drops future time for taken', () {
      final validator = ProposalValidator(
        activeMeds: activeMeds,
        now: now, // 10 AM
        transcript: 'uminom amlodipine 11am',
      );
      final record = ProposedMedicationTaken(
        medicationName: 'Amlodipine',
        timePhrase: '11am',
        sourceQuote: 'amlodipine',
      );
      expect(validator.validate(record), isNull);
    });
  });
}
