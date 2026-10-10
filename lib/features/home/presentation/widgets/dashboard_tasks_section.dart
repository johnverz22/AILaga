import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../care_recipient/data/care_recipient_providers.dart';
import '../../../medications/data/medication_providers.dart';
import '../../../medications/domain/medication_entity.dart';
import '../../../medications/domain/medication_status.dart';
import '../../../appointments/data/appointment_providers.dart';
import '../../../appointments/domain/appointment_entity.dart';
import '../../../care_notes/data/care_note_providers.dart';
import '../../../care_notes/domain/care_note_entity.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

// Providers must be top-level — creating them inside build() makes a new
// provider every rebuild → new subscription → new emission → rebuild loop
// (visible as constant flicker).
final _todayOccurrencesProvider =
    StreamProvider.autoDispose<List<MedicationOccurrenceEntity>>((ref) {
  final recipient = ref.watch(primaryCareRecipientProvider).value;
  if (recipient == null) return const Stream.empty();
  return ref
      .watch(medicationRepositoryProvider)
      .watchTodayOccurrences(recipient.id);
});

final _upcomingAppointmentsProvider =
    StreamProvider.autoDispose<List<AppointmentEntity>>((ref) {
  final recipient = ref.watch(primaryCareRecipientProvider).value;
  if (recipient == null) return const Stream.empty();
  return ref
      .watch(appointmentRepositoryProvider)
      .watchUpcoming(recipient.id);
});

final _recentNotesProvider =
    StreamProvider.autoDispose<List<CareNoteEntity>>((ref) {
  final recipient = ref.watch(primaryCareRecipientProvider).value;
  if (recipient == null) return const Stream.empty();
  return ref
      .watch(careNoteRepositoryProvider)
      .watchRecent(recipient.id, limit: 50);
});

class DashboardTasksSection extends ConsumerWidget {
  const DashboardTasksSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipient = ref.watch(primaryCareRecipientProvider).value;
    if (recipient == null) return const SizedBox();

    final occurrencesAsync = ref.watch(_todayOccurrencesProvider);
    final appointmentsAsync = ref.watch(_upcomingAppointmentsProvider);
    final notesAsync = ref.watch(_recentNotesProvider);

    int pendingMedsCount = 0;
    int upcomingApptsTodayCount = 0;
    int unreviewedNotesCount = 0;

    if (occurrencesAsync.hasValue) {
      pendingMedsCount = occurrencesAsync.value!.where((m) => m.status == MedicationStatus.pending).length;
    }
    
    if (appointmentsAsync.hasValue) {
      final now = DateTime.now();
      upcomingApptsTodayCount = appointmentsAsync.value!.where((a) => 
        a.scheduledAt.year == now.year && a.scheduledAt.month == now.month && a.scheduledAt.day == now.day && a.scheduledAt.isAfter(now)
      ).length;
    }
    
    if (notesAsync.hasValue) {
      unreviewedNotesCount = notesAsync.value!.where((n) => n.reviewStatus == 'pending' || n.reviewStatus == 'unreviewed').length;
    }
    
    final totalTasks = pendingMedsCount + upcomingApptsTodayCount + unreviewedNotesCount;

    if (totalTasks == 0) return const SizedBox(); // Hide if no tasks

    const amber = Color(0xFF9A5B00);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: amber.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0x55C98A2E), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Symbols.priority_high_rounded,
                      color: amber, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Needs Attention',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: amber,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('$totalTasks',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          if (pendingMedsCount > 0)
            _taskRow(context, Symbols.medication_rounded, amber,
                '$pendingMedsCount pending medication(s)', '/medications'),
          if (upcomingApptsTodayCount > 0)
            _taskRow(context, Symbols.event_rounded, amber,
                '$upcomingApptsTodayCount appointment(s) today', '/appointments'),
          if (unreviewedNotesCount > 0)
            _taskRow(context, Symbols.note_rounded, amber,
                '$unreviewedNotesCount care note(s) to check', '/care-notes'),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _taskRow(BuildContext context, IconData icon, Color color,
      String label, String route) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => context.push(route),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(label)),
            Icon(Symbols.chevron_right_rounded,
                color: cs.onSurface.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }
}
