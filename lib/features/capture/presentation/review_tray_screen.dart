import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../services/ai/local/proposals/proposal_models.dart';
import '../../../services/ai/local/proposals/proposal_repository.dart';
import '../../../features/medications/data/medication_providers.dart';
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
                        onEdit: () => _editAt(index),
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

  /// Edit opens A's existing add form pre-filled (spec §5 — forms are the
  /// edit path; no new form code). When the form reports a save, the
  /// staged proposal is marked `edited` and leaves the tray so
  /// "Confirm all" can't write a second record for it.
  ///
  /// Medication taken/skipped is the exception: the form only creates
  /// the missing *schedule*, not the status. The proposal stays pending
  /// so "Confirm all" can still mark the new schedule's occurrence.
  Future<void> _editAt(int index) async {
    final staged = _proposals[index];
    final record = staged.record;
    bool? saved;

    if (record is ProposedMeasurement) {
      saved = await context.push<bool>('/measurements/add', extra: {
        'recipientId': widget.careRecipientId,
        'initialValues': {
          'type': record.type,
          'value1': record.value1,
          'value2': record.value2,
          'unit': record.unit,
        },
      });
    } else if (record is ProposedMedicationTaken ||
        record is ProposedMedicationSkipped) {
      final name = record is ProposedMedicationTaken
          ? record.medicationName
          : (record as ProposedMedicationSkipped).medicationName;
      // The form is only the corrective path for an UNSCHEDULED drug
      // (spec §5.5: add the medication first, then confirm marks its
      // occurrence). For a scheduled med, saving here would create a
      // duplicate schedule — and duplicate dose reminders.
      final schedules = await ref
          .read(medicationRepositoryProvider)
          .getActiveSchedules(widget.careRecipientId);
      if (!mounted) return;
      final listed = schedules.any(
          (s) => s.medicationName.toLowerCase() == name.toLowerCase());
      if (listed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Already listed. Tap Confirm to save.')),
        );
        return;
      }
      await context.push<bool>('/medications/add', extra: {
        'recipientId': widget.careRecipientId,
        'initialValues': {'medicationName': name},
      });
      return; // stays pending — see doc comment
    } else if (record is ProposedMedicationSchedule) {
      saved = await context.push<bool>('/medications/add', extra: {
        'recipientId': widget.careRecipientId,
        'initialValues': {
          'medicationName': record.name,
          'instructions': record.instructionText,
          'timesHhmm': record.timesHhmm,
        },
      });
    } else if (record is ProposedCareNote) {
      saved = await context.push<bool>('/care-notes/add', extra: {
        'recipientId': widget.careRecipientId,
        'initialValues': {'text': record.text},
      });
    } else if (record is ProposedAppointment) {
      saved = await context.push<bool>('/appointments/add', extra: {
        'recipientId': widget.careRecipientId,
        'initialValues': {
          'provider': record.provider,
          'purpose': record.purpose,
        },
      });
    }

    if (saved != true || !mounted) return;
    // Persist BEFORE the card disappears — same rule as discard.
    try {
      await ref
          .read(aiCaptureRepositoryProvider)
          .updateProposalStatus(staged.proposalId, 'edited');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update: $e')),
        );
      }
      return;
    }
    if (mounted) {
      setState(() => _proposals.removeAt(index));
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
