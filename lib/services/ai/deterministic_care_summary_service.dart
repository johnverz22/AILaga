import 'care_summary_models.dart';
import 'care_summary_service.dart';
import '../../features/medications/domain/medication_status.dart';

class DeterministicCareSummaryService implements CareSummaryService {
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Future<CareSummaryResult> generateDailyBrief(CareSummaryInput input) async {
    final StringBuffer buffer = StringBuffer();
    final now = DateTime.now();

    buffer.writeln('📋 Daily Care Brief — ${_formatDate(now)}');
    buffer.writeln('Generated: ${_formatDate(now)} ${_formatTime(now)}');
    buffer.writeln('Care Recipient: ${input.careRecipientName}');
    buffer.writeln();

    buffer.writeln('💊 Medications');
    if (input.occurrences.isEmpty) {
      buffer.writeln('No data for this period');
    } else {
      for (final occ in input.occurrences) {
        final timeStr = _formatTime(occ.scheduledAt);
        final medName = 'Medication'; 
        switch (occ.status) {
          case MedicationStatus.taken:
            buffer.writeln('✅ $medName — Taken at ${occ.statusUpdatedAt != null ? _formatTime(occ.statusUpdatedAt!) : timeStr}');
            break;
          case MedicationStatus.pending:
            buffer.writeln('⏳ $medName — Pending (scheduled $timeStr)');
            break;
          case MedicationStatus.skipped:
            buffer.writeln('⊘ $medName — Skipped at ${occ.statusUpdatedAt != null ? _formatTime(occ.statusUpdatedAt!) : timeStr}');
            break;
          case MedicationStatus.notConfirmed:
            buffer.writeln('❓ $medName — Not confirmed');
            break;
        }
      }
    }
    buffer.writeln();

    buffer.writeln('📊 Recent Measurements');
    if (input.measurements.isEmpty) {
      buffer.writeln('No data for this period');
    } else {
      for (final m in input.measurements) {
        final val2Str = m.value2 != null ? '/${m.value2}' : '';
        buffer.writeln('${m.measurementType.name}: ${m.value1}$val2Str ${m.unit} (${m.sourceType}, ${_formatTime(m.measuredAt)})');
      }
    }
    buffer.writeln();

    buffer.writeln('📅 Today\'s Appointments');
    if (input.appointments.isEmpty) {
      buffer.writeln('No data for this period');
    } else {
      for (final appt in input.appointments) {
        buffer.writeln('${_formatTime(appt.scheduledAt)} — ${appt.providerOrFacility ?? 'Unknown'} — ${appt.purpose ?? 'Checkup'}');
      }
    }
    buffer.writeln();

    buffer.writeln('⚠️ Items Requiring Attention');
    if (input.unresolvedTasks.isEmpty) {
      buffer.writeln('No data for this period');
    } else {
      for (final task in input.unresolvedTasks) {
        buffer.writeln('- $task');
      }
    }
    buffer.writeln();

    buffer.writeln('📝 Recent Observations');
    if (input.notes.isEmpty) {
      buffer.writeln('No data for this period');
    } else {
      for (final note in input.notes) {
        buffer.writeln('${_formatTime(note.observedAt)} — ${note.originalText}');
      }
    }

    final sourceRecordIds = [
      ...input.occurrences.map((e) => e.id),
      ...input.measurements.map((e) => e.id),
      ...input.appointments.map((e) => e.id),
      ...input.notes.map((e) => e.id),
    ];

    return CareSummaryResult(
      summaryText: buffer.toString(),
      sourceRecordIds: sourceRecordIds,
      unconfirmedItems: input.unresolvedTasks,
      ambiguousStatements: [],
      status: GenerationStatus.success,
    );
  }

  @override
  Future<CareSummaryResult> generateHandover(CareSummaryInput input) async {
    final StringBuffer buffer = StringBuffer();
    final now = DateTime.now();

    buffer.writeln('🤝 Caregiver Handover');
    buffer.writeln('Period: ${_formatDate(input.periodStart)} to ${_formatDate(input.periodEnd)}');
    buffer.writeln('Prepared by: AILaga');
    buffer.writeln('Generated: ${_formatDate(now)} ${_formatTime(now)}');
    buffer.writeln();

    buffer.writeln('✅ Completed');
    bool hasCompleted = false;
    for (final occ in input.occurrences.where((o) => o.status == MedicationStatus.taken)) {
      buffer.writeln('- Medication taken at ${_formatTime(occ.statusUpdatedAt ?? occ.scheduledAt)}');
      hasCompleted = true;
    }
    for (final appt in input.appointments.where((a) => a.status == 'completed')) {
      buffer.writeln('- ${appt.purpose ?? 'Appointment'} completed');
      hasCompleted = true;
    }
    if (!hasCompleted) buffer.writeln('No data for this period');
    buffer.writeln();

    buffer.writeln('⏳ Needs Attention');
    if (input.unresolvedTasks.isEmpty) {
      buffer.writeln('No data for this period');
    } else {
      for (final task in input.unresolvedTasks) {
        buffer.writeln('- $task');
      }
    }
    buffer.writeln();

    buffer.writeln('📊 Recent Vitals');
    if (input.measurements.isEmpty) {
      buffer.writeln('No data for this period');
    } else {
      for (final m in input.measurements) {
        final val2Str = m.value2 != null ? '/${m.value2}' : '';
        buffer.writeln('- ${m.measurementType.name}: ${m.value1}$val2Str ${m.unit} (${_formatTime(m.measuredAt)})');
      }
    }
    buffer.writeln();

    buffer.writeln('📅 Upcoming');
    final upcomingAppts = input.appointments.where((a) => a.scheduledAt.isAfter(now)).toList();
    if (upcomingAppts.isEmpty) {
      buffer.writeln('No data for this period');
    } else {
      for (final appt in upcomingAppts) {
        buffer.writeln('- ${appt.purpose ?? 'Appointment'} on ${_formatDate(appt.scheduledAt)}');
      }
    }
    buffer.writeln();

    buffer.writeln('📝 Notes');
    buffer.writeln('[caregiver can add free text here]');

    final sourceRecordIds = [
      ...input.occurrences.map((e) => e.id),
      ...input.measurements.map((e) => e.id),
      ...input.appointments.map((e) => e.id),
      ...input.notes.map((e) => e.id),
    ];

    return CareSummaryResult(
      summaryText: buffer.toString(),
      sourceRecordIds: sourceRecordIds,
      unconfirmedItems: input.unresolvedTasks,
      ambiguousStatements: [],
      status: GenerationStatus.success,
    );
  }

  @override
  Future<StructuredCareNoteResult> structureCareNote(String originalText) async {
    return StructuredCareNoteResult(
      structuredText: originalText,
      originalText: originalText,
      ambiguousItems: [],
      requiresReview: true,
    );
  }
}
