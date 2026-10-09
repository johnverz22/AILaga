import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../care_recipient/data/care_recipient_providers.dart';
import '../../../medications/data/medication_providers.dart';
import '../../../medications/domain/medication_entity.dart';
import '../../../medications/domain/medication_status.dart';

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
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Today\'s Medications', style: theme.textTheme.titleMedium),
                TextButton(
                  onPressed: () => context.push('/medications'),
                  child: const Text('All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            occurrencesAsync.when(
              data: (occurrences) {
                if (occurrences.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No medications scheduled for today'),
                    ),
                  );
                }
                
                // Sort by time
                final sorted = List<MedicationOccurrenceEntity>.from(occurrences)
                  ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
                  
                return Column(
                  children: sorted.map((occ) => _MedicationItem(occurrence: occ)).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicationItem extends ConsumerWidget {
  final MedicationOccurrenceEntity occurrence;
  
  const _MedicationItem({required this.occurrence});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final isOverdue = occurrence.status == MedicationStatus.pending && 
                     occurrence.scheduledTime.isBefore(now);
                     
    Color statusColor;
    IconData statusIcon;
    
    switch (occurrence.status) {
      case MedicationStatus.taken:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case MedicationStatus.skipped:
        statusColor = Colors.orange;
        statusIcon = Icons.cancel;
        break;
      case MedicationStatus.pending:
      default:
        statusColor = isOverdue ? Colors.red : Colors.grey;
        statusIcon = isOverdue ? Icons.error_outline : Icons.radio_button_unchecked;
        break;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(statusIcon, color: statusColor),
      title: Text(
        occurrence.medicationName,
        style: TextStyle(
          color: isOverdue ? Colors.red : null,
          fontWeight: isOverdue ? FontWeight.bold : null,
        ),
      ),
      subtitle: Text(
        DateFormatter.formatTime(occurrence.scheduledTime),
        style: TextStyle(
          color: isOverdue ? Colors.red : null,
        ),
      ),
      trailing: occurrence.status == MedicationStatus.pending
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    ref.read(medicationRepositoryProvider)
                       .updateOccurrenceStatus(occurrence.id, MedicationStatus.taken);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.orange),
                  onPressed: () {
                    ref.read(medicationRepositoryProvider)
                       .updateOccurrenceStatus(occurrence.id, MedicationStatus.skipped);
                  },
                ),
              ],
            )
          : Text(
              occurrence.status.name.toUpperCase(),
              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
            ),
      onTap: () => context.push('/medications/${occurrence.scheduleId}'),
    );
  }
}
