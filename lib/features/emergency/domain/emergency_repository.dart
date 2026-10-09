import 'emergency_entity.dart';

abstract class EmergencyRepository {
  Future<void> create(EmergencyEventEntity entity);
  Future<void> updateStatus(String id, String actionStatus, {DateTime? cancelledAt, String? selectedAction});
  Future<List<EmergencyEventEntity>> getByRecipient(String recipientId);
  Future<EmergencyEventEntity?> getById(String id);
}
