import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/database/database_provider.dart';
import 'core/notifications/notification_provider.dart';
import 'firebase_options.dart';

// SECURITY NOTE: The Supabase anon key is intentionally included in source.
// Security is enforced by Row-Level Security (RLS) policies on all tables —
// the key alone cannot access any user's data without a valid Firebase JWT.
const _supabaseUrl = 'https://sgistmejqsbssutscbda.supabase.co';
const _supabaseAnonKey = 'sb_publishable_iFKfTlTpn1FfQtQbhsH7jA_Kea8UJOW';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Set up global error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Flutter Error: ${details.exception}');
    };

    // ---------------------------------------------------------------------------
    // Firebase initialization — Auth only. Health data is NEVER sent to Firebase.
    // Failure is non-fatal: the app continues in fully offline mode.
    // ---------------------------------------------------------------------------
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('[D] Firebase initialized');
    } catch (e) {
      // Network unavailable or misconfiguration — continue offline.
      debugPrint('[D] Firebase init failed (offline mode): $e');
    }

    // ---------------------------------------------------------------------------
    // Supabase initialization — remote DB + sync target.
    // Failure is non-fatal: sync features are disabled, local DB still works.
    // ---------------------------------------------------------------------------
    try {
      await Supabase.initialize(
        url: _supabaseUrl,
        // supabase_flutter ^2.7 resolves publishableKey as the preferred param.
        // The value is the Supabase "anon/publishable" key — safe in source.
        // ignore: deprecated_member_use
        anonKey: _supabaseAnonKey,
      );
      debugPrint('[D] Supabase initialized');
    } catch (e) {
      debugPrint('[D] Supabase init failed (offline mode): $e');
    }

    // ---------------------------------------------------------------------------
    // Local infrastructure — Drift DB + notifications
    // ---------------------------------------------------------------------------
    final container = ProviderContainer();

    // Initialize database (reading it forces creation)
    container.read(appDatabaseProvider);

    // Initialize notification service
    container.read(notificationServiceProvider);

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const AilagaApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('Async Error: $error\n$stack');
  });
}
