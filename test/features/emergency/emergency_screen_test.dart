import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ailaga/app/theme.dart';
import 'package:ailaga/core/database/app_database.dart';
import 'package:ailaga/core/database/database_provider.dart';
import 'package:ailaga/features/emergency/presentation/emergency_screen.dart';

/// Regression: the SOS screen hardcoded the light cream palette while its
/// text used theme colors — in dark mode white text landed on a cream
/// panel and was unreadable. The screen must render correctly in both
/// themes with no overflow.
void main() {
  late AppDatabase db;

  const recipientId = 'cr-1';

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final now = DateTime.now();
    await db.into(db.careRecipients).insert(CareRecipientsCompanion.insert(
          id: recipientId,
          displayName: 'Lola',
          createdAt: now,
          updatedAt: now,
        ));
    await db.into(db.familyContacts).insert(FamilyContactsCompanion.insert(
          id: 'fc-1',
          careRecipientId: recipientId,
          displayName: 'Ana',
          relationship: const Value('Daughter'),
          phoneNumber: '09171234567',
          isEmergencyContact: const Value(true),
          createdAt: now,
          updatedAt: now,
        ));
  });

  tearDown(() => db.close());

  Widget harness(ThemeData theme) {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(theme: theme, home: const EmergencyScreen()),
    );
  }

  for (final (label, theme) in [('light', appTheme), ('dark', darkAppTheme)]) {
    testWidgets('SOS screen renders contacts readably in $label mode',
        (tester) async {
      await tester.pumpWidget(harness(theme));
      await tester.pumpAndSettle();

      expect(find.text('Emergency SOS'), findsOneWidget);
      expect(find.text('SOS'), findsOneWidget);
      expect(find.text('Lola'), findsOneWidget);
      expect(find.text('Call family'), findsOneWidget);
      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('Daughter'), findsOneWidget);
      expect(find.text('Call'), findsOneWidget);
      expect(find.text('Text'), findsOneWidget);
      // A RenderFlex overflow reports as an exception during pump.
      expect(tester.takeException(), isNull);

      // Flush Drift stream-provider zero-timers before teardown.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 1));
    });
  }
}
