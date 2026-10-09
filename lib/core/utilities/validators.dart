import '../errors/app_exception.dart';

/// Validation helpers for user input across the app.
///
/// Each method either returns [null] (valid) or a human-readable error string
/// suitable for displaying in form field error labels.
///
/// For hard-fail situations (e.g. programmatic misuse), use [validate] which
/// throws a [ValidationException] instead.
class Validators {
  Validators._();

  // ---------------------------------------------------------------------------
  // Generic
  // ---------------------------------------------------------------------------

  /// Returns an error message if [value] is null or blank; otherwise null.
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  /// Throws [ValidationException] if [validator] returns a non-null error.
  static void validate(
    String? Function() validator, {
    String? field,
  }) {
    final error = validator();
    if (error != null) {
      throw ValidationException(error, field: field);
    }
  }

  // ---------------------------------------------------------------------------
  // Date range
  // ---------------------------------------------------------------------------

  /// Returns an error if [start] is after [end].
  static String? dateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return null;
    if (start.isAfter(end)) {
      return 'Start date must be before end date.';
    }
    return null;
  }

  /// Returns an error if [date] is in the future.
  static String? notFuture(DateTime? date, {String fieldName = 'Date'}) {
    if (date == null) return null;
    if (date.isAfter(DateTime.now())) {
      return '$fieldName cannot be in the future.';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Phone number
  // ---------------------------------------------------------------------------

  /// Validates a phone number in a flexible, non-country-locked way.
  ///
  /// Accepts formats like:
  ///   +63 917 123 4567
  ///   09171234567
  ///   +1-800-555-0199
  ///   (02) 8876-5432
  ///
  /// Rules:
  ///  - After stripping whitespace, dashes, parentheses, and +, at least 7
  ///    and at most 15 digits must remain (E.164 max is 15 digits).
  ///  - May start with + (international prefix).
  static String? phoneNumber(String? value,
      {String fieldName = 'Phone number'}) {
    if (value == null || value.trim().isEmpty) return null; // optional by default
    final cleaned = value.replaceAll(RegExp(r'[\s\-().+]'), '');
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return '$fieldName contains invalid characters.';
    }
    if (cleaned.length < 7 || cleaned.length > 15) {
      return '$fieldName must be between 7 and 15 digits.';
    }
    return null;
  }

  /// Same as [phoneNumber] but treats an empty value as invalid (required).
  static String? requiredPhoneNumber(String? value,
      {String fieldName = 'Phone number'}) {
    final req = required(value, fieldName: fieldName);
    if (req != null) return req;
    return phoneNumber(value, fieldName: fieldName);
  }

  // ---------------------------------------------------------------------------
  // Measurement ranges
  // ---------------------------------------------------------------------------

  /// Blood pressure systolic — 50 to 300 mmHg.
  static String? bloodPressureSystolic(double? value) {
    return _range(value, min: 50, max: 300, label: 'Systolic BP', unit: 'mmHg');
  }

  /// Blood pressure diastolic — 30 to 200 mmHg.
  static String? bloodPressureDiastolic(double? value) {
    return _range(value, min: 30, max: 200, label: 'Diastolic BP', unit: 'mmHg');
  }

  /// Pulse / heart rate — 20 to 300 bpm.
  static String? pulse(double? value) {
    return _range(value, min: 20, max: 300, label: 'Pulse', unit: 'bpm');
  }

  /// Body temperature in Celsius — 30 to 45 °C.
  static String? temperatureCelsius(double? value) {
    return _range(value, min: 30, max: 45, label: 'Temperature', unit: '°C');
  }

  /// Body temperature in Fahrenheit — 86 to 113 °F.
  static String? temperatureFahrenheit(double? value) {
    return _range(value, min: 86, max: 113, label: 'Temperature', unit: '°F');
  }

  /// Body weight in kg — 1 to 500 kg.
  static String? weightKg(double? value) {
    return _range(value, min: 1, max: 500, label: 'Weight', unit: 'kg');
  }

  /// Body weight in lbs — 2 to 1100 lbs.
  static String? weightLbs(double? value) {
    return _range(value, min: 2, max: 1100, label: 'Weight', unit: 'lbs');
  }

  /// Blood glucose in mg/dL — 20 to 1000 mg/dL.
  static String? bloodGlucoseMgDl(double? value) {
    return _range(value,
        min: 20, max: 1000, label: 'Blood glucose', unit: 'mg/dL');
  }

  /// Blood glucose in mmol/L — 1.1 to 55.5 mmol/L.
  static String? bloodGlucoseMmolL(double? value) {
    return _range(value,
        min: 1.1, max: 55.5, label: 'Blood glucose', unit: 'mmol/L');
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  static String? _range(
    double? value, {
    required double min,
    required double max,
    required String label,
    required String unit,
  }) {
    if (value == null) return null;
    if (value < min || value > max) {
      return '$label must be between $min and $max $unit. '
          'The entered value ($value $unit) appears out of range — '
          'please double-check before saving.';
    }
    return null;
  }
}
