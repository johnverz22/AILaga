import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// App-wide error capture.
///
/// AILaga is offline-first with no accounts, so there is no crashlytics.
/// Instead, uncaught errors are appended to an on-device log file
/// (`<app documents>/logs/ailaga_errors.log`) that survives restarts and
/// can be pulled off the phone for debugging. Logging is strictly
/// best-effort: it must never throw or block startup.
class ErrorHandler {
  ErrorHandler._();

  /// Keep the log bounded — when it grows past this, the oldest half is
  /// dropped so a crash loop can't fill storage.
  static const int _maxLogBytes = 256 * 1024;

  static File? _logFile;

  /// Resolves the log file location. Call once at startup.
  static Future<void> init() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _logFile = File('${dir.path}/logs/ailaga_errors.log');
    } catch (_) {
      _logFile = null;
    }
  }

  /// Test hook: point the handler at a specific file (or disable with null).
  static void useFileForTesting(File? file) => _logFile = file;

  /// Entry point for [FlutterError.onError].
  static void recordFlutterError(FlutterErrorDetails details) {
    recordError(
      details.exception,
      details.stack ?? StackTrace.current,
      context: details.context?.toDescription(),
    );
  }

  /// Entry point for the [runZonedGuarded] zone handler and any
  /// catch-all sites that want the error persisted.
  static void recordError(Object error, StackTrace stack,
      {String? context}) {
    if (kDebugMode) {
      debugPrint(
          'Error${context != null ? ' ($context)' : ''}: $error\n$stack');
    }
    unawaited(_append(
      '=== ${DateTime.now().toIso8601String()} ===\n'
      '${context != null ? 'context: $context\n' : ''}'
      '$error\n$stack\n',
    ));
  }

  static Future<void> _append(String entry) async {
    final file = _logFile;
    if (file == null) return;
    try {
      await file.parent.create(recursive: true);
      if (await file.exists() && await file.length() > _maxLogBytes) {
        final bytes = await file.readAsBytes();
        await file.writeAsBytes(
          bytes.sublist(bytes.length - _maxLogBytes ~/ 2),
          flush: true,
        );
      }
      await file.writeAsString(entry, mode: FileMode.append, flush: true);
    } catch (_) {
      // Error logging must never throw.
    }
  }
}
