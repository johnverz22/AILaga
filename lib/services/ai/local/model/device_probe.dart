import 'package:flutter/services.dart';

import '../local_ai_engine.dart';
import 'ai_thresholds.dart';

/// Raw device capabilities relevant to local-AI feasibility.
class DeviceCapabilities {
  /// Total RAM in MiB (Android ActivityManager.MemoryInfo.totalMem /
  /// iOS ProcessInfo.physicalMemory).
  final int? ramMb;

  /// Android SDK int (e.g. 34); iOS major version (e.g. 26). Null off-platform.
  final int? sdkInt;

  /// Supported ABIs (e.g. arm64-v8a). iOS reports ['arm64'].
  final List<String> abis;

  /// Free bytes on the app's storage volume.
  final int? freeStorageBytes;

  /// 'android' | 'ios' | null (unreported → treated as Android legacy).
  final String? platform;

  const DeviceCapabilities({
    this.ramMb,
    this.sdkInt,
    this.abis = const [],
    this.freeStorageBytes,
    this.platform,
  });

  static const DeviceCapabilities unknown = DeviceCapabilities();
}

/// Machine-readable reasons for a tier decision. The UI maps these to plain
/// words — never shown raw to the user.
enum TierReason {
  unknownDevice, // probe failed or off-platform
  sdkTooOld, // below AiThresholds.minSdkForLiteRt
  unsupportedCpu, // no arm64-v8a ABI (e.g. x86 emulator)
  lowStorage, // not enough free space for the model
  lowRam, // below the Lite threshold
  ramLite, // enough for Lite, not Full
  ramFull, // enough for Full
}

/// The tier plus why — so Settings can explain the decision in plain words.
class TierDecision {
  final AiTier tier;
  final List<TierReason> reasons;
  const TierDecision(this.tier, this.reasons);
}

/// Signature of the raw platform probe (injectable for tests).
typedef PlatformDeviceInfo = Future<Map<Object?, Object?>?> Function();

/// Probes RAM/ABI/SDK/free-space through the Kotlin device channel and maps
/// the result to an [AiTier].
///
/// Design rules (audit B):
/// - Async + defensive: every platform call is try/caught; any failure maps
///   to [DeviceCapabilities.unknown] → Basic. The probe can never crash the
///   app or block SOS/Basic behavior.
/// - Deterministic + testable: the platform call is injectable.
/// - Explainable: [decide] returns reason codes alongside the tier.
/// - Thresholds live in ONE file ([AiThresholds]) tied to SPIKE_RESULTS.md.
class DeviceProbe {
  static const MethodChannel _channel =
      MethodChannel('com.ailaga.ailaga/device');

  final PlatformDeviceInfo _platformInfo;

  DeviceProbe({PlatformDeviceInfo? platformInfo})
      : _platformInfo = platformInfo ?? _channelInfo;

  static Future<Map<Object?, Object?>?> _channelInfo() =>
      _channel.invokeMethod<Map<Object?, Object?>>('getDeviceInfo');

  Future<DeviceCapabilities> capabilities() async {
    try {
      final result = await _platformInfo();
      if (result == null) return DeviceCapabilities.unknown;
      return DeviceCapabilities(
        ramMb: (result['ramMb'] as num?)?.toInt(),
        sdkInt: (result['sdkInt'] as num?)?.toInt(),
        abis:
            (result['abis'] as List?)?.map((e) => e.toString()).toList() ??
                const [],
        freeStorageBytes: (result['freeStorageBytes'] as num?)?.toInt(),
        platform: result['platform']?.toString(),
      );
    } catch (_) {
      // PlatformException, MissingPluginException (iOS/tests), bad casts —
      // all land here. Unknown device → Basic, never a crash.
      return DeviceCapabilities.unknown;
    }
  }

  Future<TierDecision> decideTier() async => decide(await capabilities());

  /// Pure tier mapping — conservative: unknown or under-provisioned devices
  /// fall back to Basic mode, which always works.
  static TierDecision decide(DeviceCapabilities caps) {
    final reasons = <TierReason>[];
    final ram = caps.ramMb;
    final sdk = caps.sdkInt;

    if (ram == null || sdk == null) {
      return const TierDecision(AiTier.basic, [TierReason.unknownDevice]);
    }
    // Android-only gates: sdkInt is an Android API level and abis is an
    // Android ABI list. On iOS these fields carry different meanings
    // (iOS major version, always arm64) — Apple Intelligence availability
    // is checked separately via the apple_ai channel.
    if (caps.platform != 'ios') {
      if (sdk < AiThresholds.minSdkForLiteRt) {
        reasons.add(TierReason.sdkTooOld);
      }
      if (caps.abis.isNotEmpty &&
          !caps.abis.contains(AiThresholds.requiredAbi)) {
        reasons.add(TierReason.unsupportedCpu);
      }
    }
    final free = caps.freeStorageBytes;
    if (free != null && free < AiThresholds.minFreeBytesForModel) {
      reasons.add(TierReason.lowStorage);
    }
    if (ram < AiThresholds.liteTierMinRamMb) {
      reasons.add(TierReason.lowRam);
    }
    if (reasons.isNotEmpty) {
      return TierDecision(AiTier.basic, reasons);
    }
    return ram >= AiThresholds.fullTierMinRamMb
        ? const TierDecision(AiTier.full, [TierReason.ramFull])
        : const TierDecision(AiTier.lite, [TierReason.ramLite]);
  }

  // ---------------------------------------------------------------------
  // Static compatibility API (existing call sites/tests)
  // ---------------------------------------------------------------------

  static Future<DeviceCapabilities> probe() => DeviceProbe().capabilities();

  static AiTier tierFor(DeviceCapabilities caps) => decide(caps).tier;

  static Future<AiTier> probeTier() async => tierFor(await probe());
}
