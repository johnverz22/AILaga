import 'package:flutter_test/flutter_test.dart';
import 'package:ailaga/core/utilities/date_utils.dart';

void main() {
  group('AppDateUtils.formatRelativeTime', () {
    test('returns "just now" for a time < 60s ago', () {
      final dt = DateTime.now().subtract(const Duration(seconds: 10));
      expect(AppDateUtils.formatRelativeTime(dt), 'just now');
    });

    test('returns minutes ago for < 1h', () {
      final dt = DateTime.now().subtract(const Duration(minutes: 5));
      expect(AppDateUtils.formatRelativeTime(dt), '5 minutes ago');
    });

    test('returns singular "minute" for 1 minute ago', () {
      final dt = DateTime.now().subtract(const Duration(minutes: 1));
      expect(AppDateUtils.formatRelativeTime(dt), '1 minute ago');
    });

    test('returns hours ago for < 24h', () {
      final dt = DateTime.now().subtract(const Duration(hours: 3));
      expect(AppDateUtils.formatRelativeTime(dt), '3 hours ago');
    });

    test('returns days ago for < 7 days', () {
      final dt = DateTime.now().subtract(const Duration(days: 2));
      expect(AppDateUtils.formatRelativeTime(dt), '2 days ago');
    });

    test('returns weeks ago for 7–29 days', () {
      final dt = DateTime.now().subtract(const Duration(days: 14));
      expect(AppDateUtils.formatRelativeTime(dt), '2 weeks ago');
    });

    test('returns "in X minutes" for a future time', () {
      final dt = DateTime.now().add(const Duration(minutes: 10));
      expect(AppDateUtils.formatRelativeTime(dt), 'in 10 minutes');
    });

    test('returns "in a moment" for near-future (< 60s)', () {
      final dt = DateTime.now().add(const Duration(seconds: 30));
      expect(AppDateUtils.formatRelativeTime(dt), 'in a moment');
    });
  });

  group('AppDateUtils.isSameDay', () {
    test('same day returns true', () {
      final a = DateTime(2026, 10, 9, 10, 0);
      final b = DateTime(2026, 10, 9, 22, 59);
      expect(AppDateUtils.isSameDay(a, b), isTrue);
    });

    test('different day returns false', () {
      final a = DateTime(2026, 10, 9);
      final b = DateTime(2026, 10, 10);
      expect(AppDateUtils.isSameDay(a, b), isFalse);
    });
  });

  group('AppDateUtils.startOfDay / endOfDay', () {
    test('startOfDay is midnight UTC', () {
      final dt = DateTime(2026, 10, 9, 15, 30).toLocal();
      final start = AppDateUtils.startOfDay(dt);
      final local = start.toLocal();
      expect(local.hour, 0);
      expect(local.minute, 0);
      expect(local.second, 0);
    });

    test('endOfDay is 23:59:59.999 UTC', () {
      final dt = DateTime(2026, 10, 9, 8, 0).toLocal();
      final end = AppDateUtils.endOfDay(dt);
      final local = end.toLocal();
      expect(local.hour, 23);
      expect(local.minute, 59);
      expect(local.second, 59);
      expect(local.millisecond, 999);
    });
  });

  group('AppDateUtils.isValidTimeString', () {
    test('accepts valid HH:mm', () {
      expect(AppDateUtils.isValidTimeString('08:30'), isTrue);
      expect(AppDateUtils.isValidTimeString('00:00'), isTrue);
      expect(AppDateUtils.isValidTimeString('23:59'), isTrue);
    });

    test('rejects invalid formats', () {
      expect(AppDateUtils.isValidTimeString('8:30'), isFalse);
      expect(AppDateUtils.isValidTimeString('25:00'), isFalse);
      expect(AppDateUtils.isValidTimeString('08:60'), isFalse);
      expect(AppDateUtils.isValidTimeString('abc'), isFalse);
      expect(AppDateUtils.isValidTimeString(''), isFalse);
    });
  });

  group('AppDateUtils.scheduledTimeOnDate', () {
    test('returns correct DateTime for a given HH:mm on a date', () {
      final date = DateTime(2026, 10, 9);
      final result = AppDateUtils.scheduledTimeOnDate('14:30', date);
      expect(result.hour, 14);
      expect(result.minute, 30);
      expect(result.day, 9);
      expect(result.month, 10);
      expect(result.year, 2026);
    });
  });

  group('AppDateUtils.toUtc / toLocal', () {
    test('round-trip UTC → local preserves time', () {
      final now = DateTime.now();
      final utc = AppDateUtils.toUtc(now);
      final local = AppDateUtils.toLocal(utc);
      expect(local.isAtSameMomentAs(now), isTrue);
    });
  });

  group('AppDateUtils.formatDate', () {
    test('formats correctly', () {
      // Use a fixed date to avoid locale/timezone flakiness.
      final dt = DateTime(2026, 10, 9);
      final result = AppDateUtils.formatDate(dt);
      // Should contain "Oct", "9", "2026"
      expect(result, contains('Oct'));
      expect(result, contains('9'));
      expect(result, contains('2026'));
    });
  });
}
