import '../../features/medications/domain/medication_entity.dart';
import '../../features/measurements/domain/measurement_entity.dart';
import '../../features/appointments/domain/appointment_entity.dart';
import '../../features/care_notes/domain/care_note_entity.dart';

enum GenerationStatus { success, partial, fallback, error }

class CareSummaryInput {
  final DateTime periodStart;
  final DateTime periodEnd;
  final String careRecipientName;
  final List<MedicationOccurrenceEntity> occurrences;
  final List<MeasurementEntity> measurements;
  final List<AppointmentEntity> appointments;
  final List<CareNoteEntity> notes;
  final List<String> unresolvedTasks;

  const CareSummaryInput({
    required this.periodStart,
    required this.periodEnd,
    required this.careRecipientName,
    required this.occurrences,
    required this.measurements,
    required this.appointments,
    required this.notes,
    required this.unresolvedTasks,
  });
}

class CareSummaryResult {
  final String summaryText;
  final List<String> sourceRecordIds;
  final List<String> unconfirmedItems;
  final List<String> ambiguousStatements;
  final GenerationStatus status;

  const CareSummaryResult({
    required this.summaryText,
    required this.sourceRecordIds,
    required this.unconfirmedItems,
    required this.ambiguousStatements,
    required this.status,
  });
}

class StructuredCareNoteResult {
  final String structuredText;
  final String originalText;
  final List<String> ambiguousItems;
  final bool requiresReview;

  const StructuredCareNoteResult({
    required this.structuredText,
    required this.originalText,
    required this.ambiguousItems,
    required this.requiresReview,
  });
}
