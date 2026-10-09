import '../local_ai_engine.dart';
import 'narration_verifier.dart';

/// Narratorist: builds fact sets and generates AI-narrated prose,
/// falling back to template when the verifier rejects the output.
class Narrator {
  final LocalAiEngine engine;
  final NarrationVerifier verifier;

  Narrator({required this.engine, required this.verifier});

  /// Narrate a fact set for a given audience and language.
  /// Returns the narrated text or template fallback.
  Future<NarrationOutput> narrate({
    required FactSet facts,
    required String audience, // 'sibling', 'helper', 'doctor'
    required String language, // 'filipino', 'taglish', 'english'
  }) async {
    try {
      final prompt = _buildPrompt(facts, audience, language);
      final rawOutput = await engine.narrate(NarrationRequest(
        facts: facts.facts.map((f) => '[r:${f.id}] ${f.text}').toList(),
        audience: audience,
        language: language,
        prompt: prompt,
      ));

      final result = verifier.verify(rawOutput, facts);

      if (result.verified) {
        return NarrationOutput(
          text: result.text!,
          isAiGenerated: true,
          citedFactIds: result.citedFactIds,
        );
      } else {
        // Fallback to template
        return NarrationOutput(
          text: _templateFallback(facts, audience, language),
          isAiGenerated: false,
          citedFactIds: facts.facts.map((f) => f.id).toSet(),
          fallbackReason: result.reason,
        );
      }
    } catch (e) {
      // Engine error → template fallback
      return NarrationOutput(
        text: _templateFallback(facts, audience, language),
        isAiGenerated: false,
        citedFactIds: facts.facts.map((f) => f.id).toSet(),
        fallbackReason: 'AI engine error: $e',
      );
    }
  }

  String _buildPrompt(FactSet facts, String audience, String language) {
    final langLabel = language == 'filipino'
        ? 'Filipino'
        : language == 'taglish'
            ? 'Taglish'
            : 'English';
    final audienceLabel = audience == 'sibling'
        ? 'a family member abroad'
        : audience == 'doctor'
            ? 'a doctor'
            : 'the next caregiver';

    return '''
You are writing a care update for $audienceLabel in $langLabel.
Use ONLY the facts below. Cite each fact with its [r:ID] marker.
Do NOT add medical advice, recommendations, or diagnoses.
Do NOT invent any numbers, times, or medication names.

Facts:
${facts.facts.map((f) => '[r:${f.id}] ${f.text}').join('\n')}
''';
  }

  String _templateFallback(FactSet facts, String audience, String language) {
    // Simple bullet-point template
    final buffer = StringBuffer();
    if (language == 'filipino' || language == 'taglish') {
      buffer.writeln('Ulat ng Pag-aalaga:');
    } else {
      buffer.writeln('Care Update:');
    }
    for (final fact in facts.facts) {
      buffer.writeln('• ${fact.text}');
    }
    return buffer.toString();
  }
}

class NarrationOutput {
  final String text;
  final bool isAiGenerated;
  final Set<String> citedFactIds;
  final String? fallbackReason;

  const NarrationOutput({
    required this.text,
    required this.isAiGenerated,
    required this.citedFactIds,
    this.fallbackReason,
  });
}
