import 'package:flutter/material.dart';
import '../../domain/appointment_entity.dart';
import '../../../../core/utilities/date_utils.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Displays a single appointment with status badge, date, provider and actions.
class AppointmentCard extends StatelessWidget {
  final AppointmentEntity appointment;
  final VoidCallback? onTap;
  final VoidCallback? onMarkCompleted;
  final VoidCallback? onMarkCancelled;
  final VoidCallback? onDelete;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
    this.onMarkCompleted,
    this.onMarkCancelled,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final (statusColor, statusIcon, statusLabel) = _statusStyle(cs);
    final isUpcoming = appointment.status == 'scheduled' &&
        appointment.scheduledAt.isAfter(DateTime.now());

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Date block
                  Container(
                    width: 52,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isUpcoming
                          ? cs.primary.withValues(alpha: 0.1)
                          : cs.onSurface.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _monthAbbr(appointment.scheduledAt),
                          style: theme.textTheme.labelSmall!.copyWith(
                            color: isUpcoming
                                ? cs.primary
                                : cs.onSurface.withValues(alpha: 0.5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          appointment.scheduledAt.day.toString(),
                          style: theme.textTheme.titleLarge!.copyWith(
                            color: isUpcoming
                                ? cs.primary
                                : cs.onSurface.withValues(alpha: 0.5),
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                appointment.purpose ?? 'Appointment',
                                style: theme.textTheme.titleSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _StatusBadge(
                              label: statusLabel,
                              color: statusColor,
                              icon: statusIcon,
                            ),
                          ],
                        ),
                        if (appointment.providerOrFacility?.isNotEmpty == true)
                          Text(
                            appointment.providerOrFacility!,
                            style: theme.textTheme.bodySmall!.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.6),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        Text(
                          AppDateUtils.formatTime(appointment.scheduledAt),
                          style: theme.textTheme.bodySmall!.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions menu
                  if (appointment.status == 'scheduled')
                    PopupMenuButton<String>(
                      icon: const Icon(Symbols.more_vert_rounded, size: 20),
                      onSelected: (action) {
                        if (action == 'complete') onMarkCompleted?.call();
                        if (action == 'cancel') onMarkCancelled?.call();
                        if (action == 'delete') onDelete?.call();
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                            value: 'complete',
                            child: Row(children: [
                              Icon(Symbols.check_circle_rounded,
                                  color: Color(0xFF16A34A), size: 18),
                              SizedBox(width: 10),
                              Text('Mark Completed'),
                            ])),
                        const PopupMenuItem(
                            value: 'cancel',
                            child: Row(children: [
                              Icon(Symbols.cancel_rounded,
                                  color: Color(0xFFD97706), size: 18),
                              SizedBox(width: 10),
                              Text('Cancel Appointment'),
                            ])),
                        const PopupMenuItem(
                            value: 'delete',
                            child: Row(children: [
                              Icon(Symbols.delete_rounded,
                                  color: Colors.red, size: 18),
                              SizedBox(width: 10),
                              Text('Delete'),
                            ])),
                      ],
                    )
                  else if (onDelete != null)
                    TextButton.icon(
                      icon: Icon(Symbols.delete_rounded,
                          size: 18,
                          color: cs.error.withValues(alpha: 0.7)),
                      label: Text('Delete',
                          style: TextStyle(
                              color: cs.error.withValues(alpha: 0.8))),
                      onPressed: onDelete,
                    ),
                ],
              ),
              if (appointment.notes?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  appointment.notes!,
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.5),
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  (Color, IconData, String) _statusStyle(ColorScheme cs) {
    switch (appointment.status) {
      case 'completed':
        return (const Color(0xFF16A34A), Symbols.check_circle_rounded, 'Completed');
      case 'cancelled':
        return (const Color(0xFFD97706), Symbols.cancel_rounded, 'Cancelled');
      default:
        return (cs.primary, Symbols.calendar_today_rounded, 'Scheduled');
    }
  }

  String _monthAbbr(DateTime dt) {
    const months = [
      'JAN','FEB','MAR','APR','MAY','JUN',
      'JUL','AUG','SEP','OCT','NOV','DEC'
    ];
    return months[dt.month - 1];
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _StatusBadge(
      {required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
