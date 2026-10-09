import 'medication_entity.dart';
import 'medication_status.dart';

abstract class MedicationRepository {
  Future<List<MedicationScheduleEntity>> getActiveSchedules(String recipientId);
  Future<List<MedicationScheduleEntity>> getAllSchedules(String recipientId);
  Future<MedicationScheduleEntity?> getScheduleById(String id);
  Future<void> createSchedule(MedicationScheduleEntity entity);
  Future<void> updateSchedule(MedicationScheduleEntity entity);
  Future<void> deactivateSchedule(String id);
  Stream<List<MedicationScheduleEntity>> watchActiveSchedules(String recipientId);
  Future<List<MedicationOccurrenceEntity>> getOccurrencesForDate(String scheduleId, DateTime date);
  Future<List<MedicationOccurrenceEntity>> getOccurrencesForDateRange(String recipientId, DateTime start, DateTime end);
  Future<List<MedicationOccurrenceEntity>> getPendingOccurrences(String recipientId);
  Future<void> generateOccurrences(String scheduleId, DateTime fromDate, DateTime toDate);
  Future<void> updateOccurrenceStatus(String occurrenceId, MedicationStatus status, {String? note});
  Stream<List<MedicationOccurrenceEntity>> watchTodayOccurrences(String recipientId);
}
