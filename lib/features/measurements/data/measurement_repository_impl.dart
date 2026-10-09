import '../../measurements/domain/measurement_entity.dart';
import '../../measurements/domain/measurement_type.dart';
import '../../measurements/domain/measurement_repository.dart';
import '../../../core/database/app_database.dart';

class MeasurementRepositoryImpl implements MeasurementRepository {
  final AppDatabase _db;
  
  MeasurementRepositoryImpl(this._db);

  @override
  Future<List<MeasurementEntity>> getByRecipient(String recipientId, {MeasurementType? type}) {
    throw UnimplementedError('TODO: Implement getByRecipient');
  }

  @override
  Future<List<MeasurementEntity>> getForDateRange(String recipientId, DateTime start, DateTime end) {
    throw UnimplementedError('TODO: Implement getForDateRange');
  }

  @override
  Future<MeasurementEntity?> getLatest(String recipientId, MeasurementType type) {
    throw UnimplementedError('TODO: Implement getLatest');
  }

  @override
  Future<void> create(MeasurementEntity entity) {
    throw UnimplementedError('TODO: Implement create');
  }

  @override
  Future<void> update(MeasurementEntity entity) {
    throw UnimplementedError('TODO: Implement update');
  }

  @override
  Future<void> delete(String id) {
    throw UnimplementedError('TODO: Implement delete');
  }

  @override
  Stream<List<MeasurementEntity>> watchRecent(String recipientId, {int limit = 10}) {
    throw UnimplementedError('TODO: Implement watchRecent');
  }
}
