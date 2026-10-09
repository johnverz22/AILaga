import 'package:drift/drift.dart';
import '../domain/measurement_entity.dart';
import '../domain/measurement_repository.dart';
import '../domain/measurement_type.dart';
import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';

// ---------------------------------------------------------------------------
// Mapper
// ---------------------------------------------------------------------------

MeasurementEntity _toEntity(MeasurementLog row) {
  return MeasurementEntity(
    id: row.id,
    careRecipientId: row.careRecipientId,
    measurementType: MeasurementType.fromDatabaseValue(row.measurementType),
    value1: row.value1,
    value2: row.value2,
    unit: row.unit,
    measuredAt: row.measuredAt,
    recordedAt: row.recordedAt,
    sourceType: row.sourceType,
    sourceLabel: row.sourceLabel,
    notes: row.notes,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

class MeasurementRepositoryImpl implements MeasurementRepository {
  final AppDatabase _db;

  MeasurementRepositoryImpl(this._db);

  // -------------------------------------------------------------------------
  // Read
  // -------------------------------------------------------------------------

  @override
  Future<List<MeasurementEntity>> getByRecipient(
    String recipientId, {
    MeasurementType? type,
  }) async {
    try {
      final query = _db.select(_db.measurementLogs)
        ..where((t) {
          final byRecipient = t.careRecipientId.equals(recipientId);
          if (type != null) {
            return byRecipient & t.measurementType.equals(type.databaseValue);
          }
          return byRecipient;
        })
        ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)]);
      final rows = await query.get();
      return rows.map(_toEntity).toList();
    } on Exception catch (e) {
      throw DatabaseException('Failed to get measurements for recipient', cause: e);
    }
  }

  @override
  Future<List<MeasurementEntity>> getForDateRange(
    String recipientId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final rows = await (_db.select(_db.measurementLogs)
            ..where((t) =>
                t.careRecipientId.equals(recipientId) &
                t.measuredAt.isBetweenValues(start.toUtc(), end.toUtc()))
            ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)]))
          .get();
      return rows.map(_toEntity).toList();
    } on Exception catch (e) {
      throw DatabaseException('Failed to get measurements for date range', cause: e);
    }
  }

  @override
  Future<MeasurementEntity?> getLatest(
    String recipientId,
    MeasurementType type,
  ) async {
    try {
      final row = await (_db.select(_db.measurementLogs)
            ..where((t) =>
                t.careRecipientId.equals(recipientId) &
                t.measurementType.equals(type.databaseValue))
            ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)])
            ..limit(1))
          .getSingleOrNull();
      return row == null ? null : _toEntity(row);
    } on Exception catch (e) {
      throw DatabaseException('Failed to get latest measurement', cause: e);
    }
  }

  // -------------------------------------------------------------------------
  // Write
  // -------------------------------------------------------------------------

  @override
  Future<void> create(MeasurementEntity entity) async {
    try {
      await _db.into(_db.measurementLogs).insert(
            MeasurementLogsCompanion.insert(
              id: entity.id,
              careRecipientId: entity.careRecipientId,
              measurementType: entity.measurementType.databaseValue,
              value1: entity.value1,
              value2: Value(entity.value2),
              unit: entity.unit,
              measuredAt: entity.measuredAt,
              recordedAt: entity.recordedAt,
              sourceType: Value(entity.sourceType),
              sourceLabel: Value(entity.sourceLabel),
              notes: Value(entity.notes),
              createdAt: entity.createdAt,
              updatedAt: entity.updatedAt,
            ),
          );
    } on Exception catch (e) {
      throw DatabaseException('Failed to create measurement', cause: e);
    }
  }

  @override
  Future<void> update(MeasurementEntity entity) async {
    try {
      await (_db.update(_db.measurementLogs)
            ..where((t) => t.id.equals(entity.id)))
          .write(MeasurementLogsCompanion(
        value1: Value(entity.value1),
        value2: Value(entity.value2),
        unit: Value(entity.unit),
        measuredAt: Value(entity.measuredAt),
        notes: Value(entity.notes),
        updatedAt: Value(entity.updatedAt),
      ));
    } on Exception catch (e) {
      throw DatabaseException('Failed to update measurement', cause: e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await (_db.delete(_db.measurementLogs)
            ..where((t) => t.id.equals(id)))
          .go();
    } on Exception catch (e) {
      throw DatabaseException('Failed to delete measurement: $id', cause: e);
    }
  }

  // -------------------------------------------------------------------------
  // Streams
  // -------------------------------------------------------------------------

  @override
  Stream<List<MeasurementEntity>> watchRecent(
    String recipientId, {
    int limit = 10,
  }) {
    return (_db.select(_db.measurementLogs)
          ..where((t) => t.careRecipientId.equals(recipientId))
          ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)])
          ..limit(limit))
        .watch()
        .map((rows) => rows.map(_toEntity).toList());
  }
}
