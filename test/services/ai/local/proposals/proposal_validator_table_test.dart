import 'package:flutter_test/flutter_test.dart';
import 'package:ailaga/services/ai/local/proposals/proposal_models.dart';
import 'package:ailaga/services/ai/local/proposals/proposal_validator.dart';
import 'package:ailaga/services/ai/local/proposals/med_matcher.dart';
import 'package:ailaga/services/ai/local/proposals/time_resolver.dart';

/// Table-driven audit suite (spec C-3 / F13).
/// Covers MedMatcher thresholds, Taglish TimeResolver phrases, and every
/// ProposalValidator branch: quote grounding, med match flags, measurement
/// ranges, ambiguous/future time handling.
void main() {
  // Fixed "now": Tuesday 2023-10-10 10:00 AM.
  final now = DateTime(2023, 10, 10, 10, 0);
  const meds = ['Amlodipine', 'Metformin', 'Losartan'];

  group('MedMatcher table', () {
    final cases = <(String, String, MatchStatus, String?)>{
      ('exact', 'Amlodipine', MatchStatus.sure, 'Amlodipine'),
      ('case insensitive', 'amlodipine', MatchStatus.sure, 'Amlodipine'),
      ('punctuation stripped', 'Amlodipine!', MatchStatus.sure, 'Amlodipine'),
      ('typo >= 0.8', 'amlodipin', MatchStatus.check, 'Amlodipine'),
      ('truncated >= 0.8', 'Metformi', MatchStatus.check, 'Metformin'),
      ('different drug', 'Vitamin C', MatchStatus.unmatched, null),
      ('empty input', '', MatchStatus.unmatched, null),
      // Dose suffix pushes similarity to 0.75 — documented limitation:
      // unmatched drugs stay visible as Check cards, never dropped.
      ('dose suffix', 'Amlodipin 5mg', MatchStatus.unmatched, null),
      ('brand name', 'Norvasc', MatchStatus.unmatched, null),
      ('partial below 0.8', 'Metfo', MatchStatus.unmatched, null),
    };
    for (final (name, input, status, matched) in cases) {
      test(name, () {
        final res = MedMatcher.match(input, meds);
        expect(res.status, status, reason: input);
        if (matched != null) expect(res.matchedName, matched);
      });
    }
    test('empty med list → unmatched', () {
      expect(MedMatcher.match('Amlodipine', const []).status,
          MatchStatus.unmatched);
    });
  });

  group('TimeResolver table', () {
    final cases = <(String, String, DateTime?)>{
      ('ngayon', 'ngayon', now),
      ('now', 'now', now),
      ('kanina', 'kanina', DateTime(2023, 10, 10, 9, 0)),
      ('kaninang umaga', 'kaninang umaga', DateTime(2023, 10, 10, 8, 0)),
      ('this morning', 'this morning', DateTime(2023, 10, 10, 8, 0)),
      ('kagabi', 'kagabi', DateTime(2023, 10, 9, 20, 0)),
      ('last night', 'last night', DateTime(2023, 10, 9, 20, 0)),
      ('yesterday evening', 'yesterday evening', DateTime(2023, 10, 9, 20, 0)),
      ('kahapon', 'kahapon', DateTime(2023, 10, 9, 12, 0)),
      ('yesterday', 'yesterday', DateTime(2023, 10, 9, 12, 0)),
      ('8am', '8am', DateTime(2023, 10, 10, 8, 0)),
      ('8:30pm', '8:30pm', DateTime(2023, 10, 10, 20, 30)),
      ('12am → midnight', '12am', DateTime(2023, 10, 10, 0, 0)),
      ('12pm → noon', '12pm', DateTime(2023, 10, 10, 12, 0)),
      ('uppercase + spaces', '  8AM  ', DateTime(2023, 10, 10, 8, 0)),
      ('mamaya → null', 'mamaya', null),
      ('bukas → null', 'bukas', null),
      ('sa hapon → null', 'sa hapon', null),
      ('empty → null', '', null),
      ('nonsense → null', 'blah blah', null),
    };
    for (final (name, phrase, expected) in cases) {
      test(name, () {
        expect(TimeResolver.resolve(phrase, now), expected, reason: phrase);
      });
    }
  });

  group('ProposalValidator table', () {
    /// (name, record, expected flag, transcript override)
    /// expected == null → the proposal is dropped.
    /// transcript == null → transcript defaults to the sourceQuote itself.
    final cases =
        <(String, ProposedRecord, ProposalFlag?, String?)>{
      // --- MedicationTaken ---
      ('med taken: exact, no time → sure',
          ProposedMedicationTaken(
              medicationName: 'Amlodipine', sourceQuote: 'uminom amlodipine'),
          ProposalFlag.sure, null),
      ('med taken: exact + kanina → sure',
          ProposedMedicationTaken(
              medicationName: 'Amlodipine',
              timePhrase: 'kanina',
              sourceQuote: 'uminom amlodipine'),
          ProposalFlag.sure, null),
      ('med taken: exact + past 8am → sure',
          ProposedMedicationTaken(
              medicationName: 'Amlodipine',
              timePhrase: '8am',
              sourceQuote: 'uminom amlodipine'),
          ProposalFlag.sure, null),
      ('med taken: exact + kagabi → sure',
          ProposedMedicationTaken(
              medicationName: 'Amlodipine',
              timePhrase: 'kagabi',
              sourceQuote: 'uminom amlodipine'),
          ProposalFlag.sure, null),
      ('med taken: future 11am → dropped',
          ProposedMedicationTaken(
              medicationName: 'Amlodipine',
              timePhrase: '11am',
              sourceQuote: 'uminom amlodipine'),
          null, null),
      ('med taken: typo name → check',
          ProposedMedicationTaken(
              medicationName: 'amlodipin', sourceQuote: 'uminom amlodipin'),
          ProposalFlag.check, null),
      ('med taken: unmatched drug → check (not dropped)',
          ProposedMedicationTaken(
              medicationName: 'Vitamin C', sourceQuote: 'uminom vitamin c'),
          ProposalFlag.check, null),
      ('med taken: ambiguous time mamaya → check',
          ProposedMedicationTaken(
              medicationName: 'Amlodipine',
              timePhrase: 'mamaya',
              sourceQuote: 'uminom amlodipine'),
          ProposalFlag.check, null),
      ('med taken: empty quote → dropped',
          ProposedMedicationTaken(
              medicationName: 'Amlodipine', sourceQuote: ''),
          null, 'uminom amlodipine'),
      ('med taken: quote not in transcript → dropped',
          ProposedMedicationTaken(
              medicationName: 'Amlodipine', sourceQuote: 'losartan'),
          null, 'uminom amlodipine'),
      // --- MedicationSkipped ---
      ('med skipped: exact → sure',
          ProposedMedicationSkipped(
              medicationName: 'Metformin',
              reasonText: 'masakit ang tiyan',
              sourceQuote: 'hindi ininom metformin'),
          ProposalFlag.sure, null),
      ('med skipped: typo → check',
          ProposedMedicationSkipped(
              medicationName: 'metformi',
              sourceQuote: 'hindi ininom metformi'),
          ProposalFlag.check, null),
      ('med skipped: unmatched → check',
          ProposedMedicationSkipped(
              medicationName: 'Biogesic',
              sourceQuote: 'hindi ininom biogesic'),
          ProposalFlag.check, null),
      // --- Measurements: blood pressure ---
      ('bp 120/80 → sure', bp(120, 80), ProposalFlag.sure, null),
      ('bp 49/80 low systolic → check', bp(49, 80), ProposalFlag.check, null),
      ('bp 50/30 min boundary → sure', bp(50, 30), ProposalFlag.sure, null),
      ('bp 300/200 max boundary → sure', bp(300, 200), ProposalFlag.sure, null),
      ('bp 301/80 → check', bp(301, 80), ProposalFlag.check, null),
      ('bp 120/29 low diastolic → check', bp(120, 29), ProposalFlag.check, null),
      ('bp 120/201 → check', bp(120, 201), ProposalFlag.check, null),
      ('bp systolic only 120 → sure', bp(120, null), ProposalFlag.sure, null),
      // --- Measurements: pulse ---
      ('pulse 70 → sure', meas('pulse', 70, 'bpm'), ProposalFlag.sure, null),
      ('pulse 19 → check', meas('pulse', 19, 'bpm'), ProposalFlag.check, null),
      ('pulse 300 boundary → sure',
          meas('pulse', 300, 'bpm'), ProposalFlag.sure, null),
      // --- Measurements: temperature ---
      ('temp 37.5 C → sure',
          meas('temperature', 37.5, 'C'), ProposalFlag.sure, null),
      ('temp 45.1 C → check',
          meas('temperature', 45.1, 'C'), ProposalFlag.check, null),
      ('temp 98.6 F → sure',
          meas('temperature', 98.6, 'F'), ProposalFlag.sure, null),
      ('temp 85 F → check',
          meas('temperature', 85, 'F'), ProposalFlag.check, null),
      // --- Measurements: weight ---
      ('weight 60 kg → sure',
          meas('weight', 60, 'kg'), ProposalFlag.sure, null),
      ('weight 0.9 kg → check',
          meas('weight', 0.9, 'kg'), ProposalFlag.check, null),
      ('weight 150 lbs → sure',
          meas('weight', 150, 'lbs'), ProposalFlag.sure, null),
      // --- Measurements: blood glucose ---
      ('glucose 100 mg/dL → sure',
          meas('blood_glucose', 100, 'mg/dL'), ProposalFlag.sure, null),
      ('glucose 19 mg/dL → check',
          meas('blood_glucose', 19, 'mg/dL'), ProposalFlag.check, null),
      ('glucose 5.5 mmol/L → sure',
          meas('blood_glucose', 5.5, 'mmol/L'), ProposalFlag.sure, null),
      ('glucose 60 mmol/L → check',
          meas('blood_glucose', 60, 'mmol/L'), ProposalFlag.check, null),
      // Unknown measurement types have no range table → pass as sure;
      // the confirm gate only re-checks known ranges.
      ('spo2 unknown type → sure',
          meas('spo2', 98, '%'), ProposalFlag.sure, null),
      // --- Measurement time handling ---
      ('measurement + ambiguous time → check',
          ProposedMeasurement(
              type: 'pulse',
              value1: 70,
              unit: 'bpm',
              timePhrase: 'mamaya',
              sourceQuote: 'pulse 70'),
          ProposalFlag.check, null),
      ('measurement + future time → dropped',
          ProposedMeasurement(
              type: 'pulse',
              value1: 70,
              unit: 'bpm',
              timePhrase: '11am',
              sourceQuote: 'pulse 70'),
          null, null),
      ('out-of-range + ambiguous time → check',
          ProposedMeasurement(
              type: 'pulse',
              value1: 500,
              unit: 'bpm',
              timePhrase: 'mamaya',
              sourceQuote: 'pulse 500'),
          ProposalFlag.check, null),
      // --- Passthrough kinds (grounded quote required) ---
      ('care note → sure passthrough',
          ProposedCareNote(
              text: 'masaya si lola', sourceQuote: 'masaya si lola'),
          ProposalFlag.sure, null),
      ('appointment → sure passthrough',
          ProposedAppointment(
              datetimePhrase: 'sa friday',
              provider: 'Dr. Santos',
              sourceQuote: 'checkup sa friday'),
          ProposalFlag.sure, null),
      ('med schedule → sure passthrough',
          ProposedMedicationSchedule(
              name: 'Amlodipine',
              strength: '5mg',
              timesHhmm: const ['08:00'],
              sourceQuote: 'amlodipine 5mg daily'),
          ProposalFlag.sure, null),
    };

    test('validator table has >= 40 cases', () {
      expect(cases.length, greaterThanOrEqualTo(40));
    });

    for (final (name, record, expected, transcript) in cases) {
      test(name, () {
        final validator = ProposalValidator(
          activeMeds: meds,
          now: now,
          transcript: transcript ?? record.sourceQuote,
        );
        final result = validator.validate(record);
        if (expected == null) {
          expect(result, isNull, reason: name);
        } else {
          expect(result, isNotNull, reason: name);
          expect(result!.flag, expected, reason: name);
        }
      });
    }

    test('quote case difference still grounds (case-insensitive)', () {
      final validator = ProposalValidator(
        activeMeds: meds,
        now: now,
        transcript: 'UMINOM NG AMLODIPINE KANINA',
      );
      final result = validator.validate(ProposedMedicationTaken(
        medicationName: 'Amlodipine',
        timePhrase: 'kanina',
        sourceQuote: 'uminom ng amlodipine',
      ));
      expect(result, isNotNull);
      expect(result!.flag, ProposalFlag.sure);
    });

    test('unmatched med keeps original name on the Check card', () {
      final validator = ProposalValidator(
        activeMeds: meds,
        now: now,
        transcript: 'uminom ng vitamin c',
      );
      final result = validator.validate(ProposedMedicationTaken(
        medicationName: 'Vitamin C',
        sourceQuote: 'vitamin c',
      )) as ProposedMedicationTaken;
      expect(result.flag, ProposalFlag.check);
      expect(result.medicationName, 'Vitamin C');
    });
  });
}

ProposedMeasurement meas(String type, num v1, String unit) =>
    ProposedMeasurement(
      type: type,
      value1: v1,
      unit: unit,
      sourceQuote: '$type $v1 $unit',
    );

ProposedMeasurement bp(num sys, num? dia) => ProposedMeasurement(
      type: 'blood_pressure',
      value1: sys,
      value2: dia,
      unit: 'mmHg',
      sourceQuote: 'bp $sys${dia != null ? "/$dia" : ""}',
    );
