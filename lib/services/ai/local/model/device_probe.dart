import 'package:flutter/services.dart';

import '../local_ai_engine.dart';

/// Raw device capabilities relevant to local-AI feasibility.
class DeviceCapabilities {
  /// Total RAM in MiB (Android ActivityManager.MemoryInfo.totalMem).
  final int? ramMb;

  /// Android SDK int (e.g. 34). Null off-platform.
  final int? sdkInt;

  /// Supported ABIs (e.g. arm64-v8a).
  final List<String> abis;

  /// Free bytes on the app's storage volume.
  final int? freeStorageBytes;

  const DeviceCapabilities({
    this.ramMb,
    this.sdkInt,
    this.abis = const [],
    this.freeStorageBytes,
  });

  static const DeviceCapabilities unknown = DeviceCapabilities();
}

/// Probes RAM/ABI/SDK/free-space through the Kotlin device channel.
/// Off-platform or channel failure → [DeviceCapabilities.unknown] → basic tier.
class DeviceProbe {
  static const MethodChannel _channel =
      MethodChannel('com.ailaga.ailaga/device');

  static Future<DeviceCapabilities> probe() async {
    try {
      final result =
          await _channel.invokeMethod<Map<Object?, Object?>>('getDeviceInfo');
      if (result == null) return DeviceCapabilities.unknown;
      return DeviceCapabilities(
        ramMb: (result['ramMb'] as num?)?.toInt(),
        sdkInt: (result['sdkInt'] as num?)?.toInt(),
        abis: (result['abis'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        freeStorageBytes: (result['freeStorageBytes'] as num?)?.toInt(),
      );
    } on PlatformException {
      return DeviceCapabilities.unknown;
    } on MissingPluginException {
      return DeviceCapabilities.unknown;
    }
  }

  // -------------------------------------------------------------------------
  // Tier thresholds — PLACEHOLDERS pending Spike S4 measurements.
  // These must be re-derived from real numbers recorded in
  // docs/SPIKE_RESULTS.md before ship; do not present as final.
  // -------------------------------------------------------------------------
  static const int _minSdkForLiteRt = 30; // flutter_gemma LiteRT requirement
  static const int _fullTierMinRamMb = 6144; // ~6 GB — placeholder for S4
  static const int _liteTierMinRamMb = 4096; // ~4 GB — placeholder for S4
  static const int _minFreeBytesForModel = 3 * 1024 * 1024 * 1024; // ~3 GB

  /// Maps capabilities to an [AiTier]. Conservative: unknown or
  /// under-provisioned devices fall back to Basic mode, which always works.
  static AiTier tierFor(DeviceCapabilities caps) {
    final ram = caps.ramMb;
    final sdk = caps.sdkInt;
    if (ram == null || sdk == null) return AiTier.basic;
    if (sdk < _minSdkForLiteRt) return AiTier.basic;
    final free = caps.freeStorageBytes;
    if (free != null && free < _minFreeBytesForModel) return AiTier.basic;
    if (ram >= _fullTierMinRamMb) return AiTier.full;
    if (ram >= _liteTierMinRamMb) return AiTier.lite;
    return AiTier.basic;
  }

  static Future<AiTier> probeTier() async => tierFor(await probe());
}
