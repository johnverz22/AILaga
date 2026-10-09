import 'dart:math';

class MedMatcher {
  static String normalize(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '').trim();
  }

  static int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.filled(t.length + 1, 0);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < v0.length; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }
      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[t.length];
  }

  static double similarity(String a, String b) {
    String normA = normalize(a);
    String normB = normalize(b);
    if (normA == normB) return 1.0;
    if (normA.isEmpty || normB.isEmpty) return 0.0;
    
    int dist = _levenshtein(normA, normB);
    return 1.0 - (dist / max(normA.length, normB.length));
  }

  static MatchResult match(String input, List<String> activeMeds) {
    String bestMatch = '';
    double bestScore = 0.0;

    for (String med in activeMeds) {
      double score = similarity(input, med);
      if (score > bestScore) {
        bestScore = score;
        bestMatch = med;
      }
    }

    if (bestScore == 1.0) {
      return MatchResult(bestMatch, MatchStatus.sure);
    } else if (bestScore >= 0.8) {
      return MatchResult(bestMatch, MatchStatus.check);
    } else {
      return MatchResult(input, MatchStatus.unmatched);
    }
  }
}

enum MatchStatus { sure, check, unmatched }

class MatchResult {
  final String matchedName;
  final MatchStatus status;

  MatchResult(this.matchedName, this.status);
}
