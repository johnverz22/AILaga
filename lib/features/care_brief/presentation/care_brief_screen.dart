import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/date_formatter.dart';
import '../../care_recipient/data/care_recipient_providers.dart';
import '../data/care_brief_providers.dart';
import '../domain/care_brief_entity.dart';
import 'widgets/brief_section_card.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Care Brief'),
        actions: [
          IconButton(
            icon: const Icon(Icons.handshake),
            tooltip: 'Generate Handover',
            onPressed: () => context.push('/handover'),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Generate PDF Report',
            onPressed: () => context.push('/reports'),
          ),
        ],
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
                        icon: Icons.medication,
                        children: brief.medicationStatuses.isEmpty
                            ? [const Padding(padding: EdgeInsets.all(16), child: Text('No medications for this period.'))]
                            : brief.medicationStatuses.map((m) {
                                return ListTile(
                                  title: Text(m.name),
                                  subtitle: Text('Status: ${m.status.toUpperCase()}'),
                                  trailing: Text(DateFormatter.formatTime(m.scheduledTime)),
                                  onTap: () => context.push('/medications/${m.id}'), // Might just push to /medications
                                );
                              }).toList(),
                      ),
                      BriefSectionCard(
                        title: 'Recent Measurements',
                        icon: Icons.monitor_weight,
                        children: brief.recentMeasurements.isEmpty
                            ? [const Padding(padding: EdgeInsets.all(16), child: Text('No measurements for this period.'))]
                            : brief.recentMeasurements.map((m) {
                                return ListTile(
                                  title: Text('${m.type}: ${m.value} ${m.unit}'),
                                  subtitle: Text('${m.source} • ${DateFormatter.formatTime(m.timestamp)}'),
                                  onTap: () => context.push('/measurements'),
                                );
                              }).toList(),
                      ),
                      BriefSectionCard(
                        title: 'Appointments',
                        icon: Icons.calendar_today,
                        children: brief.todayAppointments.isEmpty
                            ? [const Padding(padding: EdgeInsets.all(16), child: Text('No appointments for this period.'))]
                            : brief.todayAppointments.map((a) {
                                return ListTile(
                                  title: Text(a.providerName),
                                  subtitle: Text(a.purpose),
                                  trailing: Text(DateFormatter.formatTime(a.date)),
                                  onTap: () => context.push('/appointments'),
                                );
                              }).toList(),
                      ),
                      if (brief.itemsRequiringReview.isNotEmpty)
                        BriefSectionCard(
                          title: 'Needs Attention',
                          icon: Icons.warning_amber,
                          initiallyExpanded: true,
                          children: brief.itemsRequiringReview.map((item) {
                            return ListTile(
                              leading: const Icon(Icons.error_outline, color: Colors.orange),
                              title: Text(item),
                            );
                          }).toList(),
                        ),
                      BriefSectionCard(
                        title: 'Recent Observations',
                        icon: Icons.note,
                        children: brief.recentObservations.isEmpty
                            ? [const Padding(padding: EdgeInsets.all(16), child: Text('No observations for this period.'))]
                            : brief.recentObservations.map((n) {
                                return ListTile(
                                  title: Text(n.text),
                                  subtitle: Text(DateFormatter.formatTime(n.timestamp)),
                                  onTap: () => context.push('/care-notes'),
                                );
                              }).toList(),
                      ),
                      
                      // Full text view at the bottom for easy copying or debugging
                      Card(
                        margin: const EdgeInsets.all(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Raw Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(brief.formattedText, style: const TextStyle(fontFamily: 'monospace')),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateSelectorRow extends ConsumerWidget {
  final DateTime date;
  
  const _DateSelectorRow({required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              ref.read(careBriefDateProvider.notifier).state = date.subtract(const Duration(days: 1));
            },
          ),
          Text(
            DateFormatter.formatDate(date),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              ref.read(careBriefDateProvider.notifier).state = date.add(const Duration(days: 1));
            },
          ),
        ],
      ),
    );
  }
}
