import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma_litertlm/flutter_gemma_litertlm.dart';
import 'app/app.dart';
import 'core/database/database_provider.dart';
import 'core/errors/error_handler.dart';
import 'core/notifications/notification_provider.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Offline-first, no crashlytics: persist uncaught errors to an
    // on-device log file so they can be pulled for debugging.
    await ErrorHandler.init();

    // Initialize FlutterGemma once at startup (required by flutter_gemma 1.11.3
    // — must be called before runApp, not lazily inside engine methods).
    // Wrap in try/catch: on simulators or platforms without LiteRT support the
    // call throws, but NullEngine handles the graceful fallback.
    try {
      await FlutterGemma.initialize(inferenceEngines: [LiteRtLmEngine()]);
    } catch (_) {
      // Ignore — DeviceProbe / NullEngine provides the fallback path.
    }

    // Set up global error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      ErrorHandler.recordFlutterError(details);
    };

    // We can pre-initialize services by creating a ProviderContainer,
    // initializing what's needed, and passing it to ProviderScope.
    final container = ProviderContainer();

    // Initialize database (reading it forces creation)
    container.read(appDatabaseProvider);

    // Initialize notifications (reading the provider constructs the service;
    // a real init hook can be added later).
    container.read(notificationServiceProvider);

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const AilagaApp(),
      ),
    );
  }, (error, stack) {
    ErrorHandler.recordError(error, stack);
  });
}
