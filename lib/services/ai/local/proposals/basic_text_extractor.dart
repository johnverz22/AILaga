import 'proposal_models.dart';

class BasicTextExtractor {
  final List<String> activeMeds;

  BasicTextExtractor({required this.activeMeds});

  List<ProposedRecord> extract(String text) {
    List<ProposedRecord> records = [];
    String lowerText = text.toLowerCase();

    // Blood Pressure
    RegExp bpRegex = RegExp(r'(\d{2,3})\s*(?:/|over)\s*(\d{2,3})');
    for (var match in bpRegex.allMatches(lowerText)) {
      records.add(ProposedMeasurement(
        type: 'blood_pressure',
        value1: int.parse(match.group(1)!),
        value2: int.parse(match.group(2)!),
        unit: 'mmHg',
        sourceQuote: text.substring(match.start, match.end),
      ));
    }

    // Temperature
    RegExp tempRegex = RegExp(r'(\d{2}(?:\.\d)?)\s*(c|f|celsius|fahrenheit)?\s*(?:temp|lagnat)');
    for (var match in tempRegex.allMatches(lowerText)) {
      String unit = match.group(2) ?? 'c';
      if (unit.startsWith('f')) {
        unit = 'f';
      } else {
        unit = 'c';
      }
      records.add(ProposedMeasurement(
        type: 'temperature',
        value1: double.parse(match.group(1)!),
        unit: unit,
        sourceQuote: text.substring(match.start, match.end),
      ));
    }
    
    // Fallback: temp before value
    RegExp tempRegex2 = RegExp(r'(?:temp|lagnat)\s*(\d{2}(?:\.\d)?)\s*(c|f|celsius|fahrenheit)?');
    for (var match in tempRegex2.allMatches(lowerText)) {
      String unit = match.group(2) ?? 'c';
      if (unit.startsWith('f')) {
        unit = 'f';
      } else {
        unit = 'c';
      }
      records.add(ProposedMeasurement(
        type: 'temperature',
        value1: double.parse(match.group(1)!),
        unit: unit,
        sourceQuote: text.substring(match.start, match.end),
      ));
    }

    // Known med names + verbs
    RegExp takenVerb = RegExp(r'\b(uminom|nainom|binigyan|took|taken)\b');
    RegExp skipVerb = RegExp(r'\b(skip|skipped|hindi uminom|di uminom)\b');
    
    for (String med in activeMeds) {
      if (lowerText.contains(med.toLowerCase())) {
        int idx = lowerText.indexOf(med.toLowerCase());
        String quote = text.substring(idx, idx + med.length);
        
        if (skipVerb.hasMatch(lowerText)) {
          records.add(ProposedMedicationSkipped(
            medicationName: med,
            sourceQuote: quote,
          ));
        } else if (takenVerb.hasMatch(lowerText)) {
          records.add(ProposedMedicationTaken(
            medicationName: med,
            sourceQuote: quote,
          ));
        } else {
          // If just mentioned, default to taken
          records.add(ProposedMedicationTaken(
            medicationName: med,
            sourceQuote: quote,
          ));
        }
      }
    }

    return records;
  }
}
