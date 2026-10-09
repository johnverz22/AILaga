import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ailaga/core/database/app_database.dart';
import 'package:ailaga/core/database/database_provider.dart';
import 'package:ailaga/features/capture/presentation/review_tray_screen.dart';
import 'package:ailaga/services/ai/local/proposals/proposal_models.dart';
import 'package:ailaga/services/ai/local/proposals/proposal_repository.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Audit D/E: review tray must not overflow at 130%/200% font scale or on
/// small phones; helper confirm button must be >= 64dp; Sure/Check badges
/// must carry icon + word (never color alone).
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

  Future<List<StagedProposal>> seed() async {
    final captureId = await captureRepo.createCapture(
      careRecipientId: recipientId,
      modality: 'voice',
      originalText: 'Uminom ng amlodipine, BP 120/80',
      engineId: 'scripted',
      modelId: 'scripted',
      latencyMs: 1,
    );
    final records = <ProposedRecord>[
      ProposedMedicationTaken(
        medicationName: 'Amlodipine',
        sourceQuote: 'uminom ng amlodipine',
      ),
      ProposedMeasurement(
        type: 'blood_pressure',
        value1: 500,
        value2: 300,
        unit: 'mmHg',
        sourceQuote: 'BP 500/300',
        flag: ProposalFlag.check,
      ),
    ];
    final staged = <StagedProposal>[];
    for (final r in records) {
      final id =
          await captureRepo.createProposal(captureId: captureId, record: r);
      staged.add(StagedProposal(proposalId: id, record: r));
    }
    return staged;
  }

  Widget harness(List<StagedProposal> staged, double textScale) {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: ReviewTrayScreen(
            captureId: 'cap-1',
            careRecipientId: recipientId,
            heardText: 'Uminom ng amlodipine, BP 120/80',
            proposals: staged,
          ),
        ),
      ),
    );
  }

  final viewports = {
    '360x640': const Size(360, 640),
    '412x915': const Size(412, 915),
  };

  for (final vp in viewports.entries) {
    for (final scale in [1.0, 1.3, 2.0]) {
      testWidgets(
          'no overflow at ${vp.key} textScale $scale', (tester) async {
        tester.view.physicalSize = vp.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final staged = await seed();
        await tester.pumpWidget(harness(staged, scale));
        await tester.pumpAndSettle();

        // Any RenderFlex overflow/layout error surfaces as an exception.
        expect(tester.takeException(), isNull);
        expect(find.textContaining('Confirm all'), findsOneWidget);
      });
    }
  }

  testWidgets('confirm-all button is at least 64dp tall', (tester) async {
    final staged = await seed();
    await tester.pumpWidget(harness(staged, 1.0));
    await tester.pumpAndSettle();

    final button = find.widgetWithText(
        FilledButton, 'Confirm all (2)');
    expect(button, findsOneWidget);
    final size = tester.getSize(find.ancestor(
      of: find.textContaining('Confirm all'),
      matching: find.byType(SizedBox),
    ).first);
    expect(size.height, greaterThanOrEqualTo(64));
  });

  testWidgets('Sure and Check badges show icon + word', (tester) async {
    final staged = await seed();
    await tester.pumpWidget(harness(staged, 1.0));
    await tester.pumpAndSettle();

    expect(find.text('Sure'), findsOneWidget);
    expect(find.text('Check'), findsOneWidget);
    expect(find.byIcon(Symbols.check_circle_rounded), findsWidgets);
    expect(find.byIcon(Symbols.warning_amber_rounded), findsOneWidget);
  });
}
