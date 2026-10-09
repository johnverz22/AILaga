import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// The kind of hardware event detected.
enum SosSensorEventKind {
  /// Rapid shaking of the phone — the elder-friendly SOS shortcut.
  shake,

  /// A hard impact followed by prolonged stillness — a possible fall.
  /// This is a heuristic, not a medical-grade detector.
  possibleFall,
}

class SosSensorEvent {
  final SosSensorEventKind kind;
  final DateTime at;

  const SosSensorEvent(this.kind, this.at);
}

/// Listens to the accelerometer and emits [SosSensorEvent]s.
///
/// Deterministic — no AI involved. Foreground only: the stream runs while the
/// app is open, which matches how the emergency screen is meant to be reached.
///
/// Detection rules (all magnitudes in m/s², gravity ≈ 9.81):
///  - **Shake**: ≥4 acceleration spikes (> 25 m/s²) within 1.5 s.
///  - **Fall**: a hard impact (> 27 m/s²) followed within 15 s by ≥3 s of
///    near-total stillness (device resting).
///
/// A cooldown suppresses repeat events so a single shake/fall doesn't spam.
class SosSensorService {
  SosSensorService({
    Stream<AccelerometerEvent>? accelerometerStream,
    DateTime Function()? clock,
    this.shakeEnabled = true,
    this.fallEnabled = false,
  })  : _accelerometerStream =
            accelerometerStream ?? accelerometerEventStream(),
        _now = clock ?? DateTime.now;
  static const _shakeThreshold = 25.0;
  static const _shakeWindowMs = 1500;
  static const _shakeMinSpikes = 4;
  static const _impactThreshold = 27.0;
  static const _stillMin = 7.0;
  static const _stillMax = 12.5;
  static const _stillNeededMs = 3000;
  static const _postImpactWindowMs = 15000;
  static const _cooldownMs = 45000;

  final Stream<AccelerometerEvent> _accelerometerStream;
  final DateTime Function() _now;

  bool shakeEnabled;
  bool fallEnabled;

  StreamSubscription<AccelerometerEvent>? _sub;
  final _events = StreamController<SosSensorEvent>.broadcast(sync: true);

  final List<DateTime> _shakeSpikes = [];
  DateTime? _impactAt;
  DateTime? _stillSince;
  DateTime _lastEventAt = DateTime.fromMillisecondsSinceEpoch(0);

  Stream<SosSensorEvent> get events => _events.stream;
  bool get isRunning => _sub != null;

  void configure({bool? shake, bool? fall}) {
    shakeEnabled = shake ?? shakeEnabled;
    fallEnabled = fall ?? fallEnabled;
  }

  void start() {
    if (_sub != null) return;
    _sub = _accelerometerStream.listen(_onAccel);
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
    _shakeSpikes.clear();
    _impactAt = null;
    _stillSince = null;
  }

  void dispose() {
    stop();
    _events.close();
  }

  double _magnitude(AccelerometerEvent e) =>
      math.sqrt(e.x * e.x + e.y * e.y + e.z * e.z);

  void _onAccel(AccelerometerEvent e) {
    final now = _now();
    final m = _magnitude(e);

    if (shakeEnabled) _trackShake(m, now);
    if (fallEnabled) _trackFall(m, now);
  }

  void _trackShake(double m, DateTime now) {
    if (m > _shakeThreshold) {
      final last =
          _shakeSpikes.isEmpty ? null : _shakeSpikes.last;
      // Ignore duplicates within 80 ms — one physical jolt can read as
      // several consecutive high samples.
      if (last == null || now.difference(last).inMilliseconds > 80) {
        _shakeSpikes.add(now);
      }
    }
    _shakeSpikes.removeWhere(
        (t) => now.difference(t).inMilliseconds > _shakeWindowMs);
    if (_shakeSpikes.length >= _shakeMinSpikes) {
      _shakeSpikes.clear();
      _emit(SosSensorEventKind.shake, now);
    }
  }

  void _trackFall(double m, DateTime now) {
    if (m > _impactThreshold) {
      _impactAt = now;
      _stillSince = null;
      return;
    }
    if (_impactAt == null) return;
    if (now.difference(_impactAt!).inMilliseconds > _postImpactWindowMs) {
      _impactAt = null;
      _stillSince = null;
      return;
    }
    final still = m >= _stillMin && m <= _stillMax;
    if (still) {
      _stillSince ??= now;
      if (now.difference(_stillSince!).inMilliseconds >= _stillNeededMs) {
        _impactAt = null;
        _stillSince = null;
        _emit(SosSensorEventKind.possibleFall, now);
      }
    } else {
      // Device moving again — reset the stillness clock but keep watching
      // until the post-impact window expires.
      _stillSince = null;
    }
  }

  void _emit(SosSensorEventKind kind, DateTime now) {
    if (now.difference(_lastEventAt).inMilliseconds < _cooldownMs) return;
    _lastEventAt = now;
    _events.add(SosSensorEvent(kind, now));
  }
}

final sosSensorServiceProvider = Provider<SosSensorService>((ref) {
  final service = SosSensorService();
  ref.onDispose(service.dispose);
  return service;
});
