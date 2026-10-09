import '../../medications/domain/medication_entity.dart';
import '../../medications/domain/medication_status.dart';
import '../../medications/domain/medication_repository.dart';
import '../../../core/database/app_database.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final AppDatabase _db;
  
  MedicationRepositoryImpl(this._db);

  @override
  Future<List<MedicationScheduleEntity>> getActiveSchedules(String recipientId) {
    throw UnimplementedError('TODO: Implement getActiveSchedules');
  }

  @override
  Future<List<MedicationScheduleEntity>> getAllSchedules(String recipientId) {
    throw UnimplementedError('TODO: Implement getAllSchedules');
  }

  @override
  Future<MedicationScheduleEntity?> getScheduleById(String id) {
    throw UnimplementedError('TODO: Implement getScheduleById');
  }

  @override
  Future<void> createSchedule(MedicationScheduleEntity entity) {
    throw UnimplementedError('TODO: Implement createSchedule');
  }

  @override
  Future<void> updateSchedule(MedicationScheduleEntity entity) {
    throw UnimplementedError('TODO: Implement updateSchedule');
  }

  @override
  Future<void> deactivateSchedule(String id) {
    throw UnimplementedError('TODO: Implement deactivateSchedule');
  }

  @override
  Stream<List<MedicationScheduleEntity>> watchActiveSchedules(String recipientId) {
    throw UnimplementedError('TODO: Implement watchActiveSchedules');
  }

  @override
  Future<List<MedicationOccurrenceEntity>> getOccurrencesForDate(String scheduleId, DateTime date) {
    throw UnimplementedError('TODO: Implement getOccurrencesForDate');
  }

  @override
  Future<List<MedicationOccurrenceEntity>> getOccurrencesForDateRange(String recipientId, DateTime start, DateTime end) {
    throw UnimplementedError('TODO: Implement getOccurrencesForDateRange');
  }

  @override
  Future<List<MedicationOccurrenceEntity>> getPendingOccurrences(String recipientId) {
    throw UnimplementedError('TODO: Implement getPendingOccurrences');
  }

  @override
  Future<void> generateOccurrences(String scheduleId, DateTime fromDate, DateTime toDate) {
    throw UnimplementedError('TODO: Implement generateOccurrences');
  }

  @override
  Future<void> updateOccurrenceStatus(String occurrenceId, MedicationStatus status, {String? note}) {
    throw UnimplementedError('TODO: Implement updateOccurrenceStatus');
  }

  @override
  Stream<List<MedicationOccurrenceEntity>> watchTodayOccurrences(String recipientId) {
    throw UnimplementedError('TODO: Implement watchTodayOccurrences');
  }
}
