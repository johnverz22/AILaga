import 'package:intl/intl.dart';

import '../domain/handover_entity.dart';
import '../domain/handover_service.dart';
import '../../care_recipient/domain/care_recipient_repository.dart';
import '../../medications/domain/medication_repository.dart';
import '../../medications/domain/medication_status.dart';
import '../../measurements/domain/measurement_repository.dart';
import '../../appointments/domain/appointment_repository.dart';
import '../../care_notes/domain/care_note_repository.dart';
import '../../../core/utils/date_formatter.dart';

class DeterministicHandoverService implements HandoverService {
  final CareRecipientRepository _careRecipientRepo;
  final MedicationRepository _medicationRepo;
  final MeasurementRepository _measurementRepo;
  final AppointmentRepository _appointmentRepo;
  final CareNoteRepository _careNoteRepo;

  DeterministicHandoverService(
    this._careRecipientRepo,
    this._medicationRepo,
    this._measurementRepo,
    this._appointmentRepo,
    this._careNoteRepo,
  );

  @override
  Future<HandoverEntity> generateHandover({
    required String recipientId,
    required DateTime periodStart,
    required DateTime periodEnd,
    String? caregiverName,
  }) async {
    final recipient = await _careRecipientRepo.getById(recipientId);
    final name = recipient?.displayName ?? 'Unknown';

    final occurrences = await _medicationRepo.getOccurrencesForDateRange(
        recipientId, periodStart, periodEnd);
    final measurements = await _measurementRepo.getForDateRange(
        recipientId, periodStart, periodEnd);
    final appointments = await _appointmentRepo.getForDateRange(
        recipientId, periodStart, periodEnd);
    final notes = await _careNoteRepo.getForDateRange(
        recipientId, periodStart, periodEnd);

    // For upcoming appointments, query from periodEnd onwards up to 7 days
    final upcomingAppointmentsData = await _appointmentRepo.getForDateRange(
      recipientId,
      periodEnd,
      periodEnd.add(const Duration(days: 7)),
    );

    final completedTasks = <String>[];
    final unconfirmedItems = <String>[];
    final relevantObservations = <String>[];
    final recentMeasurements = <String>[];
    final upcomingAppointments = <String>[];

    final now = DateTime.now();

    for (final o in occurrences) {
      final timeStr = DateFormatter.formatTime(
          o.scheduledAt); // Use scheduledAt instead of scheduledTime
      if (o.status == MedicationStatus.taken) {
        completedTasks.add(
            '${o.medicationScheduleId} taken at $timeStr'); // Use medicationScheduleId instead of medicationName
      } else if (o.status == MedicationStatus.pending &&
          o.scheduledAt.isBefore(now)) {
        // Use scheduledAt instead of scheduledTime
        unconfirmedItems.add(
            '${o.medicationScheduleId} not confirmed since $timeStr'); // Use medicationScheduleId instead of medicationName
      }
    }

    for (final a in appointments) {
      completedTasks.add('${a.purpose} appointment completed');
    }

    for (final n in notes) {
      if (n.reviewStatus == 'pending' || n.reviewStatus == 'unreviewed') {
        unconfirmedItems.add(
            'Care note from ${DateFormatter.formatTime(n.observedAt)} unreviewed');
      }
      relevantObservations
          .add('${DateFormatter.formatTime(n.observedAt)}: ${n.originalText}');
    }

    for (final m in measurements) {
      recentMeasurements.add(
          '${m.measurementType.name}: ${m.value1} ${m.unit} (${DateFormatter.formatTime(m.measuredAt)})'); // Use measurementType.name, value1, and measuredAt
    }

    final dateFormatter = DateFormat('MMM d');
    for (final a in upcomingAppointmentsData) {
      upcomingAppointments.add(
          '${a.purpose} with ${a.providerOrFacility ?? 'Unknown Provider'} on ${dateFormatter.format(a.scheduledAt)}'); // Use providerOrFacility and scheduledAt
    }

    final buffer = StringBuffer();
    final fullDateFormatter = DateFormat('MMMM d, yyyy');

    buffer.writeln('🤝 Caregiver Handover');
    buffer.writeln(
        'Period: ${fullDateFormatter.format(periodStart)} to ${fullDateFormatter.format(periodEnd)}');
    if (caregiverName != null && caregiverName.isNotEmpty) {
      buffer.writeln('Prepared by: $caregiverName');
    }
    buffer
        .writeln('Generated: ${DateFormatter.formatDateTime(DateTime.now())}');
    buffer.writeln();

    buffer.writeln('✅ Completed');
    if (completedTasks.isEmpty) {
      buffer.writeln('- None');
    } else {
      for (final t in completedTasks) {
        buffer.writeln('- $t');
      }
    }
    buffer.writeln();

    buffer.writeln('⏳ Needs Attention');
    if (unconfirmedItems.isEmpty) {
      buffer.writeln('- None');
    } else {
      for (final i in unconfirmedItems) {
        buffer.writeln('- $i');
      }
    }
    buffer.writeln();

    buffer.writeln('📊 Recent Vitals');
    if (recentMeasurements.isEmpty) {
      buffer.writeln('- None');
    } else {
      for (final m in recentMeasurements) {
        buffer.writeln('- $m');
      }
    }
    buffer.writeln();

    buffer.writeln('📅 Upcoming');
    if (upcomingAppointments.isEmpty) {
      buffer.writeln('- None in the next 7 days');
    } else {
      for (final a in upcomingAppointments) {
        buffer.writeln('- $a');
      }
    }
    buffer.writeln();

    buffer.writeln('📝 Notes');
    buffer.writeln('[Add any additional notes here]');

    return HandoverEntity(
      generatedAt: DateTime.now(),
      periodStart: periodStart,
      periodEnd: periodEnd,
      careRecipientName: name,
      caregiverName: caregiverName,
      completedTasks: completedTasks,
      unconfirmedItems: unconfirmedItems,
      relevantObservations: relevantObservations,
      upcomingAppointments: upcomingAppointments,
      recentMeasurements: recentMeasurements,
      formattedText: buffer.toString(),
    );
  }
}
