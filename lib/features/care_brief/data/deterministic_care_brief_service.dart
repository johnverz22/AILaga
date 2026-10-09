import 'package:intl/intl.dart';

import '../domain/care_brief_entity.dart';
import '../domain/care_brief_service.dart';
import '../../care_recipient/domain/care_recipient_repository.dart';
import '../../medications/domain/medication_repository.dart';
import '../../medications/domain/medication_status.dart';
import '../../measurements/domain/measurement_repository.dart';
import '../../appointments/domain/appointment_repository.dart';
import '../../care_notes/domain/care_note_repository.dart';
import '../../../core/utils/date_formatter.dart';

class DeterministicCareBriefService implements CareBriefService {
  final CareRecipientRepository _careRecipientRepo;
  final MedicationRepository _medicationRepo;
  final MeasurementRepository _measurementRepo;
  final AppointmentRepository _appointmentRepo;
  final CareNoteRepository _careNoteRepo;

  DeterministicCareBriefService(
    this._careRecipientRepo,
    this._medicationRepo,
    this._measurementRepo,
    this._appointmentRepo,
    this._careNoteRepo,
  );

  @override
  Future<CareBriefEntity> generateBrief({
    required String recipientId,
    required DateTime periodStart,
    required DateTime periodEnd,
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

    // Map to Brief Items — resolve the real medication name from the
    // schedule; an occurrence only stores the schedule's ID.
    final schedules = await _medicationRepo.getAllSchedules(recipientId);
    final medNameById = {for (final s in schedules) s.id: s.medicationName};

    final medBriefItems = occurrences
        .map((o) => MedicationBriefItem(
              id: o.id,
              name: medNameById[o.medicationScheduleId] ?? 'Medication',
              status: o.status.name,
              scheduledTime:
                  o.scheduledAt, // Use scheduledAt instead of scheduledTime
              statusTime: o.statusUpdatedAt ??
                  o.createdAt, // Use statusUpdatedAt or fallback to createdAt
            ))
        .toList();

    final measBriefItems = measurements
        .map((m) => MeasurementBriefItem(
              id: m.id,
              type:
                  m.measurementType.name, // Use measurementType instead of type
              value: m.value1.toString(), // Use value1 instead of value
              unit: m.unit,
              timestamp: m.measuredAt, // Use measuredAt instead of timestamp
              source: m.sourceType,
            ))
        .toList();

    final apptBriefItems = appointments
        .map((a) => AppointmentBriefItem(
              id: a.id,
              providerName: a.providerOrFacility ??
                  'Unknown Provider', // Use providerOrFacility instead of providerName
              purpose: a.purpose ?? 'Appointment', // Handle nullable purpose
              date: a.scheduledAt, // Use scheduledAt instead of date
            ))
        .toList();

    final noteBriefItems = notes
        .map((n) => CareNoteBriefItem(
              id: n.id,
              text: n.originalText,
              timestamp: n.observedAt,
            ))
        .toList();

    final unconfirmedMeds =
        occurrences.where((o) => o.status == MedicationStatus.pending).toList();
    final unreviewedNotes = notes
        .where((n) =>
            n.reviewStatus == 'pending' || n.reviewStatus == 'unreviewed')
        .toList();

    final itemsRequiringReview = <String>[];
    if (unconfirmedMeds.isNotEmpty) {
      itemsRequiringReview.add(
          '${unconfirmedMeds.length} unconfirmed ${unconfirmedMeds.length == 1 ? 'medication' : 'medications'}');
    }
    if (unreviewedNotes.isNotEmpty) {
      itemsRequiringReview.add(
          '${unreviewedNotes.length} unreviewed care ${unreviewedNotes.length == 1 ? 'note' : 'notes'}');
    }

    // Generate formatted text
    final buffer = StringBuffer();
    final dateFormatter = DateFormat('MMMM d, yyyy');

    buffer
        .writeln('📋 Daily Care Brief — ${dateFormatter.format(periodStart)}');
    buffer
        .writeln('Generated: ${DateFormatter.formatDateTime(DateTime.now())}');
    buffer.writeln('Care Recipient: $name');
    buffer.writeln();

    buffer.writeln('💊 Medications');
    if (occurrences.isEmpty) {
      buffer.writeln('No data for this period');
    } else {
      for (final med in medBriefItems) {
        final timeStr = DateFormatter.formatTime(med.scheduledTime);
        if (med.status == 'taken') {
          buffer.writeln('✅ ${med.name} — Taken at $timeStr');
        } else if (med.status == 'skipped') {
          buffer.writeln('⊘ ${med.name} — Skipped at $timeStr');
        } else {
          final now = DateTime.now();
          if (med.scheduledTime.isBefore(now)) {
            buffer
                .writeln('❓ ${med.name} — Not confirmed (scheduled $timeStr)');
          } else {
            buffer.writeln('⏳ ${med.name} — Pending (scheduled $timeStr)');
          }
        }
      }
    }
    buffer.writeln();

    buffer.writeln('📊 Recent Measurements');
    if (measurements.isEmpty) {
      buffer.writeln('No data for this period');
    } else {
      for (final m in measBriefItems) {
        buffer.writeln(
            '${m.type}: ${m.value} ${m.unit} (${m.source}, ${DateFormatter.formatTime(m.timestamp)})');
      }
    }
    buffer.writeln();

    buffer.writeln('📅 Today\'s Appointments');
    if (appointments.isEmpty) {
      buffer.writeln('No data for this period');
    } else {
      for (final a in apptBriefItems) {
        buffer.writeln(
            '${DateFormatter.formatTime(a.date)} — ${a.providerName} — ${a.purpose}');
      }
    }
    buffer.writeln();

    buffer.writeln('⚠️ Items Requiring Attention');
    if (itemsRequiringReview.isEmpty) {
      buffer.writeln('None');
    } else {
      for (final item in itemsRequiringReview) {
        buffer.writeln('- $item');
      }
    }
    buffer.writeln();

    buffer.writeln('📝 Recent Observations');
    if (notes.isEmpty) {
      buffer.writeln('No data for this period');
    } else {
      for (final n in noteBriefItems) {
        buffer.writeln('${DateFormatter.formatTime(n.timestamp)} — ${n.text}');
      }
    }

    return CareBriefEntity(
      generatedAt: DateTime.now(),
      periodStart: periodStart,
      periodEnd: periodEnd,
      careRecipientName: name,
      medicationStatuses: medBriefItems,
      recentMeasurements: measBriefItems,
      todayAppointments: apptBriefItems,
      unconfirmedTasks: [], // We use itemsRequiringReview primarily
      recentObservations: noteBriefItems,
      itemsRequiringReview: itemsRequiringReview,
      formattedText: buffer.toString().trim(),
    );
  }
}
