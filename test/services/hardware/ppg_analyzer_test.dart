import 'dart:math' as math;

import 'package:ailaga/services/hardware/ppg_analyzer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PpgAnalyzer', () {
    PpgAnalyzer feedSine({required double hz, int durationMs = 15000}) {
      final a = PpgAnalyzer();
      // ~30 fps, baseline 128, ±30 amplitude — like a lit fingertip.
      for (var t = 0; t <= durationMs; t += 33) {
        a.addSample(t, 128 + 30 * math.sin(2 * math.pi * hz * t / 1000));
      }
      return a;
    }

    test('estimates ~60 bpm from a 1 Hz signal', () {
      final est = feedSine(hz: 1.0).estimate();
      expect(est, isNotNull);
      expect(est!.bpm, closeTo(60, 5));
      expect(est.quality, greaterThan(0.5));
    });

    test('estimates ~90 bpm from a 1.5 Hz signal', () {
      final est = feedSine(hz: 1.5).estimate();
      expect(est, isNotNull);
      expect(est!.bpm, closeTo(90, 6));
    });

    test('returns null for a flat signal (no finger)', () {
      final a = PpgAnalyzer();
      for (var t = 0; t <= 15000; t += 33) {
        a.addSample(t, 200);
      }
      expect(a.estimate(), isNull);
    });

    test('returns null when not enough data', () {
      final a = PpgAnalyzer();
      for (var t = 0; t <= 2000; t += 33) {
        a.addSample(t, 128 + 30 * math.sin(2 * math.pi * t / 1000));
      }
      expect(a.estimate(), isNull);
    });

    test('noisy signal yields no result or low quality', () {
      final a = PpgAnalyzer();
      final rng = math.Random(42);
      for (var t = 0; t <= 15000; t += 33) {
        a.addSample(t, 128 + 90 * rng.nextDouble());
      }
      final est = a.estimate();
      if (est != null) {
        expect(est.quality, lessThan(0.5));
      }
    });

    test('progress tracks the minimum window', () {
      final a = PpgAnalyzer(minWindowMs: 8000);
      expect(a.progress, 0);
      for (var t = 0; t <= 4000; t += 33) {
        a.addSample(t, 128.0);
      }
      expect(a.progress, closeTo(0.5, 0.05));
    });
  });
}
