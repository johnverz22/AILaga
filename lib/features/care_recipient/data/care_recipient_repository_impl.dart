import 'package:drift/drift.dart';
import '../../care_recipient/domain/care_recipient_entity.dart';
import '../../care_recipient/domain/care_recipient_repository.dart';
import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';

/// Converts a Drift [CareRecipient] row to a domain [CareRecipientEntity].
CareRecipientEntity _toEntity(CareRecipient row) {
  return CareRecipientEntity(
    id: row.id,
    displayName: row.displayName,
    dateOfBirth: row.dateOfBirth,
    allergies: row.allergies,
    importantNotes: row.importantNotes,
    emergencyInfo: row.emergencyInfo,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}

class CareRecipientRepositoryImpl implements CareRecipientRepository {
  final AppDatabase _db;

  CareRecipientRepositoryImpl(this._db);

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  @override
  Future<CareRecipientEntity?> getById(String id) async {
    try {
      final row = await (_db.select(_db.careRecipients)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return row == null ? null : _toEntity(row);
    } on Exception catch (e) {
      throw DatabaseException('Failed to get care recipient by id: $id', cause: e);
    }
  }

  @override
  Future<CareRecipientEntity?> getPrimary() async {
    try {
      final row = await (_db.select(_db.careRecipients)
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
            ..limit(1))
          .getSingleOrNull();
      return row == null ? null : _toEntity(row);
    } on Exception catch (e) {
      throw DatabaseException('Failed to get primary care recipient', cause: e);
    }
  }

  @override
  Future<List<CareRecipientEntity>> getAll() async {
    try {
      final rows = await (_db.select(_db.careRecipients)
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();
      return rows.map(_toEntity).toList();
    } on Exception catch (e) {
      throw DatabaseException('Failed to get all care recipients', cause: e);
    }
  }

  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------

  @override
  Future<void> create(CareRecipientEntity entity) async {
    try {
      await _db.into(_db.careRecipients).insert(
            CareRecipientsCompanion.insert(
              id: entity.id,
              displayName: entity.displayName,
              dateOfBirth: Value(entity.dateOfBirth),
              allergies: Value(entity.allergies),
              importantNotes: Value(entity.importantNotes),
              emergencyInfo: Value(entity.emergencyInfo),
              createdAt: entity.createdAt,
              updatedAt: entity.updatedAt,
            ),
          );
    } on Exception catch (e) {
      throw DatabaseException('Failed to create care recipient', cause: e);
    }
  }

  @override
  Future<void> update(CareRecipientEntity entity) async {
    try {
      await (_db.update(_db.careRecipients)
            ..where((t) => t.id.equals(entity.id)))
          .write(
        CareRecipientsCompanion(
          displayName: Value(entity.displayName),
          dateOfBirth: Value(entity.dateOfBirth),
          allergies: Value(entity.allergies),
          importantNotes: Value(entity.importantNotes),
          emergencyInfo: Value(entity.emergencyInfo),
          updatedAt: Value(entity.updatedAt),
        ),
      );
    } on Exception catch (e) {
      throw DatabaseException('Failed to update care recipient', cause: e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await (_db.delete(_db.careRecipients)..where((t) => t.id.equals(id)))
          .go();
    } on Exception catch (e) {
      throw DatabaseException('Failed to delete care recipient: $id', cause: e);
    }
  }

  // ---------------------------------------------------------------------------
  // Streams
  // ---------------------------------------------------------------------------

  @override
  Stream<CareRecipientEntity?> watchPrimary() {
    return (_db.select(_db.careRecipients)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(1))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _toEntity(row));
  }
}
