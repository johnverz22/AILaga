import 'package:flutter_test/flutter_test.dart';
import 'package:ailaga/services/ai/local/proposals/basic_text_extractor.dart';
import 'package:ailaga/services/ai/local/proposals/proposal_models.dart';

void main() {
  group('BasicTextExtractor', () {
    final activeMeds = ['Amlodipine', 'Metformin'];
    
    test('extracts BP', () {
      final extractor = BasicTextExtractor(activeMeds: activeMeds);
      final records = extractor.extract('BP ko ay 120/80 ngayon');
      expect(records.length, 1);
      final bp = records.first as ProposedMeasurement;
      expect(bp.type, 'blood_pressure');
      expect(bp.value1, 120);
      expect(bp.value2, 80);
    });

    test('extracts Temp', () {
      final extractor = BasicTextExtractor(activeMeds: activeMeds);
      final records = extractor.extract('Lagnat 38.5 c');
      expect(records.length, 1);
      final temp = records.first as ProposedMeasurement;
      expect(temp.type, 'temperature');
      expect(temp.value1, 38.5);
      expect(temp.unit, 'c');
    });

    test('extracts Med taken', () {
      final extractor = BasicTextExtractor(activeMeds: activeMeds);
      final records = extractor.extract('uminom ako ng amlodipine');
      expect(records.length, 1);
      final med = records.first as ProposedMedicationTaken;
      expect(med.medicationName, 'Amlodipine');
    });

    test('extracts Med skipped', () {
      final extractor = BasicTextExtractor(activeMeds: activeMeds);
      final records = extractor.extract('skip ko muna metformin');
      expect(records.length, 1);
      final med = records.first as ProposedMedicationSkipped;
      expect(med.medicationName, 'Metformin');
    });
  });
}
