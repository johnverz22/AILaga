import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/auth/auth_providers.dart';
import 'sync_providers.dart';

/// Duration that must elapse between automatic foreground syncs.
const _kAutoSyncThrottle = Duration(minutes: 5);

/// Debounce delay after a write before triggering an incremental sync.
const _kWriteDebounce = Duration(seconds: 10);

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

/// Manages automatic sync triggers — foreground throttle, write debounce,
/// and the "Sync Now" manual path.
///
/// Lifecycle:
///   1. Call [attachLifecycle] from a widget that spans the app lifetime
///      (e.g. [AilagaApp] or a top-level [ConsumerWidget]).
///   2. Call [onWriteCompleted] from any repository after a successful write.
///   3. The service reads [currentUidProvider] and [syncServiceProvider]
///      through the [WidgetRef] it is constructed with.
///
/// Safety contract:
///   - Sync is silently skipped when the user is not signed in.
///   - Background sync errors are logged but never surface to the user.
///   - [SyncNow] is the only path that returns a result to the caller.
class SyncTriggerService with WidgetsBindingObserver {
  SyncTriggerService(this._ref);

  final WidgetRef _ref;

  DateTime? _lastAutoSync;
  Timer? _debounceTimer;
  bool _lifecycleAttached = false;

  // ---------------------------------------------------------------------------
  // Lifecycle attachment — call once from the root widget
  // ---------------------------------------------------------------------------

  void attachLifecycle() {
    if (_lifecycleAttached) return;
    WidgetsBinding.instance.addObserver(this);
    _lifecycleAttached = true;
  }

  void detachLifecycle() {
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    _lifecycleAttached = false;
  }

  // ---------------------------------------------------------------------------
  // AppLifecycleObserver — auto-sync on foreground
  // ---------------------------------------------------------------------------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _maybeTriggerAutoSync();
    }
  }

  void _maybeTriggerAutoSync() {
    final uid = _ref.read(currentUidProvider);
    if (uid == null) return; // Not signed in — skip.

    final now = DateTime.now();
    if (_lastAutoSync != null &&
        now.difference(_lastAutoSync!) < _kAutoSyncThrottle) {
      return; // Throttled — last auto-sync was less than 5 minutes ago.
    }

    _lastAutoSync = now;
    _backgroundSync(uid);
  }

  // ---------------------------------------------------------------------------
  // Write debounce — call after any successful local write
  // ---------------------------------------------------------------------------

  /// Schedules a debounced incremental sync for [tableName].
  ///
  /// If multiple writes happen within [_kWriteDebounce], only one sync fires.
  /// Silent no-op when the user is not signed in.
  void onWriteCompleted(String tableName) {
    final uid = _ref.read(currentUidProvider);
    if (uid == null) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_kWriteDebounce, () {
      _backgroundTableSync(tableName, uid);
    });
  }

  // ---------------------------------------------------------------------------
  // Manual "Sync Now" — returns the result to the caller for UI feedback
  // ---------------------------------------------------------------------------

  Future<void> syncNow() async {
    final uid = _ref.read(currentUidProvider);
    if (uid == null) return;

    final service = _ref.read(syncServiceProvider);
    await service.syncAll(uid);
    // Reset the auto-sync timer so a manual sync counts as the last sync.
    _lastAutoSync = DateTime.now();
  }

  // ---------------------------------------------------------------------------
  // Background helpers — errors are silently logged
  // ---------------------------------------------------------------------------

  void _backgroundSync(String uid) {
    final service = _ref.read(syncServiceProvider);
    service.syncAll(uid).then(
          (result) => debugPrint('[D] SyncTrigger: auto-sync done — $result'),
          onError: (e) =>
              debugPrint('[D] SyncTrigger: auto-sync error (silent) — $e'),
        );
  }

  void _backgroundTableSync(String tableName, String uid) {
    final service = _ref.read(syncServiceProvider);
    service.syncTable(tableName, uid).then(
          (_) => debugPrint('[D] SyncTrigger: table sync done — $tableName'),
          onError: (e) =>
              debugPrint('[D] SyncTrigger: table sync error (silent) — $e'),
        );
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

/// Provider for [SyncTriggerService].
///
/// This provider intentionally does NOT auto-attach the lifecycle observer —
/// call [SyncTriggerService.attachLifecycle] from a widget that has a
/// [WidgetRef] (e.g. the root [ConsumerWidget]).
final syncTriggerServiceProvider = Provider<SyncTriggerService>((ref) {
  // SyncTriggerService needs a WidgetRef to read providers at call time
  // (not at construction time), so it holds the ref directly.
  // This is safe because providers created with Provider<T> are singletons
  // scoped to the ProviderContainer lifetime.
  //
  // NOTE: WidgetRef is not available inside a plain Provider — call-site
  // code that needs SyncTriggerService must obtain it via ConsumerWidget
  // or Consumer and pass the ref at construction if lifecycle attachment
  // is needed. For simpler cases (syncNow, onWriteCompleted), the service
  // can be called directly from widget context.
  //
  // The provider is a no-arg factory here; construction with a real WidgetRef
  // happens at the call site when lifecycle attachment is needed.
  throw UnimplementedError(
    'SyncTriggerService requires a WidgetRef. '
    'Instantiate it directly in a ConsumerStatefulWidget:\n'
    '  late final _syncTrigger = SyncTriggerService(ref);\n'
    '  @override void initState() { _syncTrigger.attachLifecycle(); }',
  );
});
