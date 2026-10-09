import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../care_recipient/data/care_recipient_providers.dart';
import '../../../medications/data/medication_providers.dart';
import '../../../medications/domain/medication_status.dart';
import '../../../appointments/data/appointment_providers.dart';
import '../../../care_notes/data/care_note_providers.dart';

final pendingTasksProvider = StreamProvider.autoDispose<int>((ref) {
  final recipient = ref.watch(primaryCareRecipientProvider).value;
  if (recipient == null) return Stream.value(0);
  
  final occurrencesStream = ref.watch(medicationRepositoryProvider).watchTodayOccurrences(recipient.id);
  final appointmentsStream = ref.watch(appointmentRepositoryProvider).watchUpcoming(recipient.id);
  final notesStream = ref.watch(careNoteRepositoryProvider).watchRecent(recipient.id, limit: 50);
  
  // Combine streams or just use occurrences for now if simpler, but let's do a basic combine
  // For simplicity, we'll just sum them up whenever any updates.
  // Actually, we can use `Rx.combineLatest3` from rxdart if available, but let's just listen.
  
  // To avoid complex stream combining without rxdart, we can just do individual providers:
  return Stream.value(0); // We will use multiple watchers in the build method instead
});

class DashboardTasksSection extends ConsumerWidget {
  const DashboardTasksSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipient = ref.watch(primaryCareRecipientProvider).value;
    if (recipient == null) return const SizedBox();

    final occurrencesAsync = ref.watch(StreamProvider.autoDispose((ref) => 
      ref.watch(medicationRepositoryProvider).watchTodayOccurrences(recipient.id)));
      
    final appointmentsAsync = ref.watch(StreamProvider.autoDispose((ref) => 
      ref.watch(appointmentRepositoryProvider).watchUpcoming(recipient.id)));
      
    final notesAsync = ref.watch(StreamProvider.autoDispose((ref) => 
      ref.watch(careNoteRepositoryProvider).watchRecent(recipient.id, limit: 50)));

    int pendingMedsCount = 0;
    int upcomingApptsTodayCount = 0;
    int unreviewedNotesCount = 0;

    if (occurrencesAsync.hasValue) {
      pendingMedsCount = occurrencesAsync.value!.where((m) => m.status == MedicationStatus.pending).length;
    }
    
    if (appointmentsAsync.hasValue) {
      final now = DateTime.now();
      upcomingApptsTodayCount = appointmentsAsync.value!.where((a) => 
        a.date.year == now.year && a.date.month == now.month && a.date.day == now.day && a.date.isAfter(now)
      ).length;
    }
    
    if (notesAsync.hasValue) {
      unreviewedNotesCount = notesAsync.value!.where((n) => n.reviewStatus == 'pending' || n.reviewStatus == 'unreviewed').length;
    }
    
    final totalTasks = pendingMedsCount + upcomingApptsTodayCount + unreviewedNotesCount;

    if (totalTasks == 0) return const SizedBox(); // Hide if no tasks

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment, color: Theme.of(context).colorScheme.onPrimaryContainer),
                const SizedBox(width: 8),
                Text('Needs Attention ($totalTasks)', 
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  )
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (pendingMedsCount > 0)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.medication, color: Colors.orange),
                title: Text('$pendingMedsCount pending medication(s)'),
                onTap: () => context.push('/medications'),
                dense: true,
              ),
            if (upcomingApptsTodayCount > 0)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: Colors.blue),
                title: Text('$upcomingApptsTodayCount upcoming appointment(s) today'),
                onTap: () => context.push('/appointments'),
                dense: true,
              ),
            if (unreviewedNotesCount > 0)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.note, color: Colors.purple),
                title: Text('$unreviewedNotesCount unreviewed care note(s)'),
                onTap: () => context.push('/care-notes'),
                dense: true,
              ),
          ],
        ),
      ),
    );
  }
}
