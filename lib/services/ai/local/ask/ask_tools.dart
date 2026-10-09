import 'dart:convert';

import '../../../../features/appointments/domain/appointment_repository.dart';
import '../../../../features/care_notes/domain/care_note_repository.dart';
import '../../../../features/measurements/domain/measurement_repository.dart';
import '../../../../features/medications/domain/medication_repository.dart';
import '../../../../features/medications/domain/medication_status.dart';
import '../local_ai_engine.dart';

/// Read-only tool surface for the Ask agent (spec §6.5).
/// Every method maps to a repository *query* — nothing here mutates state.
class AskTools implements ToolExecutor {
  final String careRecipientId;
  final MedicationRepository medicationRepo;
  final MeasurementRepository measurementRepo;
  final CareNoteRepository careNoteRepo;
  final AppointmentRepository appointmentRepo;

  AskTools({
    required this.careRecipientId,
    required this.medicationRepo,
    required this.measurementRepo,
    required this.careNoteRepo,
    required this.appointmentRepo,
  });

  static const List<String> _names = [
    'get_medication_occurrences',
    'get_measurements',
    'get_care_notes',
    'get_appointments',
    'compute_adherence',
  ];

  @override
  List<String> get toolNames => _names;

  /// JSON Schema-ish tool descriptors for the model prompt.
  static const List<Map<String, Object?>> toolDescriptors = [
    {
      'name': 'get_medication_occurrences',
      'description': 'List medication doses due/taken/skipped in a date range',
      'parameters': {
        'days_back': 'int (default 1)',
        'status': 'pending|taken|skipped|not_confirmed|null',
      },
    },
    {
      'name': 'get_measurements',
      'description': 'List measurements (BP, pulse, temp, weight, glucose)',
      'parameters': {
        'type': 'blood_pressure|pulse|temperature|weight|blood_glucose|null',
        'days_back': 'int (default 7)',
        'limit': 'int (default 10)',
      },
    },
    {
      'name': 'get_care_notes',
      'description': 'List care notes / observations',
      'parameters': {'days_back': 'int (default 7)', 'limit': 'int (default 10)'},
    },
    {
      'name': 'get_appointments',
      'description': 'List upcoming appointments',
      'parameters': {'days_forward': 'int (default 30)'},
    },
    {
      'name': 'compute_adherence',
      'description': 'Share of doses taken vs scheduled in a date range',
      'parameters': {'days_back': 'int (default 7)'},
    },
  ];

  @override
  Future<Object?> call(String name, Map<String, Object?> args) async {
    switch (name) {
      case 'get_medication_occurrences':
        return _medicationOccurrences(args);
      case 'get_measurements':
        return _measurements(args);
      case 'get_care_notes':
        return _careNotes(args);
      case 'get_appointments':
        return _appointments(args);
      case 'compute_adherence':
        return _adherence(args);
      default:
        return {'error': 'unknown_tool', 'name': name};
    }
  }

  int _daysBack(Map<String, Object?> args, int fallback) =>
      (args['days_back'] as num?)?.toInt() ?? fallback;

  Future<List<Map<String, Object?>>> _medicationOccurrences(
      Map<String, Object?> args) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: _daysBack(args, 1)));
    final occurrences = await medicationRepo.getOccurrencesForDateRange(
        careRecipientId, start, now.add(const Duration(days: 1)));

    final statusFilter = args['status'] as String?;
    final schedules = await medicationRepo.getActiveSchedules(careRecipientId);
    final namesById = {for (final s in schedules) s.id: s.medicationName};

    return occurrences
        .where((o) =>
            statusFilter == null || o.status.databaseValue == statusFilter)
        .map((o) => {
              'id': o.id,
              'medication': namesById[o.medicationScheduleId] ?? 'unknown',
              'scheduledAt': o.scheduledAt.toIso8601String(),
              'status': o.status.databaseValue,
              'recordedBy': o.recordedByLabel,
            })
        .toList();
  }

  Future<List<Map<String, Object?>>> _measurements(
      Map<String, Object?> args) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: _daysBack(args, 7)));
    final limit = (args['limit'] as num?)?.toInt() ?? 10;
    final typeArg = args['type'] as String?;

    final rows = await measurementRepo.getForDateRange(
        careRecipientId, start, now);
    return rows
        .where((m) =>
            typeArg == null || m.measurementType.databaseValue == typeArg)
        .take(limit)
        .map((m) => {
              'id': m.id,
              'type': m.measurementType.databaseValue,
              'value1': m.value1,
              'value2': m.value2,
              'unit': m.unit,
              'measuredAt': m.measuredAt.toIso8601String(),
            })
        .toList();
  }

  Future<List<Map<String, Object?>>> _careNotes(
      Map<String, Object?> args) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: _daysBack(args, 7)));
    final limit = (args['limit'] as num?)?.toInt() ?? 10;
    final rows =
        await careNoteRepo.getForDateRange(careRecipientId, start, now);
    return rows
        .take(limit)
        .map((n) => {
              'id': n.id,
              'text': n.originalText,
              'observedAt': n.observedAt.toIso8601String(),
              'sourceType': n.sourceType,
            })
        .toList();
  }

  Future<List<Map<String, Object?>>> _appointments(
      Map<String, Object?> args) async {
    final now = DateTime.now();
    final end = now.add(Duration(days: _daysBack(args, 30)));
    final rows =
        await appointmentRepo.getForDateRange(careRecipientId, now, end);
    return rows
        .map((a) => {
              'id': a.id,
              'provider': a.providerOrFacility,
              'purpose': a.purpose,
              'scheduledAt': a.scheduledAt.toIso8601String(),
              'status': a.status,
            })
        .toList();
  }

  Future<Map<String, Object?>> _adherence(Map<String, Object?> args) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: _daysBack(args, 7)));
    final occurrences = await medicationRepo.getOccurrencesForDateRange(
        careRecipientId, start, now);

    final due = occurrences
        .where((o) => o.status != MedicationStatus.pending || o.scheduledAt.isBefore(now))
        .toList();
    final taken = due.where((o) => o.status == MedicationStatus.taken).length;
    return {
      'window_days': _daysBack(args, 7),
      'doses_due': due.length,
      'doses_taken': taken,
      'adherence': due.isEmpty ? null : taken / due.length,
    };
  }

  /// Helper for the deterministic (Basic mode) path: run a tool and decode.
  Future<Map<String, Object?>?> callJson(String name,
      [Map<String, Object?> args = const {}]) async {
    final result = await call(name, args);
    return {'tool': name, 'result': result, 'result_json': jsonEncode(result)};
  }
}
