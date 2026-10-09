import 'appointment_entity.dart';

abstract class AppointmentRepository {
  Future<List<AppointmentEntity>> getByRecipient(String recipientId);
  Future<List<AppointmentEntity>> getForDateRange(String recipientId, DateTime start, DateTime end);
  Future<AppointmentEntity?> getById(String id);
  Future<AppointmentEntity?> getNextUpcoming(String recipientId);
  Future<void> create(AppointmentEntity entity);
  Future<void> update(AppointmentEntity entity);
  Future<void> updateStatus(String id, String status);
  Future<void> delete(String id);
  Stream<List<AppointmentEntity>> watchUpcoming(String recipientId);
}
