import 'report_entity.dart';

abstract interface class ReportService {
  Future<ReportEntity> generateReport({
    required String recipientId,
    required DateTime periodStart,
    required DateTime periodEnd,
  });
}
