import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../../core/database/database_provider.dart';

/// Key-value persistence backed by the [AppSettings] Drift table.
///
/// Used for hardware feature toggles (shake-to-SOS, fall detection)
/// and other small flags that don't warrant their own table.
class AppSettingsService {
  final AppDatabase _db;

  AppSettingsService(this._db);

  static const keyShakeSos = 'hw_shake_sos';
  static const keyFallDetection = 'hw_fall_detection';

  Future<String?> get(String key) async {
    final row = await (_db.select(_db.appSettings)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> set(String key, String value) {
    return _db.into(_db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion(
            key: Value(key),
            value: Value(value),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
  }

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final v = await get(key);
    if (v == null) return defaultValue;
    return v == 'true';
  }

  Future<void> setBool(String key, bool value) => set(key, '$value');
}

final appSettingsServiceProvider = Provider<AppSettingsService>((ref) {
  return AppSettingsService(ref.watch(appDatabaseProvider));
});

/// Whether shake-to-SOS is enabled. Default: on — this is the primary
/// hardware shortcut for elders.
final shakeSosEnabledProvider = FutureProvider<bool>((ref) {
  return ref
      .watch(appSettingsServiceProvider)
      .getBool(AppSettingsService.keyShakeSos, defaultValue: true);
});

/// Whether accelerometer fall detection is enabled. Default: off —
/// it can produce false alarms, so the caregiver opts in.
final fallDetectionEnabledProvider = FutureProvider<bool>((ref) {
  return ref
      .watch(appSettingsServiceProvider)
      .getBool(AppSettingsService.keyFallDetection);
});
