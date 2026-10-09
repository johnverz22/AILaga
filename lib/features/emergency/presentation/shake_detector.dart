import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetector {
  final VoidCallback onShake;
  final double shakeThresholdGravity;
  final int shakeSlopTimeMS;
  final int shakeCountResetTimeMS;
  final int requiredShakes;

  StreamSubscription? _streamSubscription;
  int _shakeCount = 0;
  int _lastShakeTimestamp = 0;

  ShakeDetector({
    required this.onShake,
    this.shakeThresholdGravity = 2.7,
    this.shakeSlopTimeMS = 500,
    this.shakeCountResetTimeMS = 3000,
    this.requiredShakes = 3,
  });

  void start() {
    if (_streamSubscription != null) return;
    
    _streamSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        double x = event.x / 9.80665;
        double y = event.y / 9.80665;
        double z = event.z / 9.80665;

        double gForce = sqrt(x * x + y * y + z * z);

        if (gForce > shakeThresholdGravity) {
          final now = DateTime.now().millisecondsSinceEpoch;
          
          if (_lastShakeTimestamp + shakeSlopTimeMS > now) {
            return; // ignore shakes too close to each other
          }

          if (_lastShakeTimestamp + shakeCountResetTimeMS < now) {
            _shakeCount = 0;
          }

          _lastShakeTimestamp = now;
          _shakeCount++;

          if (_shakeCount >= requiredShakes) {
            _shakeCount = 0;
            onShake();
          }
        }
      },
      onError: (e) {
        debugPrint('Accelerometer error: $e');
      },
      cancelOnError: true,
    );
  }

  void stop() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }
}
