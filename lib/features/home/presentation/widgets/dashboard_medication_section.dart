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
      iconColor: const Color(0xFF0B6B6B),
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
    final now = DateTime.now();
    final isOverdue = occurrence.status == MedicationStatus.pending && 
                     occurrence.scheduledAt.isBefore(now);
                     
    Color statusColor;
    IconData statusIcon;
    
    String statusLabel;
    switch (occurrence.status) {
      case MedicationStatus.taken:
        statusColor = const Color(0xFF1B7F3B); // sure
        statusIcon = Symbols.check_circle_rounded;
        statusLabel = 'Taken';
        break;
      case MedicationStatus.skipped:
        statusColor = const Color(0xFF9A5B00); // check
        statusIcon = Symbols.cancel_rounded;
        statusLabel = 'Skipped';
        break;
      case MedicationStatus.notConfirmed:
        statusColor = const Color(0xFF9A5B00);
        statusIcon = Symbols.help_rounded;
        statusLabel = 'Check';
        break;
      case MedicationStatus.pending:
        statusColor = isOverdue ? const Color(0xFFB3261E) : Colors.grey;
        statusIcon = isOverdue
            ? Symbols.error_rounded
            : Symbols.radio_button_unchecked_rounded;
        statusLabel = isOverdue ? 'Overdue' : 'Pending';
        break;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minVerticalPadding: 12,
      leading: Icon(statusIcon, color: statusColor, size: 28),
      title: Text(
        medicationName,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isOverdue ? const Color(0xFFB3261E) : null,
        ),
      ),
      subtitle: Text(
        AppDateUtils.formatTime(occurrence.scheduledAt),
        style: TextStyle(
          color: isOverdue ? const Color(0xFFB3261E) : null,
        ),
      ),
      trailing: occurrence.status == MedicationStatus.pending
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _statusButton(
                  icon: Symbols.check_circle_rounded,
                  label: 'Taken',
                  color: const Color(0xFF1B7F3B),
                  onPressed: () {
                    ref.read(medicationRepositoryProvider)
                       .updateOccurrenceStatus(occurrence.id, MedicationStatus.taken);
                  },
                ),
                const SizedBox(height: 4),
                _statusButton(
                  icon: Symbols.cancel_rounded,
                  label: 'Skip',
                  color: const Color(0xFF9A5B00),
                  onPressed: () {
                    ref.read(medicationRepositoryProvider)
                       .updateOccurrenceStatus(occurrence.id, MedicationStatus.skipped);
                  },
                ),
              ],
            )
          : StatusChip(statusLabel, statusColor),
      onTap: () => context.push('/medications/${occurrence.medicationScheduleId}'),
    );
  }

  /// Small labeled button — icon + word, never icon alone.
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
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
