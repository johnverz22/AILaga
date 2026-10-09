import 'package:flutter_test/flutter_test.dart';
import 'package:ailaga/core/utilities/validators.dart';

void main() {
  group('Validators.required', () {
    test('returns error for null', () {
      expect(Validators.required(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.required(''), isNotNull);
    });

    test('returns error for whitespace only', () {
      expect(Validators.required('   '), isNotNull);
    });

    test('returns null for valid string', () {
      expect(Validators.required('hello'), isNull);
    });
  });

  group('Validators.phoneNumber', () {
    test('returns null for empty (optional)', () {
      expect(Validators.phoneNumber(''), isNull);
      expect(Validators.phoneNumber(null), isNull);
    });

    test('accepts valid Philippine mobile number', () {
      expect(Validators.phoneNumber('09171234567'), isNull);
      expect(Validators.phoneNumber('+63 917 123 4567'), isNull);
    });

    test('accepts valid US number', () {
      expect(Validators.phoneNumber('+1-800-555-0199'), isNull);
    });

    test('accepts local landline with area code', () {
      expect(Validators.phoneNumber('(02) 8876-5432'), isNull);
    });

    test('rejects number that is too short', () {
      expect(Validators.phoneNumber('123'), isNotNull);
    });

    test('rejects number that is too long (> 15 digits)', () {
      expect(Validators.phoneNumber('1234567890123456'), isNotNull);
    });

    test('rejects letters in number', () {
      expect(Validators.phoneNumber('abc12345'), isNotNull);
    });
  });

  group('Validators.requiredPhoneNumber', () {
    test('returns error for null', () {
      expect(Validators.requiredPhoneNumber(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.requiredPhoneNumber(''), isNotNull);
    });

    test('returns null for valid phone', () {
      expect(Validators.requiredPhoneNumber('09171234567'), isNull);
    });
  });

  group('Validators.bloodPressureSystolic', () {
    test('accepts in-range value', () {
      expect(Validators.bloodPressureSystolic(120), isNull);
    });

    test('rejects below minimum (< 50)', () {
      expect(Validators.bloodPressureSystolic(40), isNotNull);
    });

    test('rejects above maximum (> 300)', () {
      expect(Validators.bloodPressureSystolic(350), isNotNull);
    });

    test('accepts boundary values', () {
      expect(Validators.bloodPressureSystolic(50), isNull);
      expect(Validators.bloodPressureSystolic(300), isNull);
    });

    test('returns null for null input (not required)', () {
      expect(Validators.bloodPressureSystolic(null), isNull);
    });
  });

  group('Validators.bloodPressureDiastolic', () {
    test('accepts in-range value', () {
      expect(Validators.bloodPressureDiastolic(80), isNull);
    });

    test('rejects below minimum', () {
      expect(Validators.bloodPressureDiastolic(20), isNotNull);
    });

    test('rejects above maximum', () {
      expect(Validators.bloodPressureDiastolic(250), isNotNull);
    });
  });

  group('Validators.pulse', () {
    test('accepts in-range value', () {
      expect(Validators.pulse(72), isNull);
    });

    test('rejects below minimum (< 20)', () {
      expect(Validators.pulse(10), isNotNull);
    });

    test('rejects above maximum (> 300)', () {
      expect(Validators.pulse(310), isNotNull);
    });
  });

  group('Validators.temperatureCelsius', () {
    test('accepts normal body temperature', () {
      expect(Validators.temperatureCelsius(37.0), isNull);
    });

    test('rejects below 30°C', () {
      expect(Validators.temperatureCelsius(29.9), isNotNull);
    });

    test('rejects above 45°C', () {
      expect(Validators.temperatureCelsius(45.5), isNotNull);
    });
  });

  group('Validators.temperatureFahrenheit', () {
    test('accepts normal body temperature', () {
      expect(Validators.temperatureFahrenheit(98.6), isNull);
    });

    test('rejects below 86°F', () {
      expect(Validators.temperatureFahrenheit(80.0), isNotNull);
    });

    test('rejects above 113°F', () {
      expect(Validators.temperatureFahrenheit(115.0), isNotNull);
    });
  });

  group('Validators.weightKg', () {
    test('accepts valid weight', () {
      expect(Validators.weightKg(70.0), isNull);
    });

    test('rejects zero or negative', () {
      expect(Validators.weightKg(0), isNotNull);
    });

    test('rejects extreme value', () {
      expect(Validators.weightKg(600), isNotNull);
    });
  });

  group('Validators.bloodGlucoseMgDl', () {
    test('accepts in-range value', () {
      expect(Validators.bloodGlucoseMgDl(90), isNull);
    });

    test('rejects below minimum', () {
      expect(Validators.bloodGlucoseMgDl(10), isNotNull);
    });

    test('rejects above maximum', () {
      expect(Validators.bloodGlucoseMgDl(1100), isNotNull);
    });
  });

  group('Validators.bloodGlucoseMmolL', () {
    test('accepts in-range value', () {
      expect(Validators.bloodGlucoseMmolL(5.5), isNull);
    });

    test('rejects below minimum', () {
      expect(Validators.bloodGlucoseMmolL(0.5), isNotNull);
    });

    test('rejects above maximum', () {
      expect(Validators.bloodGlucoseMmolL(60.0), isNotNull);
    });
  });

  group('Validators.dateRange', () {
    test('returns null when both null', () {
      expect(Validators.dateRange(null, null), isNull);
    });

    test('returns null for valid range', () {
      expect(
        Validators.dateRange(
          DateTime(2026, 1, 1),
          DateTime(2026, 12, 31),
        ),
        isNull,
      );
    });

    test('returns error when start is after end', () {
      expect(
        Validators.dateRange(
          DateTime(2026, 12, 31),
          DateTime(2026, 1, 1),
        ),
        isNotNull,
      );
    });
  });
}
