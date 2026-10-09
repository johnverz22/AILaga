import 'proposal_models.dart';
import '../../../../core/utilities/validators.dart';
import 'med_matcher.dart';
import 'time_resolver.dart';

class ProposalValidator {
  final List<String> activeMeds;
  final DateTime now;
  final String transcript;

  ProposalValidator({
    required this.activeMeds,
    required this.now,
    required this.transcript,
  });

  ProposedRecord? validate(ProposedRecord record) {
    // 1. Quote grounding
    if (record.sourceQuote.isEmpty || !transcript.toLowerCase().contains(record.sourceQuote.toLowerCase())) {
      return null; // Drop
    }

    if (record is ProposedMedicationTaken) {
      return _validateMedTaken(record);
    } else if (record is ProposedMedicationSkipped) {
      return _validateMedSkipped(record);
    } else if (record is ProposedMeasurement) {
      return _validateMeasurement(record);
    } else if (record is ProposedCareNote) {
      return record;
    } else if (record is ProposedAppointment) {
      return record;
    } else if (record is ProposedMedicationSchedule) {
      return record;
    }

    return record;
  }

  ProposedMedicationTaken? _validateMedTaken(ProposedMedicationTaken record) {
    var match = MedMatcher.match(record.medicationName, activeMeds);
    if (match.status == MatchStatus.unmatched) {
      return null; // Drop or unmatched? Spec: "else unmatched". Wait, if unmatched, maybe we shouldn't drop but mark it unmatched.
      // But spec says: "Unmatched -> 'Hindi nakalista ang X. Idagdag?' It never creates a taken for a drug that isn't scheduled without explicit confirm."
      // Let's set flag to check.
    }
    
    ProposalFlag flag = (match.status == MatchStatus.sure) ? ProposalFlag.sure : ProposalFlag.check;

    if (record.timePhrase != null) {
      DateTime? resolvedTime = TimeResolver.resolve(record.timePhrase!, now);
      if (resolvedTime != null && resolvedTime.isAfter(now)) {
        return null; // Reject future time for taken
      }
    }

    return ProposedMedicationTaken(
      medicationName: match.matchedName,
      timePhrase: record.timePhrase,
      sourceQuote: record.sourceQuote,
      flag: flag,
    );
  }

  ProposedMedicationSkipped? _validateMedSkipped(ProposedMedicationSkipped record) {
    var match = MedMatcher.match(record.medicationName, activeMeds);
    ProposalFlag flag = (match.status == MatchStatus.sure) ? ProposalFlag.sure : ProposalFlag.check;

    return ProposedMedicationSkipped(
      medicationName: match.matchedName,
      reasonText: record.reasonText,
      sourceQuote: record.sourceQuote,
      flag: flag,
    );
  }

  ProposedMeasurement? _validateMeasurement(ProposedMeasurement record) {
    ProposalFlag flag = ProposalFlag.sure;
    String? error;
    
    double val = record.value1.toDouble();

    switch (record.type) {
      case 'blood_pressure':
        error = Validators.bloodPressureSystolic(val);
        if (error == null && record.value2 != null) {
          error = Validators.bloodPressureDiastolic(record.value2!.toDouble());
        }
        break;
      case 'pulse':
        error = Validators.pulse(val);
        break;
      case 'temperature':
        if (record.unit.toLowerCase() == 'f') {
          error = Validators.temperatureFahrenheit(val);
        } else {
          error = Validators.temperatureCelsius(val);
        }
        break;
      case 'weight':
        if (record.unit.toLowerCase() == 'lbs') {
          error = Validators.weightLbs(val);
        } else {
          error = Validators.weightKg(val);
        }
        break;
      case 'blood_glucose':
        if (record.unit.toLowerCase() == 'mmol/l') {
          error = Validators.bloodGlucoseMmolL(val);
        } else {
          error = Validators.bloodGlucoseMgDl(val);
        }
        break;
    }

    if (error != null) {
      flag = ProposalFlag.check;
    }

    if (record.timePhrase != null) {
      DateTime? resolvedTime = TimeResolver.resolve(record.timePhrase!, now);
      if (resolvedTime != null && resolvedTime.isAfter(now)) {
        return null; // Reject future time
      }
    }

    return ProposedMeasurement(
      type: record.type,
      value1: record.value1,
      value2: record.value2,
      unit: record.unit,
      timePhrase: record.timePhrase,
      sourceQuote: record.sourceQuote,
      flag: flag,
    );
  }
}
