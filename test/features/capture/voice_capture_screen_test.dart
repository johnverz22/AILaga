import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ailaga/core/database/app_database.dart';
import 'package:ailaga/core/database/database_provider.dart';
import 'package:ailaga/features/capture/presentation/voice_capture_screen.dart';
import 'package:ailaga/features/capture/presentation/review_tray_screen.dart';
import 'package:ailaga/features/measurements/data/measurement_repository_impl.dart';
import 'package:ailaga/services/ai/local/ai_providers.dart';
import 'package:ailaga/services/ai/local/engines/scripted_engine.dart';
import 'package:ailaga/services/ai/local/local_ai_engine.dart';
import 'package:ailaga/services/ai/local/proposals/proposal_models.dart';
import 'package:ailaga/services/ai/local/proposals/proposal_repository.dart';

/// C14: capture-screen pump with a ScriptedEngine — typed text in,
/// staged proposals out, review tray confirm persists real records.
/// Backed by an in-memory Drift database.
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
  });

  tearDown(() => db.close());

  Widget harness(LocalAiEngine engine) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        localAiEngineProvider.overrideWith((ref) => engine),
      ],
      child: const MaterialApp(home: VoiceCaptureScreen()),
    );
  }

  testWidgets('typed text → review tray → confirm writes the record',
      (tester) async {
    final engine = ScriptedEngine(extractEvents: [
      TranscriptUpdated('BP 120 over 80'),
      ProposalEmitted(ProposedMeasurement(
        type: 'blood_pressure',
        value1: 120,
        value2: 80,
        unit: 'mmHg',
        sourceQuote: 'BP 120 over 80',
      )),
    ]);

    await tester.pumpWidget(harness(engine));
    await tester.pumpAndSettle();

    // Type a sentence — the Process button must enable as text changes.
    await tester.enterText(
        find.byType(TextField), 'Lola BP 120 over 80 kanina');
    await tester.pump();
    final process = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Process'));
    expect(process.onPressed, isNotNull,
        reason: 'Process must enable once text is entered');

    await tester.tap(find.widgetWithText(FilledButton, 'Process'));
    await tester.pumpAndSettle();

    // Review tray opens with the staged proposal.
    expect(find.byType(ReviewTrayScreen), findsOneWidget);
    expect(find.textContaining('Confirm all'), findsOneWidget);

    await tester.tap(find.textContaining('Confirm all'));
    await tester.pumpAndSettle();

    // Measurement persisted with ai_assisted provenance; proposal done.
    final now = DateTime.now();
    final measurements = await MeasurementRepositoryImpl(db).getForDateRange(
      recipientId,
      now.subtract(const Duration(days: 1)),
      now.add(const Duration(days: 1)),
    );
    expect(measurements.single.value1, 120);
    expect(measurements.single.value2, 80);
    expect(measurements.single.sourceType, 'ai_assisted');

    final captures = await db.select(db.aiCaptures).get();
    expect(captures.single.modality, 'text');
    expect(
        await captureRepo.getPendingProposals(captures.single.id), isEmpty);

    // Unmount inside the test and flush — Drift stream providers schedule
    // a zero-timer on dispose which would otherwise leak past teardown.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('Basic mode: deterministic extractor runs without an engine',
      (tester) async {
    // NullEngine-tier path: BasicTextExtractor handles the typed text.
    await tester.pumpWidget(harness(ScriptedEngine()));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byType(TextField), 'Lola BP 130 over 85 ngayong umaga');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Process'));
    await tester.pumpAndSettle();

    // ScriptedEngine yields no events → deterministic fallback still
    // stages a proposal → review tray shows it.
    expect(find.byType(ReviewTrayScreen), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
