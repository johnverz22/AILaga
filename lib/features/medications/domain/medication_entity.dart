import 'medication_status.dart';

class MedicationScheduleEntity {
  final String id;
  final String careRecipientId;
  final String medicationName;
  final String? prescribedInstructions;
  final String scheduleTimes; // JSON string
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MedicationScheduleEntity({
    required this.id,
    required this.careRecipientId,
    required this.medicationName,
    this.prescribedInstructions,
    required this.scheduleTimes,
    required this.startDate,
    this.endDate,
    this.notes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  MedicationScheduleEntity copyWith({
    String? id,
    String? careRecipientId,
    String? medicationName,
    String? prescribedInstructions,
    String? scheduleTimes,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicationScheduleEntity(
      id: id ?? this.id,
      careRecipientId: careRecipientId ?? this.careRecipientId,
      medicationName: medicationName ?? this.medicationName,
      prescribedInstructions: prescribedInstructions ?? this.prescribedInstructions,
      scheduleTimes: scheduleTimes ?? this.scheduleTimes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MedicationOccurrenceEntity {
  final String id;
  final String medicationScheduleId;
  final DateTime scheduledAt;
  final MedicationStatus status;
  final DateTime? statusUpdatedAt;
  final String? statusNote;
  final String? recordedByLabel;
  final DateTime createdAt;

  const MedicationOccurrenceEntity({
    required this.id,
    required this.medicationScheduleId,
    required this.scheduledAt,
    required this.status,
    this.statusUpdatedAt,
    this.statusNote,
    this.recordedByLabel,
    required this.createdAt,
  });

  MedicationOccurrenceEntity copyWith({
    String? id,
    String? medicationScheduleId,
    DateTime? scheduledAt,
    MedicationStatus? status,
    DateTime? statusUpdatedAt,
    String? statusNote,
    String? recordedByLabel,
    DateTime? createdAt,
  }) {
    return MedicationOccurrenceEntity(
      id: id ?? this.id,
      medicationScheduleId: medicationScheduleId ?? this.medicationScheduleId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
      statusNote: statusNote ?? this.statusNote,
      recordedByLabel: recordedByLabel ?? this.recordedByLabel,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
