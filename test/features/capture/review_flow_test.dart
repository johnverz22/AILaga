import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ailaga/core/database/app_database.dart';
import 'package:ailaga/core/database/database_provider.dart';
import 'package:ailaga/features/capture/presentation/review_tray_screen.dart';
import 'package:ailaga/features/capture/presentation/widgets/proposal_card.dart';
import 'package:ailaga/features/medications/data/medication_repository_impl.dart';
import 'package:ailaga/features/medications/domain/medication_status.dart';
import 'package:ailaga/features/measurements/data/measurement_repository_impl.dart';
import 'package:ailaga/services/ai/local/proposals/proposal_models.dart';
import 'package:ailaga/services/ai/local/proposals/proposal_repository.dart';

/// Full-flow widget test (C14): review tray → confirm → records persisted
/// in the real repositories, backed by an in-memory Drift database.
void main() {
  late AppDatabase db;
  late AiCaptureRepository captureRepo;

  const recipientId = 'cr-1';

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    captureRepo = AiCaptureRepository(db);
    final now = DateTime.now();
    await db.into(db.careRecipients).insert(CareRecipientsCompanion.insert(
          id: recipientId,
          displayName: 'Lola',
          createdAt: now,
          updatedAt: now,
        ));
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
  });

  tearDown(() => db.close());

  Future<(String, List<StagedProposal>)> seedCapture(
      List<ProposedRecord> records) async {
    final captureId = await captureRepo.createCapture(
      careRecipientId: recipientId,
      modality: 'voice',
      originalText: 'Uminom ng amlodipine, BP 120/80',
      engineId: 'scripted_engine',
      modelId: 'scripted',
      latencyMs: 10,
    );
    final staged = <StagedProposal>[];
    for (final r in records) {
      final id =
          await captureRepo.createProposal(captureId: captureId, record: r);
      staged.add(StagedProposal(proposalId: id, record: r));
    }
    return (captureId, staged);
  }

  Widget harness({
    required String captureId,
    required List<StagedProposal> proposals,
  }) {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        home: ReviewTrayScreen(
          captureId: captureId,
          careRecipientId: recipientId,
          heardText: 'Uminom ng amlodipine, BP 120/80',
          proposals: proposals,
        ),
      ),
    );
  }

  testWidgets('capture → review → confirm writes records', (tester) async {
    final proposals = [
      ProposedMedicationTaken(
        medicationName: 'Amlodipine',
        sourceQuote: 'uminom ng amlodipine',
      ),
      ProposedMeasurement(
        type: 'blood_pressure',
        value1: 120,
        value2: 80,
        unit: 'mmHg',
        sourceQuote: 'BP 120/80',
      ),
    ];
    final (captureId, staged) = await seedCapture(proposals);

    await tester.pumpWidget(harness(captureId: captureId, proposals: staged));
    await tester.pumpAndSettle();

    // Review tray shows heard text + both proposals.
    expect(find.textContaining('Narinig'), findsWidgets);
    expect(find.textContaining('Kumpirmahin lahat'), findsOneWidget);

    await tester.tap(find.textContaining('Kumpirmahin lahat'));
    await tester.pumpAndSettle();

    // Occurrence flipped to taken; measurement row persisted.
    final occs = await MedicationRepositoryImpl(db)
        .getOccurrencesForDate('ms-1', DateTime.now());
    expect(occs.single.status, MedicationStatus.taken);

    final now = DateTime.now();
    final measurements = await MeasurementRepositoryImpl(db).getForDateRange(
      recipientId,
      now.subtract(const Duration(days: 1)),
      now.add(const Duration(days: 1)),
    );
    expect(measurements.length, 1);
    expect(measurements.single.value1, 120);

    // All proposals marked confirmed — re-confirm is a no-op.
    final pending = await captureRepo.getPendingProposals(captureId);
    expect(pending, isEmpty);
  });

  testWidgets('discard removes proposal from tray and DB', (tester) async {
    final proposals = [
      ProposedMeasurement(
        type: 'blood_pressure',
        value1: 120,
        value2: 80,
        unit: 'mmHg',
        sourceQuote: 'BP 120/80',
      ),
    ];
    final (captureId, staged) = await seedCapture(proposals);

    await tester.pumpWidget(harness(captureId: captureId, proposals: staged));
    await tester.pumpAndSettle();

    await tester.tap(find.descendant(
      of: find.byType(ProposalCard),
      matching: find.byIcon(Icons.close),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Walang narinig'), findsOneWidget);
    expect(find.textContaining('Kumpirmahin lahat'), findsNothing);

    // The staged row is marked discarded — not merely hidden locally.
    final all = await captureRepo.getAllProposalsForCapture(captureId);
    expect(all.single.status, 'discarded');
    expect(await captureRepo.getPendingProposals(captureId), isEmpty);
  });

  testWidgets('discarded proposal is NOT written by confirm all',
      (tester) async {
    final proposals = [
      ProposedMedicationTaken(
        medicationName: 'Amlodipine',
        sourceQuote: 'uminom ng amlodipine',
      ),
      ProposedMeasurement(
        type: 'blood_pressure',
        value1: 120,
        value2: 80,
        unit: 'mmHg',
        sourceQuote: 'BP 120/80',
      ),
    ];
    final (captureId, staged) = await seedCapture(proposals);

    await tester.pumpWidget(harness(captureId: captureId, proposals: staged));
    await tester.pumpAndSettle();

    // Discard the measurement card (second ProposalCard), then confirm all.
    final cards = find.byType(ProposalCard);
    expect(cards, findsNWidgets(2));
    await tester.tap(find.descendant(
      of: cards.at(1),
      matching: find.byIcon(Icons.close),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Kumpirmahin lahat'));
    await tester.pumpAndSettle();

    // Med occurrence written; discarded measurement never persisted.
    final occs = await MedicationRepositoryImpl(db)
        .getOccurrencesForDate('ms-1', DateTime.now());
    expect(occs.single.status, MedicationStatus.taken);

    final now = DateTime.now();
    final measurements = await MeasurementRepositoryImpl(db).getForDateRange(
      recipientId,
      now.subtract(const Duration(days: 1)),
      now.add(const Duration(days: 1)),
    );
    expect(measurements, isEmpty,
        reason: 'discarded proposal must never reach the repository');
  });
}
