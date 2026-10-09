import 'proposal_models.dart';
import '../../../../core/utilities/validators.dart';
import 'med_matcher.dart';
import 'time_resolver.dart';

class ProposalValidator {
  /// Deterministic range check shared by the validator and the confirm
  /// use case (defense in depth: out-of-range values are never persisted,
  /// even if a flagged proposal somehow reaches confirm).
  static String? measurementRangeError(
      String type, num value1, num? value2, String unit) {
    final val = value1.toDouble();
    switch (type) {
      case 'blood_pressure':
        final e = Validators.bloodPressureSystolic(val);
        if (e != null) return e;
        if (value2 != null) {
          return Validators.bloodPressureDiastolic(value2.toDouble());
        }
        return null;
      case 'pulse':
        return Validators.pulse(val);
      case 'temperature':
        return unit.toLowerCase() == 'f'
            ? Validators.temperatureFahrenheit(val)
            : Validators.temperatureCelsius(val);
      case 'weight':
        return unit.toLowerCase() == 'lbs'
            ? Validators.weightLbs(val)
            : Validators.weightKg(val);
      case 'blood_glucose':
        return unit.toLowerCase() == 'mmol/l'
            ? Validators.bloodGlucoseMmolL(val)
            : Validators.bloodGlucoseMgDl(val);
      default:
        return null;
    }
  }

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
    // Spec §5.5: unmatched is NOT silently dropped — it stays visible as a
    // Check card ("Hindi nakalista ang X"). Confirm never writes a "taken"
    // for an unscheduled drug (the use case finds no schedule and leaves
    // the proposal pending), so the caregiver must act on it explicitly.
    ProposalFlag flag = (match.status == MatchStatus.sure) ? ProposalFlag.sure : ProposalFlag.check;

    if (record.timePhrase != null) {
      DateTime? resolvedTime = TimeResolver.resolve(record.timePhrase!, now);
      if (resolvedTime != null && resolvedTime.isAfter(now)) {
        return null; // Reject future time for taken
      }
      if (resolvedTime == null) {
        flag = ProposalFlag.check; // Ambiguous time → Check (spec S-3)
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
    final error = measurementRangeError(
        record.type, record.value1, record.value2, record.unit);

    if (error != null) {
      flag = ProposalFlag.check;
    }

    if (record.timePhrase != null) {
      DateTime? resolvedTime = TimeResolver.resolve(record.timePhrase!, now);
      if (resolvedTime != null && resolvedTime.isAfter(now)) {
        return null; // Reject future time
      }
      // Unresolvable phrase → ambiguous time → Check (spec S-3), not Sure.
      if (resolvedTime == null) {
        flag = ProposalFlag.check;
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
