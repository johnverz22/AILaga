/// Single source of truth for device-tier thresholds.
///
/// ⚠ STATUS: PLACEHOLDERS. Every value here must be re-derived from real
/// measurements recorded in `docs/SPIKE_RESULTS.md` (spike S4: RAM, speed,
/// heat, cold-load, OOM) before any of these numbers is treated as final
/// or shown to a user. Until S4 runs, these are conservative guesses whose
/// only job is to fail safe: unknown or under-provisioned → Basic mode.
library;

class AiThresholds {
  AiThresholds._();

  /// flutter_gemma LiteRT requires Android SDK 30+ (plugin docs; see
  /// LOCAL_AI_UX_SPEC.md §2). Runtime gate — app minSdk stays 26 because
  /// Basic mode works everywhere.
  static const int minSdkForLiteRt = 30;

  /// LiteRT-LM ships arm64 natives; emulators/x86 devices get Basic mode.
  static const String requiredAbi = 'arm64-v8a';

  /// PLACEHOLDER pending S4 — total RAM needed for the Full tier (~6 GB).
  static const int fullTierMinRamMb = 6144;

  /// PLACEHOLDER pending S4 — total RAM needed for the Lite tier (~4 GB).
  static const int liteTierMinRamMb = 4096;

  /// PLACEHOLDER pending S4/S6 — free storage needed to hold the model
  /// (~3 GB; real model size must come from the server/file, never here).
  static const int minFreeBytesForModel = 3 * 1024 * 1024 * 1024;
}
