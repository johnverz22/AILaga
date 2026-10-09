import 'package:intl/intl.dart';

/// Centralized date formatting utilities for the app
class DateFormatter {
  // Private formatters
  static final DateFormat _displayDate = DateFormat('MMM d, yyyy');
  static final DateFormat _displayDateTime = DateFormat('MMM d, yyyy h:mm a');
  static final DateFormat _displayTime = DateFormat('h:mm a');
  static final DateFormat _shortDate = DateFormat('MM/dd/yyyy');

  /// Returns e.g. "Oct 9, 2026"
  static String formatDate(DateTime dt) => _displayDate.format(dt.toLocal());

  /// Returns e.g. "Oct 9, 2026 4:52 PM"
  static String formatDateTime(DateTime dt) =>
      _displayDateTime.format(dt.toLocal());

  /// Returns e.g. "4:52 PM"
  static String formatTime(DateTime dt) => _displayTime.format(dt.toLocal());

  /// Returns e.g. "10/09/2026"
  static String formatShortDate(DateTime dt) => _shortDate.format(dt.toLocal());

  /// Returns true if the date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Returns true if the date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }
}
