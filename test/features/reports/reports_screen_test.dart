import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ailaga/features/reports/presentation/reports_screen.dart';

/// Regression: the date-range selector row overflowed horizontally on
/// narrow screens (RenderFlex overflow at ~379px) because the long
/// "start - end" label competed with the Custom Range button and the
/// calendar menu for fixed width.
void main() {
  Widget harness() {
    return ProviderScope(
      // Skip real PDF generation — the selector renders regardless.
      overrides: [
        reportProvider.overrideWith((ref) => Future<Uint8List?>.value())
      ],
      child: MaterialApp(
        home: Center(
          // Constrain to the narrow width that produced the overflow.
          child: SizedBox(width: 380, child: const ReportsScreen()),
        ),
      ),
    );
  }

  testWidgets('date range selector does not overflow at 380px wide',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    expect(find.text('Custom Range'), findsOneWidget);
    // A RenderFlex overflow reports as an exception during pump.
    expect(tester.takeException(), isNull);
  });
}
