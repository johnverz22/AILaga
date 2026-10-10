import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utilities/date_utils.dart';
import '../../../care_recipient/data/care_recipient_providers.dart';
import '../../../medications/data/medication_providers.dart';
import '../../../medications/domain/medication_entity.dart';
import '../../../medications/domain/medication_status.dart';
import 'dashboard_section.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

final todayOccurrencesProvider = StreamProvider.autoDispose<List<MedicationOccurrenceEntity>>((ref) {
  final recipient = ref.watch(primaryCareRecipientProvider).value;
  if (recipient == null) return const Stream.empty();
  return ref.watch(medicationRepositoryProvider).watchTodayOccurrences(recipient.id);
});

class DashboardMedicationSection extends ConsumerWidget {
  const DashboardMedicationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occurrencesAsync = ref.watch(todayOccurrencesProvider);
    final recipient = ref.watch(primaryCareRecipientProvider).value;

    return DashboardSection(
      icon: Symbols.medication_rounded,
      iconColor: Theme.of(context).colorScheme.primary,
      title: 'Today\'s Medications',
      action: TextButton(
        onPressed: () => context.push('/medications'),
        child: const Text('All'),
      ),
      children: [
        occurrencesAsync.when(
          data: (occurrences) {
            if (occurrences.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No medications scheduled for today'),
              );
            }

            // Sort by time
            final sorted = List<MedicationOccurrenceEntity>.from(occurrences)
              ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

            return Consumer(
              builder: (context, ref, child) {
                if (recipient == null) return const SizedBox.shrink();
                final schedulesAsync =
                    ref.watch(activeSchedulesProvider(recipient.id));

                return schedulesAsync.when(
                  data: (schedules) {
                    final scheduleMap = {for (var s in schedules) s.id: s};
                    return _MedRows(
                      occurrences: sorted,
                      nameFor: (occ) =>
                          scheduleMap[occ.medicationScheduleId]
                              ?.medicationName ??
                          'Unknown Medication',
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, stack) => Center(child: Text('Something went wrong.')),
                );
              },
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => Center(child: Text('Something went wrong.')),
        ),
      ],
    );
  }
}

/// Occurrence rows with hairline dividers between them.
class _MedRows extends StatelessWidget {
  final List<MedicationOccurrenceEntity> occurrences;
  final String Function(MedicationOccurrenceEntity) nameFor;

  const _MedRows({required this.occurrences, required this.nameFor});

  @override
  Widget build(BuildContext context) {
    final out = <Widget>[];
    for (var i = 0; i < occurrences.length; i++) {
      if (i > 0) {
        out.add(const Divider(height: 1, indent: 16, endIndent: 16));
      }
      final occ = occurrences[i];
      out.add(_MedicationItem(occurrence: occ, medicationName: nameFor(occ)));
    }
    return Column(children: out);
  }
}

class _MedicationItem extends ConsumerWidget {
  final MedicationOccurrenceEntity occurrence;
  final String medicationName;
  
  const _MedicationItem({required this.occurrence, required this.medicationName});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final isOverdue = occurrence.status == MedicationStatus.pending &&
                     occurrence.scheduledAt.isBefore(now);

    // Semantic colors via colorScheme so they adapt to light/dark.
    final Color takenColor = const Color(0xFF1B7F3B);   // sure — always readable
    final Color checkColor = const Color(0xFF9A5B00);   // check — always readable
    final Color overdueColor = cs.error;
    final Color pendingColor = cs.onSurface.withValues(alpha: 0.45);

    Color statusColor;
    IconData statusIcon;
    String statusLabel;
    switch (occurrence.status) {
      case MedicationStatus.taken:
        statusColor = takenColor;
        statusIcon = Symbols.check_circle_rounded;
        statusLabel = 'Taken';
        break;
      case MedicationStatus.skipped:
        statusColor = checkColor;
        statusIcon = Symbols.cancel_rounded;
        statusLabel = 'Skipped';
        break;
      case MedicationStatus.notConfirmed:
        statusColor = checkColor;
        statusIcon = Symbols.help_rounded;
        statusLabel = 'Check';
        break;
      case MedicationStatus.pending:
        statusColor = isOverdue ? overdueColor : pendingColor;
        statusIcon = isOverdue
            ? Symbols.error_rounded
            : Symbols.radio_button_unchecked_rounded;
        statusLabel = isOverdue ? 'Overdue' : 'Pending';
        break;
    }

    return InkWell(
      onTap: () => context.push('/medications/${occurrence.medicationScheduleId}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: status icon + name + status chip
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicationName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isOverdue ? cs.error : null,
                        ),
                      ),
                      Text(
                        AppDateUtils.formatTime(occurrence.scheduledAt),
                        style: TextStyle(
                          fontSize: 14,
                          color: isOverdue ? cs.error : cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (occurrence.status != MedicationStatus.pending)
                  StatusChip(statusLabel, statusColor),
              ],
            ),
            // Bottom row: action buttons (pending only)
            if (occurrence.status == MedicationStatus.pending) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const SizedBox(width: 40), // align with text above
                  Expanded(
                    child: _statusButton(
                      icon: Symbols.check_circle_rounded,
                      label: 'Taken',
                      color: takenColor,
                      onPressed: () {
                        ref.read(medicationRepositoryProvider)
                            .updateOccurrenceStatus(
                                occurrence.id, MedicationStatus.taken);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _statusButton(
                      icon: Symbols.cancel_rounded,
                      label: 'Skip',
                      color: checkColor,
                      onPressed: () {
                        ref.read(medicationRepositoryProvider)
                            .updateOccurrenceStatus(
                                occurrence.id, MedicationStatus.skipped);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Labeled button — icon + word, never icon alone. Stretches to fill width.
  static Widget _statusButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
