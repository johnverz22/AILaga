enum ProposalFlag { sure, check }

sealed class ProposedRecord {
  final String sourceQuote;
  ProposalFlag flag;
  
  ProposedRecord({
    required this.sourceQuote,
    this.flag = ProposalFlag.sure,
  });
}

class ProposedMedicationTaken extends ProposedRecord {
  final String medicationName;
  final String? timePhrase;
  
  ProposedMedicationTaken({
    required this.medicationName,
    this.timePhrase,
    required super.sourceQuote,
    super.flag,
  });
}

class ProposedMedicationSkipped extends ProposedRecord {
  final String medicationName;
  final String? reasonText;
  
  ProposedMedicationSkipped({
    required this.medicationName,
    this.reasonText,
    required super.sourceQuote,
    super.flag,
  });
}

class ProposedMeasurement extends ProposedRecord {
  final String type;
  final num value1;
  final num? value2;
  final String unit;
  final String? timePhrase;
  
  ProposedMeasurement({
    required this.type,
    required this.value1,
    this.value2,
    required this.unit,
    this.timePhrase,
    required super.sourceQuote,
    super.flag,
  });
}

class ProposedCareNote extends ProposedRecord {
  final String text;
  final String? timePhrase;
  
  ProposedCareNote({
    required this.text,
    this.timePhrase,
    required super.sourceQuote,
    super.flag,
  });
}

class ProposedAppointment extends ProposedRecord {
  final String? provider;
  final String? purpose;
  final String datetimePhrase;
  
  ProposedAppointment({
    this.provider,
    this.purpose,
    required this.datetimePhrase,
    required super.sourceQuote,
    super.flag,
  });
}

class ProposedMedicationSchedule extends ProposedRecord {
  final String name;
  final String? strength;
  final String? instructionText;
  final List<String>? timesHhmm;
  
  ProposedMedicationSchedule({
    required this.name,
    this.strength,
    this.instructionText,
    this.timesHhmm,
    required super.sourceQuote,
    super.flag,
  });
}
