import 'package:flutter_test/flutter_test.dart';
import 'package:ailaga/services/ai/local/model/device_probe.dart';
import 'package:ailaga/services/ai/local/local_ai_engine.dart';

void main() {
  group('DeviceProbe.decide — table-driven (thresholds: ai_thresholds.dart, '
      'placeholders pending SPIKE_RESULTS.md S4)', () {
    const arm = ['arm64-v8a', 'armeabi-v7a'];

    final cases = <String, (DeviceCapabilities, AiTier, TierReason)>{
      'unknown capabilities → basic': (
        DeviceCapabilities.unknown,
        AiTier.basic,
        TierReason.unknownDevice,
      ),
      'missing RAM → basic': (
        const DeviceCapabilities(sdkInt: 34, abis: arm),
        AiTier.basic,
        TierReason.unknownDevice,
      ),
      'missing SDK → basic': (
        const DeviceCapabilities(ramMb: 8192, abis: arm),
        AiTier.basic,
        TierReason.unknownDevice,
      ),
      'old SDK (28) → basic regardless of RAM': (
        const DeviceCapabilities(ramMb: 8192, sdkInt: 28, abis: arm),
        AiTier.basic,
        TierReason.sdkTooOld,
      ),
      'x86_64 emulator → basic (no arm64 natives)': (
        const DeviceCapabilities(
            ramMb: 8192, sdkInt: 34, abis: ['x86_64', 'x86']),
        AiTier.basic,
        TierReason.unsupportedCpu,
      ),
      'low free storage → basic': (
        const DeviceCapabilities(
            ramMb: 8192, sdkInt: 34, abis: arm, freeStorageBytes: 1024),
        AiTier.basic,
        TierReason.lowStorage,
      ),
      'low RAM (3 GB) → basic': (
        const DeviceCapabilities(ramMb: 3072, sdkInt: 34, abis: arm),
        AiTier.basic,
        TierReason.lowRam,
      ),
      '4 GB RAM → lite': (
        const DeviceCapabilities(ramMb: 4096, sdkInt: 34, abis: arm),
        AiTier.lite,
        TierReason.ramLite,
      ),
      '6+ GB RAM → full': (
        const DeviceCapabilities(ramMb: 6144, sdkInt: 34, abis: arm),
        AiTier.full,
        TierReason.ramFull,
      ),
      'high-end (12 GB, SDK 36) → full': (
        const DeviceCapabilities(
            ramMb: 12288,
            sdkInt: 36,
            abis: arm,
            freeStorageBytes: 64 * 1024 * 1024 * 1024),
        AiTier.full,
        TierReason.ramFull,
      ),
      'empty ABI list is tolerated (older devices) → RAM decides': (
        const DeviceCapabilities(ramMb: 6144, sdkInt: 34),
        AiTier.full,
        TierReason.ramFull,
      ),
    };

    cases.forEach((name, c) {
      test(name, () {
        final (caps, tier, reason) = c;
        final decision = DeviceProbe.decide(caps);
        expect(decision.tier, tier);
        expect(decision.reasons, contains(reason),
            reason: 'decision must carry an explainable reason code');
      });
    });

    test('multiple failures report all reasons', () {
      final d = DeviceProbe.decide(const DeviceCapabilities(
          ramMb: 2048, sdkInt: 26, abis: ['x86'], freeStorageBytes: 0));
      expect(d.tier, AiTier.basic);
      expect(
          d.reasons,
          containsAll([
            TierReason.sdkTooOld,
            TierReason.unsupportedCpu,
            TierReason.lowStorage,
            TierReason.lowRam,
          ]));
    });
  });

  group('DeviceProbe.capabilities — defensive platform handling', () {
    test('platform exception → unknown → basic', () async {
      final probe = DeviceProbe(
          platformInfo: () async => throw Exception('channel died'));
      final caps = await probe.capabilities();
      expect(caps.ramMb, isNull);
      expect(DeviceProbe.decide(caps).tier, AiTier.basic);
    });

    test('null platform result → unknown → basic', () async {
      final probe = DeviceProbe(platformInfo: () async => null);
      expect((await probe.decideTier()).tier, AiTier.basic);
    });

    test('malformed map values → unknown → basic (no crash)', () async {
      final probe = DeviceProbe(
          platformInfo: () async => {'ramMb': 'lots', 'abis': 42});
      final decision = await probe.decideTier();
      expect(decision.tier, AiTier.basic);
    });

    test('well-formed map parses into capabilities', () async {
      final probe = DeviceProbe(platformInfo: () async => {
            'ramMb': 8192,
            'sdkInt': 34,
            'abis': ['arm64-v8a'],
            'freeStorageBytes': 50 * 1024 * 1024 * 1024,
          });
      final decision = await probe.decideTier();
      expect(decision.tier, AiTier.full);
    });

    test('missing channel (iOS / tests) → basic', () async {
      // Default channel probe in a test environment has no handler.
      final caps = await DeviceProbe().capabilities();
      expect(DeviceProbe.decide(caps).tier, AiTier.basic);
    });
  });
}
