import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../../services/ai/local/proposals/proposal_repository.dart';
import '../../data/capture_providers.dart';
import '../review_tray_screen.dart';

/// Pinned strip on Ngayon showing unconfirmed AI proposals (spec C5).
/// A capture left unreviewed stays visible until every staged proposal
/// is confirmed, edited, or discarded.
class PendingProposalsStrip extends ConsumerWidget {
  const PendingProposalsStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingProposalsProvider).valueOrNull;
    if (pending == null || pending.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final accent = Colors.orange.shade800;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: accent, width: 2),
      ),
      child: ListTile(
        leading: Icon(Symbols.rate_review_rounded, color: accent, size: 32),
        title: Text(
          '${pending.length} ${pending.length == 1 ? 'thing' : 'things'} to check',
          style: theme.textTheme.titleMedium,
        ),
        subtitle: const Text('Heard but not confirmed yet'),
        trailing: FilledButton(
          onPressed: () => _openReviewTrays(context, ref, pending),
          child: const Text('Review'),
        ),
      ),
    );
  }

  /// Opens the review tray once per capture that has pending proposals,
  /// oldest first — the tray confirms per capture, so batches are
  /// reviewed one at a time.
  Future<void> _openReviewTrays(
    BuildContext context,
    WidgetRef ref,
    List<AiProposalEntity> pending,
  ) async {
    final repo = ref.read(aiCaptureRepositoryProvider);
    final byCapture = <String, List<AiProposalEntity>>{};
    for (final p in pending) {
      byCapture.putIfAbsent(p.captureId, () => []).add(p);
    }
    for (final entry in byCapture.entries) {
      if (!context.mounted) return;
      final capture = await repo.getCapture(entry.key);
      if (capture == null || !context.mounted) continue;
      final staged = entry.value
          .map((e) {
            final record = repo.recordFromEntity(e);
            return record == null
                ? null
                : StagedProposal(proposalId: e.id, record: record);
          })
          .whereType<StagedProposal>()
          .toList();
      if (staged.isEmpty) continue;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ReviewTrayScreen(
          captureId: capture.id,
          careRecipientId: capture.careRecipientId,
          heardText: capture.originalText,
          proposals: staged,
        ),
      ));
    }
  }
}
