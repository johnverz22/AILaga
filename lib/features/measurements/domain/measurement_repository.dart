import 'measurement_entity.dart';
import 'measurement_type.dart';

abstract class MeasurementRepository {
  Future<List<MeasurementEntity>> getByRecipient(String recipientId, {MeasurementType? type});
  Future<List<MeasurementEntity>> getForDateRange(String recipientId, DateTime start, DateTime end);
  Future<MeasurementEntity?> getLatest(String recipientId, MeasurementType type);
  Future<void> create(MeasurementEntity entity);
  Future<void> update(MeasurementEntity entity);
  Future<void> delete(String id);
  Stream<List<MeasurementEntity>> watchRecent(String recipientId, {int limit = 10});
}
