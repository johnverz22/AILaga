import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../domain/medication_entity.dart';
import '../domain/medication_repository.dart';
import 'medication_repository_impl.dart';

final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return MedicationRepositoryImpl(db);
});

/// Watches all active medication schedules for the given care recipient.
final activeSchedulesProvider =
    StreamProvider.family<List<MedicationScheduleEntity>, String>(
  (ref, recipientId) {
    final repo = ref.watch(medicationRepositoryProvider);
    return repo.watchActiveSchedules(recipientId);
  },
);

/// Watches today's occurrences for the given care recipient.
final todayOccurrencesProvider =
    StreamProvider.family<List<MedicationOccurrenceEntity>, String>(
  (ref, recipientId) {
    final repo = ref.watch(medicationRepositoryProvider);
    return repo.watchTodayOccurrences(recipientId);
  },
);
