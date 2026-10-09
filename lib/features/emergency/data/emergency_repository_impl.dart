import '../../emergency/domain/emergency_entity.dart';
import '../../emergency/domain/emergency_repository.dart';
import '../../../core/database/app_database.dart';

class EmergencyRepositoryImpl implements EmergencyRepository {
  final AppDatabase _db;
  
  EmergencyRepositoryImpl(this._db);

  @override
  Future<void> create(EmergencyEventEntity entity) {
    throw UnimplementedError('TODO: Implement create');
  }

  @override
  Future<void> updateStatus(String id, String actionStatus, {DateTime? cancelledAt, String? selectedAction}) {
    throw UnimplementedError('TODO: Implement updateStatus');
  }

  @override
  Future<List<EmergencyEventEntity>> getByRecipient(String recipientId) {
    throw UnimplementedError('TODO: Implement getByRecipient');
  }

  @override
  Future<EmergencyEventEntity?> getById(String id) {
    throw UnimplementedError('TODO: Implement getById');
  }
}
