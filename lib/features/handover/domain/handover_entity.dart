class HandoverEntity {
  final DateTime generatedAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String careRecipientName;
  final String? caregiverName;
  final List<String> completedTasks;
  final List<String> unconfirmedItems;
  final List<String> relevantObservations;
  final List<String> upcomingAppointments;
  final List<String> recentMeasurements;
  final String formattedText;

  const HandoverEntity({
    required this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.careRecipientName,
    this.caregiverName,
    required this.completedTasks,
    required this.unconfirmedItems,
    required this.relevantObservations,
    required this.upcomingAppointments,
    required this.recentMeasurements,
    required this.formattedText,
  });
}
