/// Single source of truth for device-tier thresholds.
///
/// ⚠ PARTIAL UPDATE: Values marked PLACEHOLDER still need real measurements
/// from spike S4 (RAM, speed, heat, cold-load, OOM) before the numbers can
/// be considered final.  Values marked CONFIRMED come from the HuggingFace
/// model card (SPIKE_RESULTS.md S6 row) and are safe to rely on.
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

  /// CONFIRMED from HuggingFace (2026-10) — minimum free storage required
  /// to hold the default model file.
  ///
  /// Default model: gemma-4-E2B-it-gpu.litertlm = 2.01 GB on disk.
  ///   2.01 GB = 2 157 000 000 bytes ≈ 2.01 × 1 073 741 824 = 2 158 170 889 B
  ///
  /// We add 10 % headroom for the partial (.part) file that co-exists during
  /// download → floor at 2.2 GB (2 362 232 012 bytes).
  ///
  /// NPU-specific files are larger:
  ///   sm8750   → 3.02 GB  — needs ~3.33 GB free (10 % headroom)
  ///   G5       → 3.11 GB  — needs ~3.43 GB free
  ///   G6       → 3.31 GB  — needs ~3.65 GB free
  ///
  /// The free-space check in ModelManager uses the actual Content-Length from
  /// the server, NOT this constant.  This constant is only the preliminary
  /// gate in DeviceProbe that prevents showing the download button on a device
  /// that clearly has no room for even the smallest variant.
  static const int minFreeBytesForModel = 2200 * 1024 * 1024; // 2.2 GB

  // -----------------------------------------------------------------------
  // Reference sizes (CONFIRMED, HuggingFace 2026-10).
  // These are for documentation/display only — never use them as the actual
  // download size.  ModelManager reads the real size from Content-Length.
  // -----------------------------------------------------------------------

  /// gpu-optimised file — default model.  2.01 GB on disk.
  static const int gpuModelApproxBytes = 2157000000;

  /// Qualcomm SM8750 NPU file.  3.02 GB on disk.
  static const int sm8750ModelApproxBytes = 3241000000;

  /// Google Tensor G5 NPU file.  3.11 GB on disk.
  static const int tensorG5ModelApproxBytes = 3338000000;

  /// Google Tensor G6 NPU file.  3.31 GB on disk.
  static const int tensorG6ModelApproxBytes = 3553000000;
}
