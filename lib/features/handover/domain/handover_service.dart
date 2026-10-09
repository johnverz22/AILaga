import 'handover_entity.dart';

abstract interface class HandoverService {
  Future<HandoverEntity> generateHandover({
    required String recipientId,
    required DateTime periodStart,
    required DateTime periodEnd,
    String? caregiverName,
  });
}
