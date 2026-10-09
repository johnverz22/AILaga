import 'package:drift/drift.dart';
import '../../family_contacts/domain/family_contact_entity.dart';
import '../../family_contacts/domain/family_contact_repository.dart';
import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';

/// Converts a Drift [FamilyContact] row to a domain [FamilyContactEntity].
FamilyContactEntity _toEntity(FamilyContact row) {
  return FamilyContactEntity(
    id: row.id,
    careRecipientId: row.careRecipientId,
    displayName: row.displayName,
    relationship: row.relationship,
    phoneNumber: row.phoneNumber,
    isEmergencyContact: row.isEmergencyContact,
    sortOrder: row.sortOrder,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}

class FamilyContactRepositoryImpl implements FamilyContactRepository {
  final AppDatabase _db;

  FamilyContactRepositoryImpl(this._db);

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  @override
  Future<List<FamilyContactEntity>> getByCareRecipient(
      String recipientId) async {
    try {
      final rows = await (_db.select(_db.familyContacts)
            ..where((t) => t.careRecipientId.equals(recipientId))
            ..orderBy([
              (t) => OrderingTerm.asc(t.sortOrder),
              (t) => OrderingTerm.asc(t.createdAt),
            ]))
          .get();
      return rows.map(_toEntity).toList();
    } on Exception catch (e) {
      throw DatabaseException(
          'Failed to get contacts for recipient: $recipientId',
          cause: e);
    }
  }

  @override
  Future<List<FamilyContactEntity>> getEmergencyContacts(
      String recipientId) async {
    try {
      final rows = await (_db.select(_db.familyContacts)
            ..where((t) =>
                t.careRecipientId.equals(recipientId) &
                t.isEmergencyContact.equals(true))
            ..orderBy([
              (t) => OrderingTerm.asc(t.sortOrder),
              (t) => OrderingTerm.asc(t.createdAt),
            ]))
          .get();
      return rows.map(_toEntity).toList();
    } on Exception catch (e) {
      throw DatabaseException(
          'Failed to get emergency contacts for recipient: $recipientId',
          cause: e);
    }
  }

  @override
  Future<FamilyContactEntity?> getById(String id) async {
    try {
      final row = await (_db.select(_db.familyContacts)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return row == null ? null : _toEntity(row);
    } on Exception catch (e) {
      throw DatabaseException('Failed to get contact by id: $id', cause: e);
    }
  }

  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------

  @override
  Future<void> create(FamilyContactEntity entity) async {
    try {
      await _db.into(_db.familyContacts).insert(
            FamilyContactsCompanion.insert(
              id: entity.id,
              careRecipientId: entity.careRecipientId,
              displayName: entity.displayName,
              relationship: Value(entity.relationship),
              phoneNumber: entity.phoneNumber,
              isEmergencyContact:
                  Value(entity.isEmergencyContact),
              sortOrder: Value(entity.sortOrder),
              createdAt: entity.createdAt,
              updatedAt: entity.updatedAt,
            ),
          );
    } on Exception catch (e) {
      throw DatabaseException('Failed to create family contact', cause: e);
    }
  }

  @override
  Future<void> update(FamilyContactEntity entity) async {
    try {
      await (_db.update(_db.familyContacts)
            ..where((t) => t.id.equals(entity.id)))
          .write(
        FamilyContactsCompanion(
          displayName: Value(entity.displayName),
          relationship: Value(entity.relationship),
          phoneNumber: Value(entity.phoneNumber),
          isEmergencyContact: Value(entity.isEmergencyContact),
          sortOrder: Value(entity.sortOrder),
          updatedAt: Value(entity.updatedAt),
        ),
      );
    } on Exception catch (e) {
      throw DatabaseException('Failed to update family contact', cause: e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await (_db.delete(_db.familyContacts)..where((t) => t.id.equals(id)))
          .go();
    } on Exception catch (e) {
      throw DatabaseException('Failed to delete family contact: $id', cause: e);
    }
  }

  /// Updates the [sortOrder] for all contacts in [orderedIds] in a transaction.
  @override
  Future<void> reorder(List<String> orderedIds) async {
    try {
      await _db.transaction(() async {
        final now = DateTime.now().toUtc();
        for (var i = 0; i < orderedIds.length; i++) {
          await (_db.update(_db.familyContacts)
                ..where((t) => t.id.equals(orderedIds[i])))
              .write(FamilyContactsCompanion(
            sortOrder: Value(i),
            updatedAt: Value(now),
          ));
        }
      });
    } on Exception catch (e) {
      throw DatabaseException('Failed to reorder family contacts', cause: e);
    }
  }

  // ---------------------------------------------------------------------------
  // Streams
  // ---------------------------------------------------------------------------

  @override
  Stream<List<FamilyContactEntity>> watchByCareRecipient(String recipientId) {
    return (_db.select(_db.familyContacts)
          ..where((t) => t.careRecipientId.equals(recipientId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .watch()
        .map((rows) => rows.map(_toEntity).toList());
  }
}
