import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_provider.dart';
import 'sync_models.dart';
import 'sync_service.dart';
import 'supabase_sync_service.dart';

/// Singleton [SyncService] backed by Supabase.
///
/// Depends on [appDatabaseProvider] so the Drift DB is always initialized
/// before the sync service uses it.
///
/// Override in tests with a mock [SyncService]:
///   ProviderContainer(overrides: [
///     syncServiceProvider.overrideWithValue(MockSyncService()),
///   ])
final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SupabaseSyncService(db: db);
});

/// Real-time stream of [SyncStatus] for driving UI sync indicators.
///
/// This is a [StreamProvider] so widgets can watch it with full
/// [AsyncValue] handling (loading / data / error states).
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  return ref.watch(syncServiceProvider).statusStream;
});

/// The UTC timestamp of the last successful sync, loaded once at startup.
///
/// Returns `null` if no sync has ever run. Refresh with [ref.invalidate] after
/// a successful sync if you want the UI to update.
final lastSyncTimeProvider = FutureProvider<DateTime?>((ref) {
  return ref.watch(syncServiceProvider).getLastSyncTime();
});
