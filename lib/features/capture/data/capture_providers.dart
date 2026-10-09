import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../services/ai/local/proposals/proposal_repository.dart';
import '../../../features/medications/data/medication_providers.dart';
import '../../../features/measurements/data/measurement_providers.dart';
import '../../../features/care_notes/data/care_note_providers.dart';
import '../application/confirm_proposals.dart';

/// Provider for the AI capture repository.
final aiCaptureRepositoryProvider = Provider<AiCaptureRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AiCaptureRepository(db);
});

/// All pending AI proposals across captures, oldest first — drives the
/// "things to check" strip on the Ngayon dashboard (spec C5).
final pendingProposalsProvider =
    StreamProvider<List<AiProposalEntity>>((ref) {
  return ref.watch(aiCaptureRepositoryProvider).watchPendingProposals();
});

/// Provider for the confirm-proposals use case.
/// Requires a careRecipientId — passed as a family arg.
final confirmProposalsProvider = Provider.family<ConfirmProposalsUseCase, String>(
  (ref, careRecipientId) {
    return ConfirmProposalsUseCase(
      captureRepo: ref.watch(aiCaptureRepositoryProvider),
      medicationRepo: ref.watch(medicationRepositoryProvider),
      measurementRepo: ref.watch(measurementRepositoryProvider),
      careNoteRepo: ref.watch(careNoteRepositoryProvider),
      careRecipientId: careRecipientId,
    );
  },
);
