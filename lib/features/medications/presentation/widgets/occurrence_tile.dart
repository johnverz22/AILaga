import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/medication_entity.dart';
import '../../domain/medication_status.dart';
import '../../data/medication_providers.dart';
import '../../../../core/utilities/date_utils.dart';

/// A single row showing one medication occurrence with its status and action buttons.
///
/// Visual distinction:
///   - taken       → green check
///   - skipped     → orange dash
///   - pending     → gray clock (or red outline if overdue)
///   - notConfirmed → amber question mark
///
/// "Overdue" is shown as elapsed time, NOT the word "missed".
class OccurrenceTile extends ConsumerWidget {
  final MedicationOccurrenceEntity occurrence;
  /// The name of the medication, used for display context.
  final String medicationName;

  const OccurrenceTile({
    super.key,
    required this.occurrence,
    required this.medicationName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final now = DateTime.now();
    final isOverdue = occurrence.status == MedicationStatus.pending &&
        occurrence.scheduledAt.isBefore(now);

    final (iconData, iconColor, bgColor, label) =
        _statusStyle(cs, isOverdue);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Status icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: isOverdue
                    ? Border.all(color: cs.error, width: 1.5)
                    : null,
              ),
              child: Icon(iconData, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            // Time + label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        AppDateUtils.formatTime(occurrence.scheduledAt),
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(width: 8),
                      _StatusBadge(label: label, color: iconColor, bg: bgColor),
                    ],
                  ),
                  if (isOverdue)
                    Text(
                      'Due ${AppDateUtils.formatRelativeTime(occurrence.scheduledAt)}',
                      style: theme.textTheme.bodySmall!
                          .copyWith(color: cs.error),
                    ),
                  if (occurrence.statusNote?.isNotEmpty == true)
                    Text(
                      occurrence.statusNote!,
                      style: theme.textTheme.bodySmall!.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.5)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            // Action buttons (only for pending)
            if (occurrence.status == MedicationStatus.pending)
              _ActionMenu(occurrence: occurrence),
          ],
        ),
      ),
    );
  }

  (IconData, Color, Color, String) _statusStyle(
      ColorScheme cs, bool isOverdue) {
    switch (occurrence.status) {
      case MedicationStatus.taken:
        return (
          Icons.check_circle_outline,
          const Color(0xFF16A34A), // green
          const Color(0xFFDCFCE7),
          'Taken',
        );
      case MedicationStatus.skipped:
        return (
          Icons.remove_circle_outline,
          const Color(0xFFD97706), // amber
          const Color(0xFFFEF3C7),
          'Skipped',
        );
      case MedicationStatus.notConfirmed:
        return (
          Icons.help_outline,
          const Color(0xFFB45309), // amber-dark
          const Color(0xFFFDE68A),
          'Not Confirmed',
        );
      case MedicationStatus.pending:
        if (isOverdue) {
          return (
            Icons.access_time,
            cs.error,
            cs.error.withValues(alpha: 0.08),
            'Overdue',
          );
        }
        return (
          Icons.access_time,
          cs.onSurface.withValues(alpha: 0.4),
          cs.onSurface.withValues(alpha: 0.06),
          'Pending',
        );
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const _StatusBadge(
      {required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ActionMenu extends ConsumerWidget {
  final MedicationOccurrenceEntity occurrence;
  const _ActionMenu({required this.occurrence});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<MedicationStatus>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'Update status',
      onSelected: (status) =>
          _updateStatus(context, ref, status),
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: MedicationStatus.taken,
          child: Row(children: [
            Icon(Icons.check_circle_outline,
                color: Color(0xFF16A34A), size: 18),
            SizedBox(width: 10),
            Text('Mark Taken'),
          ]),
        ),
        const PopupMenuItem(
          value: MedicationStatus.skipped,
          child: Row(children: [
            Icon(Icons.remove_circle_outline,
                color: Color(0xFFD97706), size: 18),
            SizedBox(width: 10),
            Text('Mark Skipped'),
          ]),
        ),
        const PopupMenuItem(
          value: MedicationStatus.notConfirmed,
          child: Row(children: [
            Icon(Icons.help_outline,
                color: Color(0xFFB45309), size: 18),
            SizedBox(width: 10),
            Text('Mark Not Confirmed'),
          ]),
        ),
      ],
    );
  }

  Future<void> _updateStatus(
      BuildContext context, WidgetRef ref, MedicationStatus status) async {
    final repo = ref.read(medicationRepositoryProvider);
    await repo.updateOccurrenceStatus(occurrence.id, status);
  }
}
