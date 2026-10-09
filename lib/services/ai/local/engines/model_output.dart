import 'dart:convert';

import '../local_ai_engine.dart';
import '../proposals/proposal_models.dart';

/// One raw function call emitted by a model, before validation.
class RawToolCall {
  final String name;
  final Map<String, dynamic> args;
  const RawToolCall(this.name, this.args);
}

/// Maps a [RawToolCall] to a [ProposedRecord]. Unknown/malformed calls
/// return null — the caller drops them (never corrects, never invents).
/// Shared by the Gemma LiteRT and Apple FoundationModels engines.
ProposedRecord? mapToolCallToProposal(RawToolCall call) {
  final a = call.args;
  String? s(String k) => a[k] is String ? a[k] as String : null;
  num? n(String k) => a[k] is num ? a[k] as num : null;

  switch (call.name) {
    case 'propose_medication_taken':
      final med = s('medication_name');
      final quote = s('source_quote');
      if (med == null || quote == null) return null;
      return ProposedMedicationTaken(
          medicationName: med, timePhrase: s('time_phrase'), sourceQuote: quote);
    case 'propose_medication_skipped':
      final med = s('medication_name');
      final quote = s('source_quote');
      if (med == null || quote == null) return null;
      return ProposedMedicationSkipped(
          medicationName: med,
          reasonText: s('reason_text'),
          sourceQuote: quote);
    case 'propose_measurement':
      final type = s('type');
      final value1 = n('value1');
      final unit = s('unit');
      final quote = s('source_quote');
      if (type == null || value1 == null || unit == null || quote == null) {
        return null;
      }
      return ProposedMeasurement(
          type: type,
          value1: value1,
          value2: n('value2'),
          unit: unit,
          timePhrase: s('time_phrase'),
          sourceQuote: quote);
    case 'propose_care_note':
      final text = s('text');
      final quote = s('source_quote');
      if (text == null || quote == null) return null;
      return ProposedCareNote(
          text: text, timePhrase: s('time_phrase'), sourceQuote: quote);
    case 'propose_appointment':
      final when = s('datetime_phrase');
      final quote = s('source_quote');
      if (when == null || quote == null) return null;
      return ProposedAppointment(
          provider: s('provider'),
          purpose: s('purpose'),
          datetimePhrase: when,
          sourceQuote: quote);
    case 'propose_medication_schedule':
      final name = s('name');
      final quote = s('source_quote');
      if (name == null || quote == null) return null;
      return ProposedMedicationSchedule(
          name: name,
          strength: s('strength'),
          instructionText: s('instruction_text'),
          timesHhmm: (a['times_hhmm'] as List?)
              ?.map((e) => e.toString())
              .toList(),
          sourceQuote: quote);
    default:
      return null;
  }
}

/// §6.3 tool schema rendered into the prompt. Output contract: a JSON
/// object {"transcript": "...", "calls": [{"name": ..., "parameters": {...}}]}.
String extractionInstruction(ExtractionContext ctx, {ImageIntent? intent}) {
  final meds = ctx.activeMeds.join(', ');
  final target = switch (intent) {
    ImageIntent.reseta => 'a photo of a handwritten prescription',
    ImageIntent.label => 'a photo of a pill bottle label',
    ImageIntent.monitor => 'a photo of a BP/glucose monitor screen',
    null => 'the caregiver\'s spoken sentence',
  };
  return '''
You convert $target into structured record proposals for a caregiving app.

Rules:
- Copy numbers EXACTLY as written/said. Never invent or correct values.
- Include source_quote: a verbatim substring of the transcript field you output
  (for images, the transcript is the text you read off the photo). Proposals
  whose quote is not found in the transcript are dropped by the app.
- If a field is unreadable, leave it null. Never guess a dose or a number.
- If nothing recordable is present, return an empty calls array.
- Known medications: [${meds.isEmpty ? 'none' : meds}]
- Now: ${ctx.now.toIso8601String()} (${ctx.timezone})

Output ONLY this JSON object, no prose:
{"transcript":"<heard or read text>","calls":[{"name":"<tool>","parameters":{...}}]}

Tools:
- propose_medication_taken {medication_name, time_phrase|null, source_quote}
- propose_medication_skipped {medication_name, reason_text|null, source_quote}
- propose_measurement {type: blood_pressure|pulse|temperature|weight|blood_glucose, value1, value2|null, unit, time_phrase|null, source_quote}
- propose_care_note {text, time_phrase|null, source_quote}
- propose_appointment {provider|null, purpose|null, datetime_phrase, source_quote}
- propose_medication_schedule {name, strength|null, instruction_text|null, times_hhmm|null, source_quote}
''';
}

/// Extracts the calls array from model output; tolerates prose around the
/// JSON object.
List<RawToolCall> parseToolCalls(String output) {
  final obj = decodeJsonObject(output);
  if (obj == null) return const [];
  final calls = obj['calls'];
  if (calls is! List) return const [];
  return calls
      .whereType<Map>()
      .map((c) => RawToolCall(
            c['name']?.toString() ?? '',
            (c['parameters'] as Map?)?.cast<String, dynamic>() ?? const {},
          ))
      .where((c) => c.name.isNotEmpty)
      .toList();
}

Map<String, dynamic>? decodeJsonObject(String output) {
  final start = output.indexOf('{');
  final end = output.lastIndexOf('}');
  if (start < 0 || end <= start) return null;
  try {
    final decoded = jsonDecode(output.substring(start, end + 1));
    return decoded is Map<String, dynamic> ? decoded : null;
  } catch (_) {
    return null;
  }
}

String? readJsonString(String output, String key) {
  final v = decodeJsonObject(output)?[key];
  return v is String && v.isNotEmpty ? v : null;
}

List<String> readJsonStringList(String output, String key) {
  final v = decodeJsonObject(output)?[key];
  return v is List ? v.map((e) => e.toString()).toList() : const [];
}

Map<String, Object?> readJsonMap(String output, String key) {
  final v = decodeJsonObject(output)?[key];
  return v is Map ? v.cast<String, Object?>() : const {};
}

/// Shared Ask prompt (§6.5): read-only tools, JSON contract.
/// `toolDescriptorsJson` is the engine's tool descriptor list, pre-encoded.
String askPrompt(String query, String toolDescriptorsJson) => '''
You answer questions about an elder's care records using read-only tools.
Tools: $toolDescriptorsJson

To call a tool output ONLY: {"tool":"<name>","args":{...}}
To answer output ONLY: {"answer":"<short plain answer>","source_ids":["<record ids used>"]}
Question: "$query"
''';
