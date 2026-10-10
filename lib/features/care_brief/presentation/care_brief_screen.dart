import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/date_formatter.dart';
import '../../care_recipient/data/care_recipient_providers.dart';
import '../data/care_brief_providers.dart';
import '../domain/care_brief_entity.dart';
import 'widgets/brief_section_card.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

final careBriefDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final careBriefProvider = FutureProvider.autoDispose<CareBriefEntity?>((ref) async {
  final recipient = ref.watch(primaryCareRecipientProvider).value;
  if (recipient == null) return null;
  
  final date = ref.watch(careBriefDateProvider);
  final start = DateTime(date.year, date.month, date.day);
  final end = DateTime(date.year, date.month, date.day, 23, 59, 59);
  
  final service = ref.watch(careBriefServiceProvider);
  return service.generateBrief(
    recipientId: recipient.id,
    periodStart: start,
    periodEnd: end,
  );
});

class CareBriefScreen extends ConsumerWidget {
  const CareBriefScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(careBriefDateProvider);
    final briefAsync = ref.watch(careBriefProvider);

    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Care Brief'),
      ),
      // Action buttons pinned to the bottom — this screen has no bottom
      // nav bar (pushed page), so they sit at the screen's lower edge.
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border(top: BorderSide(color: cs.outline, width: 1.5)),
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: () => context.push('/handover'),
                    icon: const Icon(Symbols.handshake_rounded),
                    label: const Text('Handover'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/reports'),
                    icon: const Icon(Symbols.picture_as_pdf_rounded),
                    label: const Text('PDF report'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          _DateSelectorRow(date: date),
          Expanded(
            child: briefAsync.when(
              data: (brief) {
                if (brief == null) {
                  return const Center(child: Text('No care recipient found.'));
                }
                
                return RefreshIndicator(
                  onRefresh: () async => ref.refresh(careBriefProvider.future),
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 32, top: 8),
                    children: [
                      BriefSectionCard(
                        title: 'Medications',
                        icon: Symbols.medication_rounded,
                        accent: const Color(0xFF0B6B6B),
                        count: brief.medicationStatuses.length,
                        children: brief.medicationStatuses.isEmpty
                            ? [_empty('No medications for this period.')]
                            : brief.medicationStatuses.map((m) {
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                  minVerticalPadding: 12,
                                  title: Text(m.name,
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text(DateFormatter.formatTime(m.scheduledTime)),
                                  trailing: _medStatusChip(m.status),
                                  onTap: () => context.push('/medications/${m.id}'),
                                );
                              }).toList(),
                      ),
                      BriefSectionCard(
                        title: 'Recent Measurements',
                        icon: Symbols.monitor_heart_rounded,
                        accent: const Color(0xFF1B7F3B),
                        count: brief.recentMeasurements.length,
                        children: brief.recentMeasurements.isEmpty
                            ? [_empty('No measurements for this period.')]
                            : brief.recentMeasurements.map((m) {
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                  minVerticalPadding: 12,
                                  title: Text('${m.type}: ${m.value} ${m.unit}',
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text('${m.source} • ${DateFormatter.formatTime(m.timestamp)}'),
                                  trailing: const Icon(Symbols.chevron_right_rounded, color: Colors.grey),
                                  onTap: () => context.push('/measurements'),
                                );
                              }).toList(),
                      ),
                      BriefSectionCard(
                        title: 'Appointments',
                        icon: Symbols.event_rounded,
                        accent: const Color(0xFF2F4B8A),
                        count: brief.todayAppointments.length,
                        children: brief.todayAppointments.isEmpty
                            ? [_empty('No appointments for this period.')]
                            : brief.todayAppointments.map((a) {
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                  minVerticalPadding: 12,
                                  title: Text(a.providerName,
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text(a.purpose),
                                  trailing: Text(DateFormatter.formatTime(a.date)),
                                  onTap: () => context.push('/appointments'),
                                );
                              }).toList(),
                      ),
                      if (brief.itemsRequiringReview.isNotEmpty)
                        BriefSectionCard(
                          title: 'Needs Attention',
                          icon: Symbols.warning_amber_rounded,
                          accent: const Color(0xFF9A5B00),
                          count: brief.itemsRequiringReview.length,
                          initiallyExpanded: true,
                          children: brief.itemsRequiringReview.map((item) {
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              leading: const Icon(Symbols.error_rounded,
                                  color: Color(0xFF9A5B00)),
                              title: Text(item),
                            );
                          }).toList(),
                        ),
                      BriefSectionCard(
                        title: 'Recent Observations',
                        icon: Symbols.note_rounded,
                        accent: const Color(0xFF6B5BA8),
                        count: brief.recentObservations.length,
                        children: brief.recentObservations.isEmpty
                            ? [_empty('No observations for this period.')]
                            : brief.recentObservations.map((n) {
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                  minVerticalPadding: 12,
                                  title: Text(n.text),
                                  subtitle: Text(DateFormatter.formatTime(n.timestamp)),
                                  trailing: const Icon(Symbols.chevron_right_rounded, color: Colors.grey),
                                  onTap: () => context.push('/care-notes'),
                                );
                              }).toList(),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Something went wrong.')),
            ),
          ),
        ],
      ),
    );
  }
}

/// Uniform empty-state row used inside brief cards.
Widget _empty(String text) => Padding(
      padding: const EdgeInsets.all(16),
      child: Text(text),
    );

/// Colored pill for a MedicationStatus.name string (taken/skipped/…).
Widget _medStatusChip(String status) {
  final (label, color) = switch (status) {
    'taken' => ('Taken', const Color(0xFF1B7F3B)),
    'skipped' => ('Skipped', const Color(0xFF9A5B00)),
    'notConfirmed' => ('Check', const Color(0xFF9A5B00)),
    'pending' => ('Pending', Colors.grey),
    _ => (status, Colors.grey),
  };
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(label,
        style: TextStyle(
            color: color, fontSize: 12, fontWeight: FontWeight.w600)),
  );
}

class _DateSelectorRow extends ConsumerWidget {
  final DateTime date;
  
  const _DateSelectorRow({required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Theme card colors — readable in both light and dark mode.
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Symbols.chevron_left_rounded),
            tooltip: 'Previous day',
            onPressed: () {
              ref.read(careBriefDateProvider.notifier).state = date.subtract(const Duration(days: 1));
            },
          ),
          Text(
            DateFormatter.formatDate(date),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Symbols.chevron_right_rounded),
            tooltip: 'Next day',
            onPressed: () {
              ref.read(careBriefDateProvider.notifier).state = date.add(const Duration(days: 1));
            },
          ),
        ],
      ),
    );
  }
}
