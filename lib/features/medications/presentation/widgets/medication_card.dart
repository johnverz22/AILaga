import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/medication_entity.dart';
import '../../../../core/utilities/date_utils.dart';

/// Card showing a medication schedule summary: name, times, start/end, active state.
class MedicationCard extends StatelessWidget {
  final MedicationScheduleEntity schedule;
  final VoidCallback? onTap;
  final VoidCallback? onDeactivate;

  const MedicationCard({
    super.key,
    required this.schedule,
    this.onTap,
    this.onDeactivate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final times = _parseTimes(schedule.scheduleTimes);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap ?? () => context.push('/medications/${schedule.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: schedule.isActive
                          ? cs.primary.withValues(alpha: 0.10)
                          : cs.onSurface.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.medication_outlined,
                      color: schedule.isActive
                          ? cs.primary
                          : cs.onSurface.withValues(alpha: 0.4),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule.medicationName,
                          style: theme.textTheme.titleMedium,
                        ),
                        if (schedule.prescribedInstructions?.isNotEmpty == true)
                          Text(
                            schedule.prescribedInstructions!,
                            style: theme.textTheme.bodySmall!.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (!schedule.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cs.onSurface.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Inactive',
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Schedule time chips
              if (times.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: times.map((t) => _TimeChip(time: t)).toList(),
                ),
              const SizedBox(height: 8),
              // Date range row
              Row(
                children: [
                  Icon(Icons.date_range_outlined,
                      size: 14, color: cs.onSurface.withValues(alpha: 0.4)),
                  const SizedBox(width: 4),
                  Text(
                    _dateRange(schedule),
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const Spacer(),
                  if (schedule.isActive && onDeactivate != null)
                    GestureDetector(
                      onTap: onDeactivate,
                      child: Text(
                        'Deactivate',
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: cs.error.withValues(alpha: 0.7),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _parseTimes(String json) {
    try {
      return (jsonDecode(json) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }

  String _dateRange(MedicationScheduleEntity s) {
    final start = AppDateUtils.formatShortDate(s.startDate);
    if (s.endDate == null) return 'From $start (ongoing)';
    return '$start – ${AppDateUtils.formatShortDate(s.endDate!)}';
  }
}

class _TimeChip extends StatelessWidget {
  final String time;
  const _TimeChip({required this.time});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: cs.primary.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Text(
        _format(time),
        style: TextStyle(
          color: cs.primary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _format(String hhmm) {
    try {
      final parts = hhmm.split(':');
      int h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final ampm = h >= 12 ? 'PM' : 'AM';
      h = h % 12;
      if (h == 0) h = 12;
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $ampm';
    } catch (_) {
      return hhmm;
    }
  }
}
