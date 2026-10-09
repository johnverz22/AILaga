enum MeasurementType {
  bloodPressure,
  pulse,
  temperature,
  weight,
  bloodGlucose;

  String get databaseValue {
    switch (this) {
      case MeasurementType.bloodPressure: return 'blood_pressure';
      case MeasurementType.pulse: return 'pulse';
      case MeasurementType.temperature: return 'temperature';
      case MeasurementType.weight: return 'weight';
      case MeasurementType.bloodGlucose: return 'blood_glucose';
    }
  }

  static MeasurementType fromDatabaseValue(String value) {
    switch (value) {
      case 'blood_pressure': return MeasurementType.bloodPressure;
      case 'pulse': return MeasurementType.pulse;
      case 'temperature': return MeasurementType.temperature;
      case 'weight': return MeasurementType.weight;
      case 'blood_glucose': return MeasurementType.bloodGlucose;
      default: throw ArgumentError('Unknown measurement type: $value');
    }
  }

  String get displayLabel {
    switch (this) {
      case MeasurementType.bloodPressure: return 'Blood Pressure';
      case MeasurementType.pulse: return 'Pulse';
      case MeasurementType.temperature: return 'Temperature';
      case MeasurementType.weight: return 'Weight';
      case MeasurementType.bloodGlucose: return 'Blood Glucose';
    }
  }

  String get defaultUnit {
    switch (this) {
      case MeasurementType.bloodPressure: return 'mmHg';
      case MeasurementType.pulse: return 'bpm';
      case MeasurementType.temperature: return '°C';
      case MeasurementType.weight: return 'kg';
      case MeasurementType.bloodGlucose: return 'mg/dL';
    }
  }

  bool get hasTwoValues => this == MeasurementType.bloodPressure;
}
