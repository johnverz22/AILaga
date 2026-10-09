import '../../care_summary_models.dart';

/// A single fact with a unique ID and provenance.
class Fact {
  final String id;
  final String text;
  final String? entityRef; // e.g. "medication:123" or "measurement:456"

  const Fact({required this.id, required this.text, this.entityRef});
}

/// A set of facts extracted from repositories for narration.
class FactSet {
  final List<Fact> facts;
  final DateTime generatedAt;

  const FactSet({required this.facts, required this.generatedAt});

  /// All entity references mentioned in this fact set.
  Set<String> get entityRefs =>
      facts.where((f) => f.entityRef != null).map((f) => f.entityRef!).toSet();
}

/// Verifies that AI-narrated text is grounded in facts.
class NarrationVerifier {
  /// Verifies a narrated text against the source facts.
  /// Returns the verified text, or null if too many facts were dropped.
  VerificationResult verify(String narration, FactSet facts) {
    final markers = RegExp(r'\[r:([^\]]+)\]');
    final cited = <String>{};
    int totalClaims = 0;
    int validClaims = 0;
    final droppedClaims = <String>[];

    for (final match in markers.allMatches(narration)) {
      totalClaims++;
      final factId = match.group(1)!;
      final fact = facts.facts.where((f) => f.id == factId).firstOrNull;

      if (fact != null) {
        cited.add(factId);
        validClaims++;
      } else {
        droppedClaims.add(factId);
      }
    }

    // Remove markers from output
    String cleanText = narration.replaceAll(markers, '').trim();
    cleanText = cleanText.replaceAll(RegExp(r'\s{2,}'), ' ');

    // Advice guard: reject medical advice
    final advicePatterns = [
      RegExp(r'\b(inumin|take|stop taking|increase|decrease)\s+(mo|your)\b', caseSensitive: false),
      RegExp(r'\b(recommend|suggest|advise|consult)\b', caseSensitive: false),
      RegExp(r'\b(dapat|kailangan|need to|should)\s+(mag|take)\b', caseSensitive: false),
    ];

    bool hasAdvice = false;
    for (final pattern in advicePatterns) {
      if (pattern.hasMatch(cleanText)) {
        hasAdvice = true;
        break;
      }
    }

    // Drop ratio: if >40% of claims are invalid, fallback
    double dropRatio = totalClaims > 0 ? (totalClaims - validClaims) / totalClaims : 0;
    bool tooManyDropped = dropRatio > 0.4;

    if (tooManyDropped || hasAdvice) {
      return VerificationResult(
        verified: false,
        text: null,
        reason: tooManyDropped
            ? 'Too many ungrounded claims (${(dropRatio * 100).toInt()}% dropped)'
            : 'Medical advice detected — using template fallback',
        citedFactIds: cited,
        status: GenerationStatus.fallback,
      );
    }

    return VerificationResult(
      verified: true,
      text: cleanText,
      reason: null,
      citedFactIds: cited,
      status: GenerationStatus.success,
    );
  }
}

class VerificationResult {
  final bool verified;
  final String? text;
  final String? reason;
  final Set<String> citedFactIds;
  final GenerationStatus status;

  const VerificationResult({
    required this.verified,
    this.text,
    this.reason,
    required this.citedFactIds,
    required this.status,
  });
}
