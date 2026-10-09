import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/ai/local/proposals/proposal_models.dart';
import '../../../services/ai/local/proposals/proposal_repository.dart';
import '../data/capture_providers.dart';
import 'widgets/proposal_card.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Review Tray screen: shows all AI-proposed records for a capture.
/// Caregiver can confirm all, edit individual, or discard.
class ReviewTrayScreen extends ConsumerStatefulWidget {
  final String captureId;
  final String careRecipientId;
  final String? heardText;
  final List<StagedProposal> proposals;

  const ReviewTrayScreen({
    super.key,
    required this.captureId,
    required this.careRecipientId,
    this.heardText,
    required this.proposals,
  });

  @override
  ConsumerState<ReviewTrayScreen> createState() => _ReviewTrayScreenState();
}

class _ReviewTrayScreenState extends ConsumerState<ReviewTrayScreen> {
  late List<StagedProposal> _proposals;
  bool _confirming = false;

  @override
  void initState() {
    super.initState();
    _proposals = List.from(widget.proposals);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check what was heard'),
        leading: IconButton(
          icon: const Icon(Symbols.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Close',
        ),
      ),
      body: Column(
        children: [
          // Heard text header
          if (widget.heardText != null && widget.heardText!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Heard:',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.heardText!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          // Proposal cards
          Expanded(
            child: _proposals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Symbols.check_circle_rounded,
                            size: 64, color: theme.colorScheme.primary),
                        const SizedBox(height: 16),
                        Text('Nothing was heard.',
                            style: theme.textTheme.bodyLarge),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 100),
                    itemCount: _proposals.length,
                    itemBuilder: (context, index) {
                      final staged = _proposals[index];
                      return ProposalCard(
                        record: staged.record,
                        onDiscard: () => _discardAt(index),
                        onEdit: () => _editAt(index, context),
                      );
                    },
                  ),
          ),
        ],
      ),
      // Confirm all button
      bottomSheet: _proposals.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  // Helper-mode primary action ≥ 64 dp (UI spec).
                  height: 64,
                  child: FilledButton.icon(
                    onPressed: _confirming ? null : _confirmAll,
                    icon: _confirming
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Symbols.check_rounded),
                    label: Text(_confirming
                        ? 'Confirming…'
                        : 'Confirm all (${_proposals.length})'),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  /// Discard must hit the DB BEFORE the card disappears: confirmAll reads
  /// pending rows, so a card removed only locally would still be written.
  Future<void> _discardAt(int index) async {
    final staged = _proposals[index];
    try {
      await ref
          .read(confirmProposalsProvider(widget.careRecipientId))
          .discardOne(staged.proposalId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not discard: $e')),
        );
      }
      return;
    }
    if (mounted) {
      setState(() => _proposals.removeAt(index));
    }
  }

  void _editAt(int index, BuildContext context) {
    final record = _proposals[index].record;
    // Navigate to existing edit forms based on record type
    if (record is ProposedMeasurement) {
      // Could push to add_measurement with prefilled values
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Edit in measurement form')),
      );
    } else if (record is ProposedMedicationTaken || record is ProposedMedicationSkipped) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Edit in medication form')),
      );
    }
  }

  Future<void> _confirmAll() async {
    setState(() => _confirming = true);
    try {
      final useCase = ref.read(confirmProposalsProvider(widget.careRecipientId));
      final count = await useCase.confirmAll(widget.captureId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$count records saved ✓'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(count);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong. Try again.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }
}
