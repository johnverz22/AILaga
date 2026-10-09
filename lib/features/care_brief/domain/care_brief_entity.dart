class CareBriefEntity {
  final DateTime generatedAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String careRecipientName;
  final List<MedicationBriefItem> medicationStatuses;
  final List<MeasurementBriefItem> recentMeasurements;
  final List<AppointmentBriefItem> todayAppointments;
  final List<String> unconfirmedTasks;
  final List<CareNoteBriefItem> recentObservations;
  final List<String> itemsRequiringReview;
  final String formattedText;

  const CareBriefEntity({
    required this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.careRecipientName,
    required this.medicationStatuses,
    required this.recentMeasurements,
    required this.todayAppointments,
    required this.unconfirmedTasks,
    required this.recentObservations,
    required this.itemsRequiringReview,
    required this.formattedText,
  });
}

class MedicationBriefItem {
  final String id;
  final String name;
  final String status;
  final DateTime scheduledTime;
  final DateTime? statusTime;

  const MedicationBriefItem({
    required this.id,
    required this.name,
    required this.status,
    required this.scheduledTime,
    this.statusTime,
  });
}

class MeasurementBriefItem {
  final String id;
  final String type;
  final String value;
  final String unit;
  final DateTime timestamp;
  final String source;

  const MeasurementBriefItem({
    required this.id,
    required this.type,
    required this.value,
    required this.unit,
    required this.timestamp,
    required this.source,
  });
}

class AppointmentBriefItem {
  final String id;
  final String providerName;
  final String purpose;
  final DateTime date;

  const AppointmentBriefItem({
    required this.id,
    required this.providerName,
    required this.purpose,
    required this.date,
  });
}

class CareNoteBriefItem {
  final String id;
  final String text;
  final DateTime timestamp;

  const CareNoteBriefItem({
    required this.id,
    required this.text,
    required this.timestamp,
  });
}
