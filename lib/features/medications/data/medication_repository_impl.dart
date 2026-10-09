import 'dart:convert';
import 'package:drift/drift.dart';
import '../domain/medication_entity.dart';
import '../domain/medication_repository.dart';
import '../domain/medication_status.dart';
import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utilities/uuid_generator.dart';

// ---------------------------------------------------------------------------
// Mappers
// ---------------------------------------------------------------------------

MedicationScheduleEntity _scheduleToEntity(MedicationSchedule row) {
  return MedicationScheduleEntity(
    id: row.id,
    careRecipientId: row.careRecipientId,
    medicationName: row.medicationName,
    prescribedInstructions: row.prescribedInstructions,
    scheduleTimes: row.scheduleTimes,
    startDate: row.startDate,
    endDate: row.endDate,
    notes: row.notes,
    isActive: row.isActive,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}

MedicationOccurrenceEntity _occurrenceToEntity(MedicationOccurrence row) {
  return MedicationOccurrenceEntity(
    id: row.id,
    medicationScheduleId: row.medicationScheduleId,
    scheduledAt: row.scheduledAt,
    status: MedicationStatus.fromDatabaseValue(row.status),
    statusUpdatedAt: row.statusUpdatedAt,
    statusNote: row.statusNote,
    recordedByLabel: row.recordedByLabel,
    createdAt: row.createdAt,
  );
}

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

class MedicationRepositoryImpl implements MedicationRepository {
  final AppDatabase _db;

  MedicationRepositoryImpl(this._db);

  // -------------------------------------------------------------------------
  // Schedules — read
  // -------------------------------------------------------------------------

  @override
  Future<List<MedicationScheduleEntity>> getActiveSchedules(
      String recipientId) async {
    try {
      final rows = await (_db.select(_db.medicationSchedules)
            ..where((t) =>
                t.careRecipientId.equals(recipientId) &
                t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.medicationName)]))
          .get();
      return rows.map(_scheduleToEntity).toList();
    } on Exception catch (e) {
      throw DatabaseException('Failed to get active schedules', cause: e);
    }
  }

  @override
  Future<List<MedicationScheduleEntity>> getAllSchedules(
      String recipientId) async {
    try {
      final rows = await (_db.select(_db.medicationSchedules)
            ..where((t) => t.careRecipientId.equals(recipientId))
            ..orderBy([
              (t) => OrderingTerm.desc(t.isActive),
              (t) => OrderingTerm.asc(t.medicationName),
            ]))
          .get();
      return rows.map(_scheduleToEntity).toList();
    } on Exception catch (e) {
      throw DatabaseException('Failed to get all schedules', cause: e);
    }
  }

  @override
  Future<MedicationScheduleEntity?> getScheduleById(String id) async {
    try {
      final row = await (_db.select(_db.medicationSchedules)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return row == null ? null : _scheduleToEntity(row);
    } on Exception catch (e) {
      throw DatabaseException('Failed to get schedule by id: $id', cause: e);
    }
  }

  // -------------------------------------------------------------------------
  // Schedules — write
  // -------------------------------------------------------------------------

  @override
  Future<void> createSchedule(MedicationScheduleEntity entity) async {
    try {
      await _db.into(_db.medicationSchedules).insert(
            MedicationSchedulesCompanion.insert(
              id: entity.id,
              careRecipientId: entity.careRecipientId,
              medicationName: entity.medicationName,
              prescribedInstructions: Value(entity.prescribedInstructions),
              scheduleTimes: entity.scheduleTimes,
              startDate: entity.startDate,
              endDate: Value(entity.endDate),
              notes: Value(entity.notes),
              isActive: Value(entity.isActive),
              createdAt: entity.createdAt,
              updatedAt: entity.updatedAt,
            ),
          );
    } on Exception catch (e) {
      throw DatabaseException('Failed to create schedule', cause: e);
    }
  }

  /// Updates fields of an existing schedule.
  ///
  /// Per the critical rules: does NOT rewrite past occurrences. If the caller
  /// wants to change schedule times going forward they should deactivate + create new.
  @override
  Future<void> updateSchedule(MedicationScheduleEntity entity) async {
    try {
      await (_db.update(_db.medicationSchedules)
            ..where((t) => t.id.equals(entity.id)))
          .write(
        MedicationSchedulesCompanion(
          medicationName: Value(entity.medicationName),
          prescribedInstructions: Value(entity.prescribedInstructions),
          scheduleTimes: Value(entity.scheduleTimes),
          startDate: Value(entity.startDate),
          endDate: Value(entity.endDate),
          notes: Value(entity.notes),
          updatedAt: Value(entity.updatedAt),
        ),
      );
    } on Exception catch (e) {
      throw DatabaseException('Failed to update schedule', cause: e);
    }
  }

  /// Soft-deactivates the schedule. History is preserved.
  @override
  Future<void> deactivateSchedule(String id) async {
    try {
      final now = DateTime.now().toUtc();
      await (_db.update(_db.medicationSchedules)
            ..where((t) => t.id.equals(id)))
          .write(MedicationSchedulesCompanion(
        isActive: const Value(false),
        updatedAt: Value(now),
      ));
    } on Exception catch (e) {
      throw DatabaseException('Failed to deactivate schedule: $id', cause: e);
    }
  }

  // -------------------------------------------------------------------------
  // Schedules — streams
  // -------------------------------------------------------------------------

  @override
  Stream<List<MedicationScheduleEntity>> watchActiveSchedules(
      String recipientId) {
    return (_db.select(_db.medicationSchedules)
          ..where((t) =>
              t.careRecipientId.equals(recipientId) &
              t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.medicationName)]))
        .watch()
        .map((rows) => rows.map(_scheduleToEntity).toList());
  }

  // -------------------------------------------------------------------------
  // Occurrences — read
  // -------------------------------------------------------------------------

  @override
  Future<List<MedicationOccurrenceEntity>> getOccurrencesForDate(
      String scheduleId, DateTime date) async {
    try {
      final start = DateTime.utc(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));
      final rows = await (_db.select(_db.medicationOccurrences)
            ..where((t) =>
                t.medicationScheduleId.equals(scheduleId) &
                t.scheduledAt.isBetweenValues(start, end))
            ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)]))
          .get();
      return rows.map(_occurrenceToEntity).toList();
    } on Exception catch (e) {
      throw DatabaseException('Failed to get occurrences for date', cause: e);
    }
  }

  @override
  Future<List<MedicationOccurrenceEntity>> getOccurrencesForDateRange(
      String recipientId, DateTime start, DateTime end) async {
    try {
      // Join via medicationSchedules to filter by recipientId.
      final schedules = await getActiveSchedules(recipientId);
      final scheduleIds = schedules.map((s) => s.id).toList();
      if (scheduleIds.isEmpty) return [];

      final utcStart = start.toUtc();
      final utcEnd = end.toUtc();

      final rows = await (_db.select(_db.medicationOccurrences)
            ..where((t) =>
                t.medicationScheduleId.isIn(scheduleIds) &
                t.scheduledAt.isBetweenValues(utcStart, utcEnd))
            ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)]))
          .get();
      return rows.map(_occurrenceToEntity).toList();
    } on Exception catch (e) {
      throw DatabaseException('Failed to get occurrences for date range', cause: e);
    }
  }

  @override
  Future<List<MedicationOccurrenceEntity>> getPendingOccurrences(
      String recipientId) async {
    try {
      final schedules = await getActiveSchedules(recipientId);
      final scheduleIds = schedules.map((s) => s.id).toList();
      if (scheduleIds.isEmpty) return [];

      final rows = await (_db.select(_db.medicationOccurrences)
            ..where((t) =>
                t.medicationScheduleId.isIn(scheduleIds) &
                t.status.equals('pending'))
            ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)]))
          .get();
      return rows.map(_occurrenceToEntity).toList();
    } on Exception catch (e) {
      throw DatabaseException('Failed to get pending occurrences', cause: e);
    }
  }

  // -------------------------------------------------------------------------
  // Occurrences — idempotent generation
  // -------------------------------------------------------------------------

  /// Generates occurrence rows for [scheduleId] for every dose time in the
  /// date range [fromDate]..[toDate] (inclusive), IDEMPOTENTLY.
  ///
  /// Uses `insertOnConflictUpdate` targeting the unique key
  /// (medication_schedule_id, scheduled_at) — if a row already exists, it
  /// is left unchanged (conflict update writes same values). This guarantees
  /// calling this method multiple times is safe.
  @override
  Future<void> generateOccurrences(
      String scheduleId, DateTime fromDate, DateTime toDate) async {
    try {
      final schedule = await getScheduleById(scheduleId);
      if (schedule == null || !schedule.isActive) return;

      // Parse the JSON array of "HH:mm" strings.
      final times =
          (jsonDecode(schedule.scheduleTimes) as List).cast<String>();
      if (times.isEmpty) return;

      final now = DateTime.now().toUtc();

      await _db.transaction(() async {
        DateTime cursor = DateTime.utc(
            fromDate.year, fromDate.month, fromDate.day);
        final lastDay = DateTime.utc(
            toDate.year, toDate.month, toDate.day);

        while (!cursor.isAfter(lastDay)) {
          for (final timeStr in times) {
            final parts = timeStr.split(':');
            final hour = int.parse(parts[0]);
            final minute = int.parse(parts[1]);
            final scheduledAt =
                DateTime.utc(cursor.year, cursor.month, cursor.day, hour, minute);

            // Skip occurrences before the schedule start date.
            if (scheduledAt.isBefore(schedule.startDate.toUtc())) {
              continue;
            }
            // Skip after end date if set.
            if (schedule.endDate != null &&
                scheduledAt.isAfter(schedule.endDate!.toUtc())) {
              continue;
            }

            await _db.into(_db.medicationOccurrences).insertOnConflictUpdate(
                  MedicationOccurrencesCompanion.insert(
                    id: UuidGenerator.generate(),
                    medicationScheduleId: scheduleId,
                    scheduledAt: scheduledAt,
                    status: const Value('pending'),
                    createdAt: now,
                  ),
                );
          }
          cursor = cursor.add(const Duration(days: 1));
        }
      });
    } on Exception catch (e) {
      throw DatabaseException('Failed to generate occurrences', cause: e);
    }
  }

  // -------------------------------------------------------------------------
  // Occurrences — write
  // -------------------------------------------------------------------------

  @override
  Future<void> updateOccurrenceStatus(
    String occurrenceId,
    MedicationStatus status, {
    String? note,
  }) async {
    try {
      final now = DateTime.now().toUtc();
      await (_db.update(_db.medicationOccurrences)
            ..where((t) => t.id.equals(occurrenceId)))
          .write(MedicationOccurrencesCompanion(
        status: Value(status.databaseValue),
        statusUpdatedAt: Value(now),
        statusNote: Value(note),
      ));
    } on Exception catch (e) {
      throw DatabaseException('Failed to update occurrence status', cause: e);
    }
  }

  // -------------------------------------------------------------------------
  // Occurrences — streams
  // -------------------------------------------------------------------------

  @override
  Stream<List<MedicationOccurrenceEntity>> watchTodayOccurrences(
      String recipientId) {
    final now = DateTime.now();
    final startOfDay = DateTime.utc(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // We watch all medication schedules for this recipient reactively.
    return (_db.select(_db.medicationSchedules)
          ..where((t) =>
              t.careRecipientId.equals(recipientId) &
              t.isActive.equals(true)))
        .watch()
        .asyncMap((schedules) async {
      if (schedules.isEmpty) return <MedicationOccurrenceEntity>[];
      final ids = schedules.map((s) => s.id).toList();
      final rows = await (_db.select(_db.medicationOccurrences)
            ..where((t) =>
                t.medicationScheduleId.isIn(ids) &
                t.scheduledAt.isBetweenValues(startOfDay, endOfDay))
            ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)]))
          .get();
      return rows.map(_occurrenceToEntity).toList();
    });
  }
}
