import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/ai/local/ai_providers.dart';
import '../../../services/ai/local/ask/ask_agent.dart';
import '../../../services/ai/local/ask/ask_tools.dart';
import '../../appointments/data/appointment_providers.dart';
import '../../care_notes/data/care_note_providers.dart';
import '../../care_recipient/data/care_recipient_providers.dart';
import '../../measurements/data/measurement_providers.dart';
import '../../medications/data/medication_providers.dart';

/// Read-only tool surface over A's repositories, scoped to the primary
/// care recipient.
final askToolsProvider = FutureProvider<AskTools>((ref) async {
  final recipient = await ref.watch(primaryCareRecipientProvider.future);
  if (recipient == null) {
    throw StateError('No care recipient configured');
  }
  return AskTools(
    careRecipientId: recipient.id,
    medicationRepo: ref.watch(medicationRepositoryProvider),
    measurementRepo: ref.watch(measurementRepositoryProvider),
    careNoteRepo: ref.watch(careNoteRepositoryProvider),
    appointmentRepo: ref.watch(appointmentRepositoryProvider),
  );
});

/// Ask agent bound to the current engine (NullEngine → deterministic answers).
final askAgentProvider = FutureProvider<AskAgent>((ref) async {
  return AskAgent(
    engine: ref.watch(localAiEngineProvider),
    tools: await ref.watch(askToolsProvider.future),
  );
});
