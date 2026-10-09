import 'dart:math' as math;

/// Result of analyzing a camera-sampled brightness signal.
class PpgEstimate {
  /// Estimated beats per minute.
  final double bpm;

  /// 0..1 signal-quality score — how regular and covered the detected
  /// pulse peaks were. Below ~0.4 the estimate shouldn't be trusted.
  final double quality;

  /// Number of valid pulse peaks found.
  final int peakCount;

  /// Length of the analyzed window.
  final int durationMs;

  const PpgEstimate({
    required this.bpm,
    required this.quality,
    required this.peakCount,
    required this.durationMs,
  });
}

/// Analyzes fingertip-over-lens brightness samples to estimate pulse.
///
/// Feed it one mean-brightness value per camera frame. The algorithm:
///   1. Detrend — subtract a moving-average baseline (~0.75 s window) so
///      lighting drift doesn't look like a heartbeat.
///   2. Smooth — 3-sample moving average to knock down frame noise.
///   3. Peak-pick — local maxima above a noise-scaled threshold, with a
///      300 ms refractory (max ~200 bpm).
///   4. BPM — 60000 / median inter-peak interval. Intervals outside
///      333–1500 ms (40–180 bpm) are rejected.
///   5. Quality — combines interval regularity with how much of the
///      window produced usable peaks.
///
/// Pure Dart — unit-tested against synthetic signals.
class PpgAnalyzer {
  /// Minimum data needed before an estimate is attempted.
  final int minWindowMs;

  /// Samples kept at most this long.
  final int maxWindowMs;

  PpgAnalyzer({this.minWindowMs = 8000, this.maxWindowMs = 20000});

  final List<int> _t = [];
  final List<double> _v = [];

  int get sampleCount => _v.length;

  /// 0..1 progress toward having enough data for an estimate.
  double get progress {
    if (_t.isEmpty) return 0;
    final span = _t.last - _t.first;
    return (span / minWindowMs).clamp(0.0, 1.0);
  }

  void addSample(int timestampMs, double value) {
    _t.add(timestampMs);
    _v.add(value);
    // Drop samples older than the analysis window.
    while (_t.isNotEmpty && _t.last - _t.first > maxWindowMs) {
      _t.removeAt(0);
      _v.removeAt(0);
    }
  }

  void reset() {
    _t.clear();
    _v.clear();
  }

  /// Returns an estimate when enough clean signal has been collected,
  /// or null if the data is insufficient/too noisy.
  PpgEstimate? estimate() {
    if (_v.length < 30) return null;
    final span = _t.last - _t.first;
    if (span < minWindowMs) return null;

    final residual = _detrended(_v, _t, span);
    final smoothed = _smooth(residual);
    final peaks = _findPeaks(smoothed, _t);
    if (peaks.length < 5) return null;

    // Inter-peak intervals, clamped to a physiologic range.
    final intervals = <double>[];
    for (var i = 1; i < peaks.length; i++) {
      final d = (_t[peaks[i]] - _t[peaks[i - 1]]).toDouble();
      if (d >= 333 && d <= 1500) intervals.add(d);
    }
    if (intervals.length < 4) return null;

    intervals.sort();
    final median = intervals.length.isOdd
        ? intervals[intervals.length ~/ 2]
        : (intervals[intervals.length ~/ 2 - 1] +
                intervals[intervals.length ~/ 2]) /
            2;
    final bpm = 60000 / median;
    if (bpm < 35 || bpm > 200) return null;

    // Autocorrelation gate: a real pulse signal strongly resembles
    // itself shifted by one beat; pure noise does not. Without this,
    // refractory-spaced noise peaks can fake a high bpm.
    final dt = span / (_t.length - 1);
    final lagSamples = math.max(1, (median / dt).round());
    final autocorr = _autocorr(smoothed, lagSamples);
    if (autocorr < 0.2) return null;

    // Regularity: coefficient of variation of intervals, inverted.
    final mean =
        intervals.reduce((a, b) => a + b) / intervals.length;
    final variance = intervals
            .map((d) => (d - mean) * (d - mean))
            .reduce((a, b) => a + b) /
        intervals.length;
    final cv = mean > 0 ? math.sqrt(variance) / mean : 1.0;
    final regularity = (1 - cv).clamp(0.0, 1.0);

    // Coverage: fraction of the window spanned by detected peaks.
    final coverage =
        ((_t[peaks.last] - _t[peaks.first]) / span).clamp(0.0, 1.0);

    final quality = (0.4 * regularity + 0.3 * coverage + 0.3 * autocorr)
        .clamp(0.0, 1.0);

    return PpgEstimate(
      bpm: bpm,
      quality: quality,
      peakCount: peaks.length,
      durationMs: span,
    );
  }

  /// Subtracts a moving-average baseline whose width is ~1/10 of the
  /// window (≈0.5–2 s), removing lighting drift.
  List<double> _detrended(List<double> v, List<int> t, int span) {
    final win = math.max(3, (v.length / math.max(1, span / 1000)).round());
    final out = List<double>.filled(v.length, 0);
    var sum = 0.0;
    var head = 0;
    for (var i = 0; i < v.length; i++) {
      sum += v[i];
      while (i - head >= win) {
        sum -= v[head];
        head++;
      }
      out[i] = v[i] - sum / (i - head + 1);
    }
    return out;
  }

  List<double> _smooth(List<double> v) {
    if (v.length < 3) return List.of(v);
    final out = List<double>.filled(v.length, 0);
    out[0] = (v[0] + v[1]) / 2;
    out[v.length - 1] = (v[v.length - 2] + v[v.length - 1]) / 2;
    for (var i = 1; i < v.length - 1; i++) {
      out[i] = (v[i - 1] + v[i] + v[i + 1]) / 3;
    }
    return out;
  }

  /// Pearson correlation between the signal and itself shifted by
  /// [lag] samples. ~1.0 for a periodic pulse, ~0 for noise.
  double _autocorr(List<double> v, int lag) {
    if (v.length <= lag + 2) return 0;
    final n = v.length - lag;
    var meanX = 0.0, meanY = 0.0;
    for (var i = 0; i < n; i++) {
      meanX += v[i];
      meanY += v[i + lag];
    }
    meanX /= n;
    meanY /= n;
    var num = 0.0, denX = 0.0, denY = 0.0;
    for (var i = 0; i < n; i++) {
      final dx = v[i] - meanX;
      final dy = v[i + lag] - meanY;
      num += dx * dy;
      denX += dx * dx;
      denY += dy * dy;
    }
    final den = math.sqrt(denX * denY);
    return den == 0 ? 0 : (num / den).clamp(-1.0, 1.0);
  }

  /// Local maxima exceeding a noise-scaled threshold with a 300 ms
  /// refractory period.
  List<int> _findPeaks(List<double> v, List<int> t) {
    var maxAbs = 0.0;
    for (final x in v) {
      final a = x.abs();
      if (a > maxAbs) maxAbs = a;
    }
    if (maxAbs == 0) return const [];
    final threshold = maxAbs * 0.25;

    final peaks = <int>[];
    var lastPeakT = -1000000;
    for (var i = 1; i < v.length - 1; i++) {
      if (v[i] > v[i - 1] &&
          v[i] >= v[i + 1] &&
          v[i] > threshold &&
          t[i] - lastPeakT > 300) {
        peaks.add(i);
        lastPeakT = t[i];
      }
    }
    return peaks;
  }
}
