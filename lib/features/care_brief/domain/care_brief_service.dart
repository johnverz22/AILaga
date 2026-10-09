import 'care_brief_entity.dart';

abstract class CareBriefService {
  Future<CareBriefEntity> generateBrief({
    required String recipientId,
    required DateTime periodStart,
    required DateTime periodEnd,
  });
}
