import 'dart:async';

import '../local_ai_engine.dart';

/// Result of an Ask-the-record query, already safe to render.
class AskResult {
  final String text;
  final List<String> sourceIds;
  final bool refused;
  final bool usedDeterministicFallback;

  const AskResult({
    required this.text,
    this.sourceIds = const [],
    this.refused = false,
    this.usedDeterministicFallback = false,
  });
}

/// Ask agent (spec §6.5 / C12).
///
/// Pipeline: advice guard → engine tool-loop (≤3 rounds, 20 s timeout) →
/// deterministic fallback for Basic mode / engine failure.
/// The agent only ever *reads*; all mutations stay outside this layer.
class AskAgent {
  static const Duration defaultTimeout = Duration(seconds: 20);
  static const int maxToolRounds = 3;

  final LocalAiEngine engine;
  final ToolExecutor tools;

  /// Total bound on the engine tool-loop. Injectable for tests.
  final Duration timeout;

  AskAgent({
    required this.engine,
    required this.tools,
    this.timeout = defaultTimeout,
  });

  /// Medical-advice / dosage-decision questions always get a fixed refusal.
  static final List<RegExp> _advicePatterns = [
    RegExp(r'\b(should|can|may)\s+(i|she|he|lola|we)\s+(take|stop|skip|increase|decrease|double|give|administer)\b', caseSensitive: false),
    RegExp(r'\b(is it safe|okay to take|safe ba|pwede ba|pwede bang|dapat ba)\b', caseSensitive: false),
    RegExp(r'\b(inumin|inom|painumin)\s*(ko|ba|niya|ni lola)\b', caseSensitive: false),
    RegExp(r'\b(dosage|dose|dosis)\s*(change|increase|decrease|adjust|dagdagan|bawasan)\b', caseSensitive: false),
    RegExp(r'\b(diagnose|diagnosis|ano kaya ang sakit|what.*wrong with)\b', caseSensitive: false),
  ];

  bool isAdviceQuestion(String query) =>
      _advicePatterns.any((p) => p.hasMatch(query));

  Future<AskResult> ask(String query) async {
    if (isAdviceQuestion(query)) {
      return const AskResult(
        text: 'Ask the doctor.',
        refused: true,
      );
    }

    try {
      final tier = await engine.tier();
      if (tier == AiTier.basic) {
        return await _deterministicAnswer(query);
      }
      return await _engineAnswer(query);
    } on AiUnavailable {
      return _deterministicAnswer(query);
    } catch (_) {
      return _deterministicAnswer(query);
    }
  }

  /// Model-driven path: engine runs the tool loop; we bound the total time
  /// and collect sources from the final AskAnswer event.
  Future<AskResult> _engineAnswer(String query) async {
    final buffer = StringBuffer();
    List<String> sources = const [];

    try {
      await for (final event
          in engine.ask(AskRequest(query: query), tools).timeout(timeout)) {
        if (event is AskToken) {
          buffer.write(event.text);
        } else if (event is AskAnswer) {
          sources = event.sourceIds;
          if (event.text.isNotEmpty) {
            buffer.clear();
            buffer.write(event.text);
          }
        } else if (event is AskRefused) {
          return const AskResult(text: 'Ask the doctor.', refused: true);
        } else if (event is AskFailed) {
          return await _deterministicAnswer(query);
        }
      }
    } on TimeoutException {
      return _deterministicAnswer(query);
    }

    final text = buffer.toString().trim();
    if (text.isEmpty) return _deterministicAnswer(query);
    return AskResult(text: text, sourceIds: sources);
  }

  /// Basic-mode path: deterministic answers for the common questions.
  /// No model needed — the same read-only tools produce the answer.
  Future<AskResult> _deterministicAnswer(String query) async {
    final q = query.toLowerCase();

    if (RegExp(r'(take|took|nainom|nainom na|uminom|drank|pills?|gamot|meds?)')
        .hasMatch(q)) {
      final result = await tools.call('get_medication_occurrences',
          {'days_back': 0}) as List;
      final due = result
          .where((o) => (o as Map)['status'] != 'pending')
          .toList();
      final taken =
          result.where((o) => (o as Map)['status'] == 'taken').toList();
      final total = result.length;
      final text = total == 0
          ? 'No medicines today.'
          : taken.length == total
              ? 'Yes. $total of $total today.'
              : '${taken.length} of $total today.';
      return AskResult(
        text: text,
        sourceIds: due.map((o) => (o as Map)['id'] as String).toList(),
        usedDeterministicFallback: true,
      );
    }

    if (RegExp(r'\b(bp|blood pressure|presyon|presyon)\b').hasMatch(q)) {
      final result = await tools.call('get_measurements',
          {'type': 'blood_pressure', 'days_back': 14, 'limit': 1}) as List;
      if (result.isEmpty) {
        return const AskResult(
            text: 'No BP readings yet.', usedDeterministicFallback: true);
      }
      final m = result.first as Map;
      return AskResult(
        text:
            'Last BP: ${m['value1']}/${m['value2']} ${m['unit']}.',
        sourceIds: [m['id'] as String],
        usedDeterministicFallback: true,
      );
    }

    if (RegExp(r'(miss|skip|nakalimutan|hindi nainom|missed)').hasMatch(q)) {
      final result = await tools.call('get_medication_occurrences',
          {'days_back': 7, 'status': 'skipped'}) as List;
      return AskResult(
        text: result.isEmpty
            ? 'None missed this week.'
            : 'Missed ${result.length} this week.',
        sourceIds: result.map((o) => (o as Map)['id'] as String).toList(),
        usedDeterministicFallback: true,
      );
    }

    if (RegExp(r'(note|notes|tala|observation)').hasMatch(q)) {
      final result = await tools
          .call('get_care_notes', {'days_back': 3, 'limit': 3}) as List;
      if (result.isEmpty) {
        return const AskResult(
            text: 'No new notes.', usedDeterministicFallback: true);
      }
      final texts =
          result.map((n) => (n as Map)['text'] as String).join(' ');
      return AskResult(
        text: texts,
        sourceIds: result.map((n) => (n as Map)['id'] as String).toList(),
        usedDeterministicFallback: true,
      );
    }

    return const AskResult(
      text: 'Try: pills, BP, missed, or notes.',
      usedDeterministicFallback: true,
    );
  }
}
