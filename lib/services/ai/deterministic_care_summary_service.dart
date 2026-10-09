import 'care_summary_models.dart';
import 'care_summary_service.dart';

class DeterministicCareSummaryService implements CareSummaryService {
  @override
  Future<CareSummaryResult> generateDailyBrief(CareSummaryInput input) {
    throw UnimplementedError('TODO: Implement generateDailyBrief');
  }

  @override
  Future<CareSummaryResult> generateHandover(CareSummaryInput input) {
    throw UnimplementedError('TODO: Implement generateHandover');
  }

  @override
  Future<StructuredCareNoteResult> structureCareNote(String originalText) {
    throw UnimplementedError('TODO: Implement structureCareNote');
  }
}
