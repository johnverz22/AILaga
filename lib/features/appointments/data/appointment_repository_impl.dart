import '../../appointments/domain/appointment_entity.dart';
import '../../appointments/domain/appointment_repository.dart';
import '../../../core/database/app_database.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppDatabase _db;
  
  AppointmentRepositoryImpl(this._db);

  @override
  Future<List<AppointmentEntity>> getByRecipient(String recipientId) {
    throw UnimplementedError('TODO: Implement getByRecipient');
  }

  @override
  Future<List<AppointmentEntity>> getForDateRange(String recipientId, DateTime start, DateTime end) {
    throw UnimplementedError('TODO: Implement getForDateRange');
  }

  @override
  Future<AppointmentEntity?> getById(String id) {
    throw UnimplementedError('TODO: Implement getById');
  }

  @override
  Future<AppointmentEntity?> getNextUpcoming(String recipientId) {
    throw UnimplementedError('TODO: Implement getNextUpcoming');
  }

  @override
  Future<void> create(AppointmentEntity entity) {
    throw UnimplementedError('TODO: Implement create');
  }

  @override
  Future<void> update(AppointmentEntity entity) {
    throw UnimplementedError('TODO: Implement update');
  }

  @override
  Future<void> updateStatus(String id, String status) {
    throw UnimplementedError('TODO: Implement updateStatus');
  }

  @override
  Future<void> delete(String id) {
    throw UnimplementedError('TODO: Implement delete');
  }

  @override
  Stream<List<AppointmentEntity>> watchUpcoming(String recipientId) {
    throw UnimplementedError('TODO: Implement watchUpcoming');
  }
}
