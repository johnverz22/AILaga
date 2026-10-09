import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ailaga/core/database/app_database.dart';
import 'package:ailaga/features/capture/application/confirm_proposals.dart';
import 'package:ailaga/features/care_notes/data/care_note_repository_impl.dart';
import 'package:ailaga/features/measurements/data/measurement_repository_impl.dart';
import 'package:ailaga/features/medications/data/medication_repository_impl.dart';
import 'package:ailaga/features/medications/domain/medication_status.dart';
import 'package:ailaga/services/ai/local/proposals/proposal_models.dart';
import 'package:ailaga/services/ai/local/proposals/proposal_repository.dart';

/// End-to-end confirm tests on a real (in-memory) Drift database:
/// proposals → repository writes → idempotent re-confirm.
void main() {
  late AppDatabase db;
  late AiCaptureRepository captureRepo;
  late ConfirmProposalsUseCase useCase;
  late MedicationRepositoryImpl medRepo;
  late MeasurementRepositoryImpl measurementRepo;

  const recipientId = 'cr-1';

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    captureRepo = AiCaptureRepository(db);
    medRepo = MedicationRepositoryImpl(db);
    measurementRepo = MeasurementRepositoryImpl(db);
    useCase = ConfirmProposalsUseCase(
      captureRepo: captureRepo,
      medicationRepo: medRepo,
      measurementRepo: measurementRepo,
      careNoteRepo: CareNoteRepositoryImpl(db),
      careRecipientId: recipientId,
    );

    final now = DateTime.now();
    await db.into(db.careRecipients).insert(CareRecipientsCompanion.insert(
          id: recipientId,
          displayName: 'Lola',
          createdAt: now,
          updatedAt: now,
        ));
  });

  tearDown(() => db.close());

  Future<String> seedCapture(List<ProposedRecord> records) async {
    final captureId = await captureRepo.createCapture(
      careRecipientId: recipientId,
      modality: 'voice',
      originalText: 'test transcript',
      engineId: 'scripted_engine',
      modelId: 'scripted',
      latencyMs: 10,
    );
    for (final r in records) {
      await captureRepo.createProposal(captureId: captureId, record: r);
    }
    return captureId;
  }

  group('medication_taken', () {
    Future<void> seedMedOccurrence() async {
      final now = DateTime.now();
      await db.into(db.medicationSchedules).insert(
          MedicationSchedulesCompanion.insert(
            id: 'ms-1',
            careRecipientId: recipientId,
            medicationName: 'Amlodipine',
            scheduleTimes: '["08:00"]',
            startDate: now,
            createdAt: now,
            updatedAt: now,
          ));
      await db.into(db.medicationOccurrences).insert(
          MedicationOccurrencesCompanion.insert(
            id: 'occ-1',
            medicationScheduleId: 'ms-1',
            scheduledAt: DateTime(now.year, now.month, now.day, 8),
            createdAt: now,
          ));
    }

    test('confirm marks occurrence taken with ai provenance', () async {
      await seedMedOccurrence();
      final captureId = await seedCapture([
        ProposedMedicationTaken(
          medicationName: 'Amlodipine',
          sourceQuote: 'uminom ng amlodipine',
        ),
      ]);

      final created = await useCase.confirmAll(captureId);
      expect(created, 1);

      final occs = await medRepo.getOccurrencesForDate('ms-1', DateTime.now());
      expect(occs.single.status, MedicationStatus.taken);
      expect(occs.single.statusNote, contains('Phone-assisted'));
    });

    test('confirming twice creates no duplicates', () async {
      await seedMedOccurrence();
      final captureId = await seedCapture([
        ProposedMedicationTaken(
          medicationName: 'Amlodipine',
          sourceQuote: 'uminom ng amlodipine',
        ),
      ]);

      expect(await useCase.confirmAll(captureId), 1);
      // Second run: no pending proposals left → nothing created.
      expect(await useCase.confirmAll(captureId), 0);
      final occs = await medRepo.getOccurrencesForDate('ms-1', DateTime.now());
      expect(occs.length, 1);
    });
  });

  group('measurement', () {
    test('confirm writes one measurement row; re-confirm is a no-op', () async {
      final now = DateTime.now();
      final captureId = await seedCapture([
        ProposedMeasurement(
          type: 'blood_pressure',
          value1: 120,
          value2: 80,
          unit: 'mmHg',
          sourceQuote: 'BP 120/80',
        ),
      ]);

      expect(await useCase.confirmAll(captureId), 1);
      expect(await useCase.confirmAll(captureId), 0);

      final rows = await measurementRepo.getForDateRange(
        recipientId,
        now.subtract(const Duration(days: 1)),
        now.add(const Duration(days: 1)),
      );
      expect(rows.length, 1);
      expect(rows.single.measurementType.databaseValue, 'blood_pressure');
      expect(rows.single.value1, 120);
      expect(rows.single.sourceType, 'ai_assisted');
    });
  });

  group('care_note', () {
    test('confirm writes note marked ai_assisted + confirmed', () async {
      final now = DateTime.now();
      final captureId = await seedCapture([
        ProposedCareNote(
          text: 'Masaya si Lola ngayon.',
          sourceQuote: 'masaya si lola',
        ),
      ]);

      expect(await useCase.confirmAll(captureId), 1);

      final rows = await CareNoteRepositoryImpl(db).getForDateRange(
        recipientId,
        now.subtract(const Duration(days: 1)),
        now.add(const Duration(days: 1)),
      );
      expect(rows.length, 1);
      expect(rows.single.sourceType, 'ai_assisted');
      expect(rows.single.reviewStatus, 'confirmed');
    });
  });

  group('safety gates (never write bad data)', () {
    test(
        'unscheduled medication is NOT confirmed — proposal stays pending '
        '(spec §5.5: no "taken" for an unscheduled drug)', () async {
      // No schedule seeded for this drug.
      final captureId = await seedCapture([
        ProposedMedicationTaken(
          medicationName: 'Vitamin C',
          sourceQuote: 'uminom ng vitamin c',
          flag: ProposalFlag.check,
        ),
      ]);

      final created = await useCase.confirmAll(captureId);
      expect(created, 0);

      final pending = await captureRepo.getPendingProposals(captureId);
      expect(pending.length, 1, reason: 'must stay visible, not silently confirmed');
    });

    test(
        'out-of-range measurement is NEVER persisted on confirm '
        '(invariant 4: flag, do not write)', () async {
      final now = DateTime.now();
      final captureId = await seedCapture([
        ProposedMeasurement(
          type: 'blood_pressure',
          value1: 1300, // out of 50–300 range
          value2: 85,
          unit: 'mmHg',
          sourceQuote: 'BP 1300/85',
          flag: ProposalFlag.check,
        ),
      ]);

      final created = await useCase.confirmAll(captureId);
      expect(created, 0);

      final rows = await measurementRepo.getForDateRange(
        recipientId,
        now.subtract(const Duration(days: 1)),
        now.add(const Duration(days: 1)),
      );
      expect(rows, isEmpty, reason: '1300 mmHg must never reach the table');

      final pending = await captureRepo.getPendingProposals(captureId);
      expect(pending.length, 1, reason: 'stays pending until edited');
    });

    test('no pending occurrence today → taken proposal stays pending',
        () async {
      final now = DateTime.now();
      // Schedule exists but no occurrence row for today.
      await db.into(db.medicationSchedules).insert(
          MedicationSchedulesCompanion.insert(
            id: 'ms-2',
            careRecipientId: recipientId,
            medicationName: 'Losartan',
            scheduleTimes: '["08:00"]',
            startDate: now,
            createdAt: now,
            updatedAt: now,
          ));
      final captureId = await seedCapture([
        ProposedMedicationTaken(
          medicationName: 'Losartan',
          sourceQuote: 'uminom ng losartan',
        ),
      ]);

      expect(await useCase.confirmAll(captureId), 0);
      final pending = await captureRepo.getPendingProposals(captureId);
      expect(pending.length, 1);
    });
  });

  group('discard', () {
    test('discarded proposal is not confirmed later', () async {
      await db.into(db.medicationSchedules).insert(
          MedicationSchedulesCompanion.insert(
            id: 'ms-1',
            careRecipientId: recipientId,
            medicationName: 'Amlodipine',
            scheduleTimes: '["08:00"]',
            startDate: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
      final captureId = await seedCapture([
        ProposedMedicationTaken(
          medicationName: 'Amlodipine',
          sourceQuote: 'amin',
        ),
      ]);
      final pending = await captureRepo.getPendingProposals(captureId);
      await useCase.discardOne(pending.single.id);

      expect(await useCase.confirmAll(captureId), 0);
      final all = await captureRepo.getAllProposalsForCapture(captureId);
      expect(all.single.status, 'discarded');
    });
  });

  test('provenance: capture row keeps engine + transcript', () async {
    final captureId = await seedCapture([]);
    final row = await (db.select(db.aiCaptures)
          ..where((t) => t.id.equals(captureId)))
        .getSingle();
    expect(row.engineId, 'scripted_engine');
    expect(row.modality, 'voice');
    expect(row.originalText, 'test transcript');
  });
}
