import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// SECURITY NOTE:
// SharedPreferences is used here ONLY for non-sensitive boolean preferences
// (e.g. whether the user has enabled automatic cloud sync).
//
// It is explicitly NOT used for:
//   • Firebase UID                  → stored in flutter_secure_storage
//   • Last sync timestamp           → stored in flutter_secure_storage
//   • Any health data               → never leaves the local Drift DB
//   • Auth tokens or credentials    → managed by Firebase SDK
//
// SharedPreferences stores data in plaintext on-device. Only values that
// are safe to lose, reset, or expose without consequence belong here.
// ---------------------------------------------------------------------------

/// Preference keys — all prefixed with "sync_" to avoid collisions with
/// other parts of the app that might use SharedPreferences.
class _PrefKeys {
  static const syncEnabled = 'sync_enabled';
}

/// Thin wrapper around [SharedPreferences] for cloud sync preferences.
///
/// Used by [SyncPreferencesNotifier] — prefer reading from
/// [syncEnabledProvider] rather than calling this class directly.
class SyncPreferences {
  SyncPreferences(this._prefs);

  final SharedPreferences _prefs;

  /// Whether automatic cloud sync is enabled.
  /// Defaults to `true` when the user signs in for the first time.
  bool get syncEnabled => _prefs.getBool(_PrefKeys.syncEnabled) ?? true;

  Future<void> setSyncEnabled(bool value) =>
      _prefs.setBool(_PrefKeys.syncEnabled, value);
}

// ---------------------------------------------------------------------------
// Riverpod providers
// ---------------------------------------------------------------------------

/// Async provider that loads [SharedPreferences] once at startup.
///
/// Downstream providers consume [syncPreferencesProvider] synchronously
/// because [SharedPreferences] is loaded before the widget tree builds
/// (see `main.dart`).
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // SharedPreferences.getInstance() must be awaited before the app starts.
  // main.dart calls SharedPreferences.getInstance() and overrides this
  // provider with the resolved instance via ProviderScope overrides:
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   runApp(ProviderScope(
  //     overrides: [
  //       sharedPreferencesProvider.overrideWithValue(prefs),
  //     ],
  //     child: const AilagaApp(),
  //   ));
  //
  // Throwing here ensures a clear error if main.dart forgets the override.
  throw StateError(
    'sharedPreferencesProvider was not overridden in ProviderScope. '
    'Call SharedPreferences.getInstance() in main() and pass it as an override.',
  );
});

/// Provides [SyncPreferences] backed by [SharedPreferences].
final syncPreferencesProvider = Provider<SyncPreferences>((ref) {
  return SyncPreferences(ref.watch(sharedPreferencesProvider));
});

/// Whether automatic cloud sync is currently enabled.
///
/// Widgets should watch this provider to reactively show/hide the sync
/// toggle in Settings.
final syncEnabledProvider = Provider<bool>((ref) {
  return ref.watch(syncPreferencesProvider).syncEnabled;
});

/// Notifier for toggling automatic sync on/off.
///
/// Usage in UI:
///   ref.read(syncEnabledNotifierProvider.notifier).toggle();
class SyncEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(syncEnabledProvider);

  Future<void> toggle() async {
    final prefs = ref.read(syncPreferencesProvider);
    final next = !state;
    await prefs.setSyncEnabled(next);
    state = next;
  }

  Future<void> setEnabled(bool value) async {
    final prefs = ref.read(syncPreferencesProvider);
    await prefs.setSyncEnabled(value);
    state = value;
  }
}

final syncEnabledNotifierProvider =
    NotifierProvider<SyncEnabledNotifier, bool>(SyncEnabledNotifier.new);
