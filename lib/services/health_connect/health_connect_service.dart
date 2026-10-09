import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';

import '../../features/measurements/domain/measurement_type.dart';

enum HealthConnectState {
  /// Health Connect is installed and this app has read permission.
  ready,

  /// Health Connect is installed but permission hasn't been granted.
  needsPermission,

  /// Health Connect app isn't installed on this Android device.
  notInstalled,

  /// Platform doesn't support Health Connect (e.g. iOS without
  /// HealthKit entitlements configured in Xcode).
  notSupported,
}

/// A reading fetched from Health Connect / a connected wearable app,
/// mapped onto our measurement model. Not yet saved — the caregiver
/// reviews and confirms before anything is written.
class HealthConnectReading {
  final MeasurementType type;
  final double value1;
  final double? value2;
  final String unit;
  final DateTime measuredAt;
  final String sourceLabel;

  const HealthConnectReading({
    required this.type,
    required this.value1,
    this.value2,
    required this.unit,
    required this.measuredAt,
    required this.sourceLabel,
  });
}

/// Reads health data that wearables (Galaxy Watch, Fitbit, etc.) write
/// into Health Connect. Read-only — AILaga never writes to Health Connect.
///
/// This is a pull/import model, not a live link: tap "Check for readings"
/// and the last 7 days are fetched, deduplicated against stored
/// measurements, then saved after confirmation.
class HealthConnectService {
  HealthConnectService({Health? health, bool? isAndroid})
      : _health = health ?? Health(),
        _isAndroid =
            isAndroid ?? (!kIsWeb && Platform.isAndroid);

  final Health _health;
  final bool _isAndroid;
  bool _configured = false;

  /// Types this app can map onto [MeasurementType].
  static const _types = [
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.BODY_TEMPERATURE,
  ];

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  Future<HealthConnectState> status() async {
    if (!_isAndroid) return HealthConnectState.notSupported;
    await _ensureConfigured();
    final available = await _health.isHealthConnectAvailable();
    if (!available) return HealthConnectState.notInstalled;
    final granted = await _health.hasPermissions(_types);
    return granted == true
        ? HealthConnectState.ready
        : HealthConnectState.needsPermission;
  }

  /// Opens the Health Connect permission screen. Returns true if the
  /// user granted access.
  Future<bool> requestAccess() async {
    await _ensureConfigured();
    return _health.requestAuthorization(_types);
  }

  /// Fetches readings between [start] and [end]. Systolic/diastolic
  /// blood-pressure points are paired into one reading when they share
  /// a timestamp (within 60 s); unpaired systolic points are skipped so
  /// we never store a half-formed BP value.
  Future<List<HealthConnectReading>> fetchReadings({
    required DateTime start,
    required DateTime end,
  }) async {
    await _ensureConfigured();
    final points = await _health.getHealthDataFromTypes(
      types: _types,
      preferredUnits: const {
        HealthDataType.BLOOD_GLUCOSE: HealthDataUnit.MILLIGRAM_PER_DECILITER,
        HealthDataType.BODY_TEMPERATURE: HealthDataUnit.DEGREE_CELSIUS,
        HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
            HealthDataUnit.MILLIMETER_OF_MERCURY,
        HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
            HealthDataUnit.MILLIMETER_OF_MERCURY,
      },
      startTime: start,
      endTime: end,
    );

    final readings = <HealthConnectReading>[];
    final systolic = <HealthDataPoint>[];
    final diastolic = <HealthDataPoint>[];

    for (final p in points) {
      final value = p.value;
      if (value is! NumericHealthValue) continue;
      final num n = value.numericValue;
      final source = p.sourceName.isNotEmpty ? p.sourceName : 'Health Connect';

      switch (p.type) {
        case HealthDataType.HEART_RATE:
        case HealthDataType.RESTING_HEART_RATE:
          readings.add(HealthConnectReading(
            type: MeasurementType.pulse,
            value1: n.toDouble(),
            unit: 'bpm',
            measuredAt: p.dateFrom.toUtc(),
            sourceLabel: source,
          ));
        case HealthDataType.BLOOD_GLUCOSE:
          readings.add(HealthConnectReading(
            type: MeasurementType.bloodGlucose,
            value1: n.toDouble(),
            unit: 'mg/dL',
            measuredAt: p.dateFrom.toUtc(),
            sourceLabel: source,
          ));
        case HealthDataType.BODY_TEMPERATURE:
          readings.add(HealthConnectReading(
            type: MeasurementType.temperature,
            value1: n.toDouble(),
            unit: '°C',
            measuredAt: p.dateFrom.toUtc(),
            sourceLabel: source,
          ));
        case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
          systolic.add(p);
        case HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
          diastolic.add(p);
        default:
          break;
      }
    }

    // Pair BP readings: for each systolic point find the nearest
    // diastolic within 60 s.
    final usedDia = <int>{};
    for (final s in systolic) {
      final sv = s.value;
      if (sv is! NumericHealthValue) continue;
      var best = -1;
      var bestDiff = 60001;
      for (var i = 0; i < diastolic.length; i++) {
        if (usedDia.contains(i)) continue;
        final diff =
            diastolic[i].dateFrom.difference(s.dateFrom).abs().inMilliseconds;
        if (diff < bestDiff) {
          bestDiff = diff;
          best = i;
        }
      }
      if (best < 0) continue;
      usedDia.add(best);
      final dv = diastolic[best].value;
      if (dv is! NumericHealthValue) continue;
      readings.add(HealthConnectReading(
        type: MeasurementType.bloodPressure,
        value1: sv.numericValue.toDouble(),
        value2: dv.numericValue.toDouble(),
        unit: 'mmHg',
        measuredAt: s.dateFrom.toUtc(),
        sourceLabel:
            s.sourceName.isNotEmpty ? s.sourceName : 'Health Connect',
      ));
    }

    readings.sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
    return readings;
  }
}

final healthConnectServiceProvider = Provider<HealthConnectService>((ref) {
  return HealthConnectService();
});
