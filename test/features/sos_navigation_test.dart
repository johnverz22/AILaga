import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ailaga/features/ask/presentation/ask_screen.dart';
import 'package:ailaga/features/capture/presentation/voice_capture_screen.dart';

/// Invariant 2 regression: the SOS button must navigate on every screen.
/// The app uses GoRouter; Navigator.pushNamed('/emergency') throws under
/// MaterialApp.router (no route generator) — SOS silently dead.
void main() {
  Widget harness(Widget screen) {
    final router = GoRouter(
      initialLocation: '/under-test',
      routes: [
        GoRoute(path: '/under-test', builder: (_, __) => screen),
        GoRoute(
          path: '/emergency',
          builder: (_, __) =>
              const Scaffold(body: Text('EMERGENCY_SCREEN_STUB')),
        ),
        GoRoute(
          path: '/capture/snap',
          builder: (_, __) => const Scaffold(body: Text('SNAP_STUB')),
        ),
      ],
    );
    return ProviderScope(
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('SOS on Ask screen reaches the emergency route', (tester) async {
    await tester.pumpWidget(harness(const AskScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('SOS'));
    await tester.pumpAndSettle();

    expect(find.text('EMERGENCY_SCREEN_STUB'), findsOneWidget);
  });

  testWidgets('SOS on Voice capture screen reaches the emergency route',
      (tester) async {
    await tester.pumpWidget(harness(const VoiceCaptureScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('SOS'));
    await tester.pumpAndSettle();

    expect(find.text('EMERGENCY_SCREEN_STUB'), findsOneWidget);
  });
}
