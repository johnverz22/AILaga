import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/database/database_provider.dart';
import 'core/notifications/notification_provider.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Set up global error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      // TODO: Log error to a file or crashlytics
      debugPrint('Flutter Error: ${details.exception}');
    };

    // We can pre-initialize services by creating a ProviderContainer, 
    // initializing what's needed, and passing it to ProviderScope.
    final container = ProviderContainer();
    
    // Initialize database (reading it forces creation)
    container.read(appDatabaseProvider);
    
    // Initialize notifications (assuming we might need an init method later)
    final notificationService = container.read(notificationServiceProvider);
    // await notificationService.init(); // To be implemented in the future

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const AilagaApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('Async Error: $error');
  });
}
