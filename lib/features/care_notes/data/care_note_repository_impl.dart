import 'package:drift/drift.dart';
import '../domain/care_note_entity.dart';
import '../domain/care_note_repository.dart';
import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';

// ---------------------------------------------------------------------------
// Mapper
// ---------------------------------------------------------------------------

CareNoteEntity _toEntity(CareNote row) {
  return CareNoteEntity(
    id: row.id,
    careRecipientId: row.careRecipientId,
    observedAt: row.observedAt,
    recordedAt: row.recordedAt,
    originalText: row.originalText,
    structuredSummary: row.structuredSummary,
    sourceType: row.sourceType,
    reviewStatus: row.reviewStatus,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

class CareNoteRepositoryImpl implements CareNoteRepository {
  final AppDatabase _db;

  CareNoteRepositoryImpl(this._db);

  // -------------------------------------------------------------------------
  // Read
  // -------------------------------------------------------------------------

  @override
  Future<List<CareNoteEntity>> getByRecipient(String recipientId) async {
    try {
      final rows = await (_db.select(_db.careNotes)
            ..where((t) => t.careRecipientId.equals(recipientId))
            ..orderBy([(t) => OrderingTerm.desc(t.observedAt)]))
          .get();
      return rows.map(_toEntity).toList();
    } on Exception catch (e) {
      throw DatabaseException('Failed to get care notes', cause: e);
    }
  }

  @override
  Future<List<CareNoteEntity>> getForDateRange(
    String recipientId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final rows = await (_db.select(_db.careNotes)
            ..where((t) =>
                t.careRecipientId.equals(recipientId) &
                t.observedAt.isBetweenValues(start.toUtc(), end.toUtc()))
            ..orderBy([(t) => OrderingTerm.desc(t.observedAt)]))
          .get();
      return rows.map(_toEntity).toList();
    } on Exception catch (e) {
      throw DatabaseException('Failed to get care notes for date range', cause: e);
    }
  }

  @override
  Future<CareNoteEntity?> getById(String id) async {
    try {
      final row = await (_db.select(_db.careNotes)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return row == null ? null : _toEntity(row);
    } on Exception catch (e) {
      throw DatabaseException('Failed to get care note: $id', cause: e);
    }
  }

  // -------------------------------------------------------------------------
  // Write
  // -------------------------------------------------------------------------

  /// Creates a new care note. originalText is immutable after creation;
  /// the [update] method only allows editing mutable fields.
  @override
  Future<void> create(CareNoteEntity entity) async {
    try {
      await _db.into(_db.careNotes).insert(
            CareNotesCompanion.insert(
              id: entity.id,
              careRecipientId: entity.careRecipientId,
              observedAt: entity.observedAt,
              recordedAt: entity.recordedAt,
              originalText: entity.originalText,
              structuredSummary: Value(entity.structuredSummary),
              sourceType: Value(entity.sourceType),
              reviewStatus: Value(entity.reviewStatus),
              createdAt: entity.createdAt,
              updatedAt: entity.updatedAt,
            ),
          );
    } on Exception catch (e) {
      throw DatabaseException('Failed to create care note', cause: e);
    }
  }

  /// Updates mutable fields only — originalText is NEVER modified.
  @override
  Future<void> update(CareNoteEntity entity) async {
    try {
      await (_db.update(_db.careNotes)
            ..where((t) => t.id.equals(entity.id)))
          .write(CareNotesCompanion(
        observedAt: Value(entity.observedAt),
        structuredSummary: Value(entity.structuredSummary),
        reviewStatus: Value(entity.reviewStatus),
        updatedAt: Value(entity.updatedAt),
        // originalText intentionally NOT included — it is immutable
      ));
    } on Exception catch (e) {
      throw DatabaseException('Failed to update care note', cause: e);
    }
  }

  @override
  Future<void> updateReviewStatus(String id, String status) async {
    try {
      final now = DateTime.now().toUtc();
      await (_db.update(_db.careNotes)
            ..where((t) => t.id.equals(id)))
          .write(CareNotesCompanion(
        reviewStatus: Value(status),
        updatedAt: Value(now),
      ));
    } on Exception catch (e) {
      throw DatabaseException('Failed to update review status: $id', cause: e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await (_db.delete(_db.careNotes)..where((t) => t.id.equals(id))).go();
    } on Exception catch (e) {
      throw DatabaseException('Failed to delete care note: $id', cause: e);
    }
  }

  // -------------------------------------------------------------------------
  // Streams
  // -------------------------------------------------------------------------

  @override
  Stream<List<CareNoteEntity>> watchRecent(
    String recipientId, {
    int limit = 20,
  }) {
    return (_db.select(_db.careNotes)
          ..where((t) => t.careRecipientId.equals(recipientId))
          ..orderBy([(t) => OrderingTerm.desc(t.observedAt)])
          ..limit(limit))
        .watch()
        .map((rows) => rows.map(_toEntity).toList());
  }
}
