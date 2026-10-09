import 'dart:async';

import 'package:ailaga/services/hardware/sos_sensor_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  late StreamController<AccelerometerEvent> ctrl;
  late DateTime fakeNow;
  late List<SosSensorEvent> events;
  late SosSensorService service;

  void feed(double x, double y, double z) {
    ctrl.add(AccelerometerEvent(x, y, z, fakeNow));
  }

  SosSensorService build({bool shake = true, bool fall = true}) {
    final s = SosSensorService(
      accelerometerStream: ctrl.stream,
      clock: () => fakeNow,
      shakeEnabled: shake,
      fallEnabled: fall,
    );
    s.start();
    service = s;
    s.events.listen(events.add);
    return s;
  }

  setUp(() {
    ctrl = StreamController<AccelerometerEvent>(sync: true);
    fakeNow = DateTime(2024, 1, 1, 12);
    events = [];
  });

  tearDown(() {
    service.dispose();
    ctrl.close();
  });

  test('shake: 4 hard spikes within 1.5 s emits one shake event', () {
    build();
    for (var i = 0; i < 4; i++) {
      fakeNow = fakeNow.add(const Duration(milliseconds: 120));
      feed(0, 0, 30);
    }
    expect(events.single.kind, SosSensorEventKind.shake);
  });

  test('gentle motion emits nothing', () {
    build();
    for (var i = 0; i < 50; i++) {
      fakeNow = fakeNow.add(const Duration(milliseconds: 100));
      feed(0.5, 9.8, 1.0);
    }
    expect(events, isEmpty);
  });

  test('shake disabled produces no shake event', () {
    build(shake: false);
    for (var i = 0; i < 6; i++) {
      fakeNow = fakeNow.add(const Duration(milliseconds: 120));
      feed(0, 0, 30);
    }
    // Fall detection is on but stillness never follows within window here.
    expect(events.where((e) => e.kind == SosSensorEventKind.shake), isEmpty);
  });

  test('impact then stillness emits possibleFall', () {
    build();
    // Hard impact.
    feed(0, 0, 30);
    // Then the phone lies still — normal gravity for > 3 s.
    for (var i = 0; i < 8; i++) {
      fakeNow = fakeNow.add(const Duration(seconds: 1));
      feed(0, 9.8, 0.5);
    }
    expect(
        events.any((e) => e.kind == SosSensorEventKind.possibleFall), isTrue);
  });

  test('impact followed by continued motion does not emit fall', () {
    build();
    feed(0, 0, 30);
    // Phone keeps moving — person picked it up.
    for (var i = 0; i < 8; i++) {
      fakeNow = fakeNow.add(const Duration(seconds: 1));
      feed(3.0, 15.0, 4.0); // ~16 m/s² — active motion
    }
    expect(
        events.where((e) => e.kind == SosSensorEventKind.possibleFall),
        isEmpty);
  });

  test('cooldown suppresses immediate repeats', () {
    build();
    for (var i = 0; i < 4; i++) {
      fakeNow = fakeNow.add(const Duration(milliseconds: 120));
      feed(0, 0, 30);
    }
    // Second shake right after — within cooldown.
    for (var i = 0; i < 4; i++) {
      fakeNow = fakeNow.add(const Duration(milliseconds: 120));
      feed(0, 0, 30);
    }
    expect(events.length, 1);
  });
}
