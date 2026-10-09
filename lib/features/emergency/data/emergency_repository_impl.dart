import 'package:drift/drift.dart';
import '../domain/emergency_entity.dart';
import '../domain/emergency_repository.dart';
import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';

EmergencyEventEntity _toEntity(EmergencyEvent row) {
  return EmergencyEventEntity(
    id: row.id,
    careRecipientId: row.careRecipientId,
    triggeredAt: row.triggeredAt,
    triggerType: row.triggerType,
    cancelledAt: row.cancelledAt,
    selectedAction: row.selectedAction,
    actionStatus: row.actionStatus,
    notes: row.notes,
    createdAt: row.createdAt,
  );
}

class EmergencyRepositoryImpl implements EmergencyRepository {
  final AppDatabase _db;
  
  EmergencyRepositoryImpl(this._db);

  @override
  Future<void> create(EmergencyEventEntity entity) async {
    try {
      await _db.into(_db.emergencyEvents).insert(
        EmergencyEventsCompanion.insert(
          id: entity.id,
          careRecipientId: entity.careRecipientId,
          triggeredAt: entity.triggeredAt,
          triggerType: entity.triggerType,
          cancelledAt: Value(entity.cancelledAt),
          selectedAction: Value(entity.selectedAction),
          actionStatus: Value(entity.actionStatus),
          notes: Value(entity.notes),
          createdAt: entity.createdAt,
        ),
      );
    } catch (e) {
      throw DatabaseException('Failed to create emergency event', cause: e);
    }
  }

  @override
  Future<void> updateStatus(String id, String actionStatus, {DateTime? cancelledAt, String? selectedAction}) async {
    try {
      await (_db.update(_db.emergencyEvents)..where((t) => t.id.equals(id))).write(
        EmergencyEventsCompanion(
          actionStatus: Value(actionStatus),
          cancelledAt: cancelledAt != null ? Value(cancelledAt) : const Value.absent(),
          selectedAction: selectedAction != null ? Value(selectedAction) : const Value.absent(),
        ),
      );
    } catch (e) {
      throw DatabaseException('Failed to update emergency event', cause: e);
    }
  }

  @override
  Future<List<EmergencyEventEntity>> getByRecipient(String recipientId) async {
    try {
      final rows = await (_db.select(_db.emergencyEvents)
        ..where((t) => t.careRecipientId.equals(recipientId))
        ..orderBy([(t) => OrderingTerm.desc(t.triggeredAt)])
      ).get();
      return rows.map(_toEntity).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch emergency events', cause: e);
    }
  }

  @override
  Future<EmergencyEventEntity?> getById(String id) async {
    try {
      final row = await (_db.select(_db.emergencyEvents)..where((t) => t.id.equals(id))).getSingleOrNull();
      return row != null ? _toEntity(row) : null;
    } catch (e) {
      throw DatabaseException('Failed to fetch emergency event', cause: e);
    }
  }
}
