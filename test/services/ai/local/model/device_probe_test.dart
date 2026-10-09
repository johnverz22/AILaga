import 'package:flutter_test/flutter_test.dart';
import 'package:ailaga/services/ai/local/model/device_probe.dart';
import 'package:ailaga/services/ai/local/local_ai_engine.dart';

void main() {
  group('DeviceProbe.tierFor', () {
    test('unknown capabilities → basic', () {
      expect(DeviceProbe.tierFor(DeviceCapabilities.unknown), AiTier.basic);
    });

    test('missing RAM or SDK → basic', () {
      expect(
        DeviceProbe.tierFor(const DeviceCapabilities(sdkInt: 34)),
        AiTier.basic,
      );
      expect(
        DeviceProbe.tierFor(const DeviceCapabilities(ramMb: 8192)),
        AiTier.basic,
      );
    });

    test('old SDK → basic regardless of RAM', () {
      expect(
        DeviceProbe.tierFor(const DeviceCapabilities(ramMb: 8192, sdkInt: 28)),
        AiTier.basic,
      );
    });

    test('low free storage → basic', () {
      expect(
        DeviceProbe.tierFor(const DeviceCapabilities(
          ramMb: 8192,
          sdkInt: 34,
          freeStorageBytes: 1024,
        )),
        AiTier.basic,
      );
    });

    test('4 GB RAM → lite', () {
      expect(
        DeviceProbe.tierFor(const DeviceCapabilities(ramMb: 4096, sdkInt: 34)),
        AiTier.lite,
      );
    });

    test('6+ GB RAM → full', () {
      expect(
        DeviceProbe.tierFor(const DeviceCapabilities(ramMb: 6144, sdkInt: 34)),
        AiTier.full,
      );
    });

    test('under 4 GB → basic', () {
      expect(
        DeviceProbe.tierFor(const DeviceCapabilities(ramMb: 3072, sdkInt: 34)),
        AiTier.basic,
      );
    });
  });
}
