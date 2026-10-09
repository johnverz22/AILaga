import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/report_service.dart';
import 'pdf_report_service.dart';
import '../../care_recipient/data/care_recipient_providers.dart';
import '../../medications/data/medication_providers.dart';
import '../../measurements/data/measurement_providers.dart';
import '../../appointments/data/appointment_providers.dart';
import '../../care_notes/data/care_note_providers.dart';
import '../../../services/pdf/pdf_generator.dart';

final pdfGeneratorProvider = Provider<PdfGenerator>((ref) {
  return PdfGenerator();
});

final reportServiceProvider = Provider<ReportService>((ref) {
  return PdfReportService(
    ref.watch(careRecipientRepositoryProvider),
    ref.watch(medicationRepositoryProvider),
    ref.watch(measurementRepositoryProvider),
    ref.watch(appointmentRepositoryProvider),
    ref.watch(careNoteRepositoryProvider),
    ref.watch(pdfGeneratorProvider),
  );
});
