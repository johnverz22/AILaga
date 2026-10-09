
import '../domain/report_entity.dart';
import '../domain/report_service.dart';
import '../../care_recipient/domain/care_recipient_repository.dart';
import '../../medications/domain/medication_repository.dart';
import '../../measurements/domain/measurement_repository.dart';
import '../../appointments/domain/appointment_repository.dart';
import '../../care_notes/domain/care_note_repository.dart';
import '../../../services/pdf/pdf_generator.dart';

class PdfReportService implements ReportService {
  final CareRecipientRepository _careRecipientRepo;
  final MedicationRepository _medicationRepo;
  final MeasurementRepository _measurementRepo;
  final AppointmentRepository _appointmentRepo;
  final CareNoteRepository _careNoteRepo;
  final PdfGenerator _pdfGenerator;

  PdfReportService(
    this._careRecipientRepo,
    this._medicationRepo,
    this._measurementRepo,
    this._appointmentRepo,
    this._careNoteRepo,
    this._pdfGenerator,
  );

  @override
  Future<ReportEntity> generateReport({
    required String recipientId,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    final recipient = await _careRecipientRepo.getById(recipientId);
    final name = recipient?.displayName ?? 'Unknown';

    final occurrences = await _medicationRepo.getOccurrencesForDateRange(recipientId, periodStart, periodEnd);
    final measurements = await _measurementRepo.getForDateRange(recipientId, periodStart, periodEnd);
    final appointments = await _appointmentRepo.getForDateRange(recipientId, periodStart, periodEnd);
    final notes = await _careNoteRepo.getForDateRange(recipientId, periodStart, periodEnd);

    final pdfBytes = await _pdfGenerator.generate(
      recipientName: name,
      periodStart: periodStart,
      periodEnd: periodEnd,
      occurrences: occurrences,
      measurements: measurements,
      appointments: appointments,
      notes: notes,
    );

    return ReportEntity(
      generatedAt: DateTime.now(),
      periodStart: periodStart,
      periodEnd: periodEnd,
      careRecipientName: name,
      pdfBytes: pdfBytes,
    );
  }
}
