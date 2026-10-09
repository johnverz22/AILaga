import 'package:intl/intl.dart';

/// Utility helpers for date/time formatting and conversion used across the app.
class AppDateUtils {
  AppDateUtils._();

  // ---------------------------------------------------------------------------
  // Display formatters
  // ---------------------------------------------------------------------------

  static final DateFormat _displayDate = DateFormat('MMM d, yyyy');
  static final DateFormat _displayDateTime = DateFormat('MMM d, yyyy h:mm a');
  static final DateFormat _displayTime = DateFormat('h:mm a');
  static final DateFormat _iso8601 = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
  static final DateFormat _shortDate = DateFormat('MM/dd/yyyy');

  /// Returns e.g. "Oct 9, 2026"
  static String formatDate(DateTime dt) => _displayDate.format(dt.toLocal());

  /// Returns e.g. "Oct 9, 2026 4:52 PM"
  static String formatDateTime(DateTime dt) =>
      _displayDateTime.format(dt.toLocal());

  /// Returns e.g. "4:52 PM"
  static String formatTime(DateTime dt) => _displayTime.format(dt.toLocal());

  /// Returns e.g. "10/09/2026"
  static String formatShortDate(DateTime dt) =>
      _shortDate.format(dt.toLocal());

  // ---------------------------------------------------------------------------
  // UTC conversion
  // ---------------------------------------------------------------------------

  /// Converts a local [DateTime] to UTC for database storage.
  static DateTime toUtc(DateTime dt) => dt.toUtc();

  /// Converts a UTC [DateTime] from the database to local time for display.
  static DateTime toLocal(DateTime dt) => dt.toLocal();

  /// Parses an ISO-8601 UTC string and returns a local [DateTime].
  static DateTime parseUtcString(String s) =>
      DateTime.parse(s).toLocal();

  // ---------------------------------------------------------------------------
  // Relative time
  // ---------------------------------------------------------------------------

  /// Returns a human-readable relative time string (e.g., "2 hours ago",
  /// "in 3 days", "just now").
  static String formatRelativeTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    final absDiff = diff.abs();

    if (absDiff.inSeconds < 60) {
      return diff.isNegative ? 'in a moment' : 'just now';
    } else if (absDiff.inMinutes < 60) {
      final m = absDiff.inMinutes;
      return diff.isNegative ? 'in $m ${_plural(m, 'minute')}' : '$m ${_plural(m, 'minute')} ago';
    } else if (absDiff.inHours < 24) {
      final h = absDiff.inHours;
      return diff.isNegative ? 'in $h ${_plural(h, 'hour')}' : '$h ${_plural(h, 'hour')} ago';
    } else if (absDiff.inDays < 7) {
      final d = absDiff.inDays;
      return diff.isNegative ? 'in $d ${_plural(d, 'day')}' : '$d ${_plural(d, 'day')} ago';
    } else if (absDiff.inDays < 30) {
      final w = (absDiff.inDays / 7).floor();
      return diff.isNegative ? 'in $w ${_plural(w, 'week')}' : '$w ${_plural(w, 'week')} ago';
    } else if (absDiff.inDays < 365) {
      final mo = (absDiff.inDays / 30).floor();
      return diff.isNegative ? 'in $mo ${_plural(mo, 'month')}' : '$mo ${_plural(mo, 'month')} ago';
    } else {
      final y = (absDiff.inDays / 365).floor();
      return diff.isNegative ? 'in $y ${_plural(y, 'year')}' : '$y ${_plural(y, 'year')} ago';
    }
  }

  static String _plural(int n, String word) => n == 1 ? word : '${word}s';

  // ---------------------------------------------------------------------------
  // Date range helpers
  // ---------------------------------------------------------------------------

  /// Returns midnight (start of day) in UTC for [date].
  static DateTime startOfDay(DateTime date) {
    final local = date.toLocal();
    return DateTime(local.year, local.month, local.day).toUtc();
  }

  /// Returns 23:59:59.999 (end of day) in UTC for [date].
  static DateTime endOfDay(DateTime date) {
    final local = date.toLocal();
    return DateTime(local.year, local.month, local.day, 23, 59, 59, 999)
        .toUtc();
  }

  /// Returns true if [dt] falls on the same calendar day as [reference]
  /// (comparison done in local time).
  static bool isSameDay(DateTime dt, DateTime reference) {
    final a = dt.toLocal();
    final b = reference.toLocal();
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Returns true if [dt] is today (local time).
  static bool isToday(DateTime dt) => isSameDay(dt, DateTime.now());

  // ---------------------------------------------------------------------------
  // Schedule time parsing
  // ---------------------------------------------------------------------------

  /// Parses a schedule time string like "08:30" into a [DateTime] on [date].
  /// [date] is expected to be in local time.
  static DateTime scheduledTimeOnDate(String hhmm, DateTime date) {
    final parts = hhmm.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final local = date.toLocal();
    return DateTime(local.year, local.month, local.day, hour, minute);
  }

  /// Validates that a "HH:mm" string is well-formed.
  static bool isValidTimeString(String s) {
    final regex = RegExp(r'^\d{2}:\d{2}$');
    if (!regex.hasMatch(s)) return false;
    final parts = s.split(':');
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    return h != null && m != null && h >= 0 && h < 24 && m >= 0 && m < 60;
  }
}
