import 'package:flutter/material.dart';
import '../../domain/care_note_entity.dart';
import '../../../../core/utilities/date_utils.dart';

class CareNoteCard extends StatelessWidget {
  final CareNoteEntity note;
  final VoidCallback? onToggleReview;
  final VoidCallback? onDelete;

  const CareNoteCard({
    super.key,
    required this.note,
    this.onToggleReview,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isConfirmed = note.reviewStatus == 'confirmed';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time_outlined, size: 16, color: cs.onSurface.withValues(alpha: 0.5)),
                const SizedBox(width: 8),
                Text(
                  AppDateUtils.formatDateTime(note.observedAt),
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                _SourceBadge(sourceType: note.sourceType),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              note.originalText,
              style: theme.textTheme.bodyMedium,
            ),
            if (note.structuredSummary != null && note.structuredSummary!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.secondaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 14, color: cs.secondary),
                        const SizedBox(width: 6),
                        Text(
                          'AI Summary',
                          style: theme.textTheme.labelSmall!.copyWith(color: cs.secondary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(note.structuredSummary!, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onToggleReview != null)
                  TextButton.icon(
                    onPressed: onToggleReview,
                    icon: Icon(
                      isConfirmed ? Icons.check_box : Icons.check_box_outline_blank,
                      color: isConfirmed ? const Color(0xFF16A34A) : cs.onSurface.withValues(alpha: 0.5),
                      size: 18,
                    ),
                    label: Text(
                      isConfirmed ? 'Reviewed' : 'Mark Reviewed',
                      style: TextStyle(
                        color: isConfirmed ? const Color(0xFF16A34A) : cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 20, color: cs.error.withValues(alpha: 0.6)),
                    onPressed: onDelete,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final String sourceType;
  const _SourceBadge({required this.sourceType});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isAi = sourceType == 'ai_assisted';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isAi ? cs.secondary.withValues(alpha: 0.1) : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isAi ? cs.secondary.withValues(alpha: 0.3) : cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAi) ...[
            Icon(Icons.mic_none, size: 10, color: cs.secondary),
            const SizedBox(width: 4),
          ],
          Text(
            isAi ? 'Voice Note' : 'Manual Entry',
            style: TextStyle(
              color: isAi ? cs.secondary : cs.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
