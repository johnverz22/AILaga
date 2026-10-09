import 'package:drift/drift.dart';
import '../domain/appointment_entity.dart';
import '../domain/appointment_repository.dart';
import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';

// ---------------------------------------------------------------------------
// Mapper
// ---------------------------------------------------------------------------

AppointmentEntity _toEntity(Appointment row) {
  return AppointmentEntity(
    id: row.id,
    careRecipientId: row.careRecipientId,
    providerOrFacility: row.providerOrFacility,
    purpose: row.purpose,
    scheduledAt: row.scheduledAt,
    notes: row.notes,
    status: row.status,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppDatabase _db;

  AppointmentRepositoryImpl(this._db);

  // -------------------------------------------------------------------------
  // Read
  // -------------------------------------------------------------------------

  @override
  Future<List<AppointmentEntity>> getByRecipient(String recipientId) async {
    try {
      final rows = await (_db.select(_db.appointments)
            ..where((t) => t.careRecipientId.equals(recipientId))
            ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)]))
          .get();
      return rows.map(_toEntity).toList();
    } on Exception catch (e) {
      throw DatabaseException('Failed to get appointments', cause: e);
    }
  }

  @override
  Future<List<AppointmentEntity>> getForDateRange(
    String recipientId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final rows = await (_db.select(_db.appointments)
            ..where((t) =>
                t.careRecipientId.equals(recipientId) &
                t.scheduledAt.isBetweenValues(start.toUtc(), end.toUtc()))
            ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)]))
          .get();
      return rows.map(_toEntity).toList();
    } on Exception catch (e) {
      throw DatabaseException('Failed to get appointments for date range', cause: e);
    }
  }

  @override
  Future<AppointmentEntity?> getById(String id) async {
    try {
      final row = await (_db.select(_db.appointments)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return row == null ? null : _toEntity(row);
    } on Exception catch (e) {
      throw DatabaseException('Failed to get appointment: $id', cause: e);
    }
  }

  @override
  Future<AppointmentEntity?> getNextUpcoming(String recipientId) async {
    try {
      final now = DateTime.now().toUtc();
      final row = await (_db.select(_db.appointments)
            ..where((t) =>
                t.careRecipientId.equals(recipientId) &
                t.scheduledAt.isBiggerThanValue(now) &
                t.status.equals('scheduled'))
            ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)])
            ..limit(1))
          .getSingleOrNull();
      return row == null ? null : _toEntity(row);
    } on Exception catch (e) {
      throw DatabaseException('Failed to get next upcoming appointment', cause: e);
    }
  }

  // -------------------------------------------------------------------------
  // Write
  // -------------------------------------------------------------------------

  @override
  Future<void> create(AppointmentEntity entity) async {
    try {
      await _db.into(_db.appointments).insert(
            AppointmentsCompanion.insert(
              id: entity.id,
              careRecipientId: entity.careRecipientId,
              providerOrFacility: Value(entity.providerOrFacility),
              purpose: Value(entity.purpose),
              scheduledAt: entity.scheduledAt,
              notes: Value(entity.notes),
              status: Value(entity.status),
              createdAt: entity.createdAt,
              updatedAt: entity.updatedAt,
            ),
          );
    } on Exception catch (e) {
      throw DatabaseException('Failed to create appointment', cause: e);
    }
  }

  @override
  Future<void> update(AppointmentEntity entity) async {
    try {
      await (_db.update(_db.appointments)
            ..where((t) => t.id.equals(entity.id)))
          .write(AppointmentsCompanion(
        providerOrFacility: Value(entity.providerOrFacility),
        purpose: Value(entity.purpose),
        scheduledAt: Value(entity.scheduledAt),
        notes: Value(entity.notes),
        status: Value(entity.status),
        updatedAt: Value(entity.updatedAt),
      ));
    } on Exception catch (e) {
      throw DatabaseException('Failed to update appointment', cause: e);
    }
  }

  @override
  Future<void> updateStatus(String id, String status) async {
    try {
      final now = DateTime.now().toUtc();
      await (_db.update(_db.appointments)
            ..where((t) => t.id.equals(id)))
          .write(AppointmentsCompanion(
        status: Value(status),
        updatedAt: Value(now),
      ));
    } on Exception catch (e) {
      throw DatabaseException('Failed to update appointment status: $id', cause: e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await (_db.delete(_db.appointments)..where((t) => t.id.equals(id))).go();
    } on Exception catch (e) {
      throw DatabaseException('Failed to delete appointment: $id', cause: e);
    }
  }

  // -------------------------------------------------------------------------
  // Streams
  // -------------------------------------------------------------------------

  @override
  Stream<List<AppointmentEntity>> watchUpcoming(String recipientId) {
    final now = DateTime.now().toUtc();
    return (_db.select(_db.appointments)
          ..where((t) =>
              t.careRecipientId.equals(recipientId) &
              t.scheduledAt.isBiggerOrEqualValue(now) &
              t.status.equals('scheduled'))
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)]))
        .watch()
        .map((rows) => rows.map(_toEntity).toList());
  }
}
