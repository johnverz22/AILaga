import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/database/database_provider.dart';
import 'core/errors/error_handler.dart';
import 'core/notifications/notification_provider.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
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
