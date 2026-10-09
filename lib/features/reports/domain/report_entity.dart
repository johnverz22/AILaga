import 'dart:typed_data';

class ReportEntity {
  final DateTime generatedAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String careRecipientName;
  final Uint8List pdfBytes;

  const ReportEntity({
    required this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.careRecipientName,
    required this.pdfBytes,
  });
}
