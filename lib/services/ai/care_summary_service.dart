import 'care_summary_models.dart';

abstract interface class CareSummaryService {
  Future<CareSummaryResult> generateDailyBrief(CareSummaryInput input);
  Future<CareSummaryResult> generateHandover(CareSummaryInput input);
  Future<StructuredCareNoteResult> structureCareNote(String originalText);
}
