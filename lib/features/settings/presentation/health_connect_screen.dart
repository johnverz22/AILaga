import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/utilities/uuid_generator.dart';
import '../../../services/health_connect/health_connect_service.dart';
import '../../care_recipient/data/care_recipient_providers.dart';
import '../../measurements/data/measurement_providers.dart';
import '../../measurements/domain/measurement_entity.dart';
import '../../measurements/domain/measurement_type.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Screen for pulling readings that wearables write into Health
/// Connect (Android). Three steps, all caregiver-confirmed:
///   1. Check the Health Connect app is installed.
///   2. Grant read permission.
///   3. Fetch the last 7 days, preview what is new, add them.
///
/// Read-only — nothing is written back to Health Connect, and imported
/// rows carry `sourceType: health_connect` for provenance.
class HealthConnectScreen extends ConsumerStatefulWidget {
  const HealthConnectScreen({super.key});

  @override
  ConsumerState<HealthConnectScreen> createState() =>
      _HealthConnectScreenState();
}

class _HealthConnectScreenState extends ConsumerState<HealthConnectScreen> {
  HealthConnectState? _state;
  List<HealthConnectReading>? _newReadings;
  bool _busy = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    try {
      final state =
          await ref.read(healthConnectServiceProvider).status();
      if (mounted) setState(() => _state = state);
    } catch (_) {
      if (mounted) {
        setState(() => _state = HealthConnectState.notInstalled);
      }
    }
  }

  Future<void> _connect() async {
    setState(() => _busy = true);
    try {
      await ref.read(healthConnectServiceProvider).requestAccess();
    } catch (_) {
      // Permission screen may fail if Health Connect is outdated.
    } finally {
      await _refreshStatus();
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Fetch the last 7 days and filter out readings we already have
  /// (same type, same value, measured within a minute).
  Future<void> _fetch() async {
    final recipient = ref.read(primaryCareRecipientProvider).valueOrNull;
    if (recipient == null) {
      setState(() => _message = 'Add a care recipient first.');
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
      _newReadings = null;
    });
    try {
      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 7));
      final service = ref.read(healthConnectServiceProvider);
      final fetched =
          await service.fetchReadings(start: start, end: now);
      final existing = await ref
          .read(measurementRepositoryProvider)
          .getForDateRange(recipient.id, start.toUtc(), now.toUtc());

      bool isDupe(HealthConnectReading r) => existing.any((m) =>
          m.measurementType == r.type &&
          m.value1 == r.value1 &&
          m.value2 == r.value2 &&
          m.measuredAt.difference(r.measuredAt).abs() <
              const Duration(minutes: 1));

      final fresh = fetched.where((r) => !isDupe(r)).toList();
      if (mounted) {
        setState(() {
          _newReadings = fresh;
          if (fresh.isEmpty) {
            _message = fetched.isEmpty
                ? 'No readings found in the last 7 days.'
                : 'Everything found is already saved.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _message = 'Could not read health data.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveAll() async {
    final recipient = ref.read(primaryCareRecipientProvider).valueOrNull;
    final readings = _newReadings;
    if (recipient == null || readings == null || readings.isEmpty) {
      return;
    }
    setState(() => _busy = true);
    final repo = ref.read(measurementRepositoryProvider);
    final now = DateTime.now().toUtc();
    for (final r in readings) {
      await repo.create(MeasurementEntity(
        id: UuidGenerator.generate(),
        careRecipientId: recipient.id,
        measurementType: r.type,
        value1: r.value1,
        value2: r.value2,
        unit: r.unit,
        measuredAt: r.measuredAt,
        recordedAt: now,
        sourceType: 'health_connect',
        sourceLabel: r.sourceLabel,
        createdAt: now,
        updatedAt: now,
      ));
    }
    if (mounted) {
      setState(() {
        _busy = false;
        _message = 'Added ${readings.length} reading'
            '${readings.length == 1 ? '' : 's'}.';
        _newReadings = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF8),
      appBar: AppBar(title: const Text('Health Connect'), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _statusCard(theme),
            const SizedBox(height: 16),
            if (_state == HealthConnectState.needsPermission)
              _primaryButton(
                label: 'Allow access',
                icon: Symbols.key_rounded,
                onPressed: _busy ? null : _connect,
              ),
            if (_state == HealthConnectState.ready &&
                _newReadings == null)
              _primaryButton(
                label: 'Check for readings',
                icon: Symbols.download_rounded,
                onPressed: _busy ? null : _fetch,
              ),
            if (_state == HealthConnectState.notInstalled)
              const Text(
                'Install the free Health Connect app from the Play '
                'Store, then come back here.',
                textAlign: TextAlign.center,
              ),
            if (_state == HealthConnectState.notSupported)
              const Text(
                'Health Connect is only on Android phones.',
                textAlign: TextAlign.center,
              ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Text(_message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF5E5748))),
            ],
            if (_busy) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_newReadings != null && _newReadings!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('New readings',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._newReadings!.map(_readingTile),
              const SizedBox(height: 16),
              _primaryButton(
                label: 'Add all',
                icon: Symbols.check_rounded,
                onPressed: _busy ? null : _saveAll,
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'AILaga reads health data only. It never writes to or '
              'changes your wearable\'s data.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF5E5748), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(ThemeData theme) {
    final (icon, text, color) = switch (_state) {
      HealthConnectState.ready => (
          Symbols.check_circle_rounded,
          'Connected — ready to read wearable data.',
          const Color(0xFF1B7F3B)
        ),
      HealthConnectState.needsPermission => (
          Symbols.key_rounded,
          'Health Connect is installed. Permission needed.',
          const Color(0xFF9A5B00)
        ),
      HealthConnectState.notInstalled => (
          Symbols.health_and_safety_rounded,
          'Health Connect app not installed.',
          const Color(0xFF9A5B00)
        ),
      HealthConnectState.notSupported => (
          Symbols.smartphone_rounded,
          'Not available on this device.',
          const Color(0xFF5E5748)
        ),
      null => (Symbols.hourglass_top_rounded, 'Checking…', const Color(0xFF5E5748)),
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFE6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD9D2C3), width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _readingTile(HealthConnectReading r) {
    final value = r.type == MeasurementType.bloodPressure
        ? '${r.value1.round()}/${r.value2?.round() ?? '—'}'
        : r.value1.round().toString();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9D2C3)),
      ),
      child: Row(
        children: [
          Icon(_iconFor(r.type), color: const Color(0xFF0B6B6B)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.type.displayLabel,
                    style:
                        const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  '${DateFormat('MMM d, h:mm a').format(r.measuredAt.toLocal())} · ${r.sourceLabel}',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF5E5748)),
                ),
              ],
            ),
          ),
          Text('$value ${r.unit}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  IconData _iconFor(MeasurementType t) => switch (t) {
        MeasurementType.bloodPressure => Symbols.blood_pressure_rounded,
        MeasurementType.pulse => Symbols.monitor_heart_rounded,
        MeasurementType.temperature => Symbols.thermostat_rounded,
        MeasurementType.weight => Symbols.monitor_weight_rounded,
        MeasurementType.bloodGlucose => Symbols.glucose_rounded,
      };

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0B6B6B)),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
