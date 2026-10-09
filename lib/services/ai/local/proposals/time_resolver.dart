class TimeResolver {
  static DateTime? resolve(String phrase, DateTime now) {
    String p = phrase.toLowerCase().trim();

    if (p == 'now' || p == 'ngayon') {
      return now;
    }
    if (p == 'kanina') {
      return now.subtract(const Duration(hours: 1)); // simple heuristic
    }
    if (p == 'kaninang umaga' || p == 'this morning') {
      return DateTime(now.year, now.month, now.day, 8, 0); // 8 AM today
    }
    if (p == 'kagabi' || p == 'yesterday evening' || p == 'last night') {
      return DateTime(now.year, now.month, now.day - 1, 20, 0); // 8 PM yesterday
    }
    if (p == 'kahapon' || p == 'yesterday') {
      return DateTime(now.year, now.month, now.day - 1, 12, 0); // Noon yesterday
    }

    // Very basic "8am", "2pm"
    RegExp timeRegex = RegExp(r'^(\d{1,2})(?::(\d{2}))?\s*(am|pm)$');
    Match? match = timeRegex.firstMatch(p);
    if (match != null) {
      int hour = int.parse(match.group(1)!);
      int minute = match.group(2) != null ? int.parse(match.group(2)!) : 0;
      String ampm = match.group(3)!;

      if (ampm == 'pm' && hour < 12) hour += 12;
      if (ampm == 'am' && hour == 12) hour = 0;

      DateTime resolved = DateTime(now.year, now.month, now.day, hour, minute);
      // If resolving "8pm" and it's currently 10am, it might mean yesterday 8pm.
      // But let's just return the naive resolved today time and let validators reject if it's future.
      return resolved;
    }

    return null;
  }
}
