import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/medication_providers.dart';
import '../domain/medication_entity.dart';
import 'widgets/medication_card.dart';
import '../../care_recipient/data/care_recipient_providers.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Lists all medication schedules for the primary care recipient.
/// Active schedules appear first; inactive below.
class MedicationsScreen extends ConsumerWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipientAsync = ref.watch(primaryCareRecipientProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Medications')),
      body: recipientAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Something went wrong. Try again.')),
        data: (recipient) {
          if (recipient == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Symbols.medication_rounded,
                        size: 64,
                        color: theme.colorScheme.primary.withValues(alpha: 0.4)),
                    const SizedBox(height: 20),
                    Text('No care recipient found',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    const Text(
                      'Please add a care recipient profile first.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: () => context.push('/care-recipient/edit'),
                      child: const Text('Add Care Recipient'),
                    ),
                  ],
                ),
              ),
            );
          }

          final activeAsync =
              ref.watch(activeSchedulesProvider(recipient.id));

          return activeAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Something went wrong. Try again.')),
            data: (schedules) =>
                _buildList(context, ref, recipient.id, schedules),
          );
        },
      ),
      floatingActionButton: recipientAsync.whenOrNull(
        data: (r) => r != null
            ? FloatingActionButton.extended(
                onPressed: () =>
                    context.push('/medications/add', extra: r.id),
                icon: const Icon(Symbols.add_rounded),
                label: const Text('Add Medication'),
              )
            : null,
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    String recipientId,
    List<MedicationScheduleEntity> schedules,
  ) {
    final theme = Theme.of(context);

    if (schedules.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Symbols.medication_rounded,
                  size: 64,
                  color: theme.colorScheme.primary.withValues(alpha: 0.4)),
              const SizedBox(height: 20),
              Text('No medications yet',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              const Text(
                'Add medications to track doses and receive reminders.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 96, top: 8),
      itemCount: schedules.length,
      itemBuilder: (ctx, i) {
        final s = schedules[i];
        return MedicationCard(
          schedule: s,
          onTap: () => context.push('/medications/${s.id}'),
          onDeactivate: s.isActive
              ? () => _confirmDeactivate(context, ref, s)
              : null,
        );
      },
    );
  }

  Future<void> _confirmDeactivate(
    BuildContext context,
    WidgetRef ref,
    MedicationScheduleEntity schedule,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate Medication?'),
        content: Text(
          'This will stop tracking new doses for "${schedule.medicationName}". '
          'History will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Deactivate',
              style: TextStyle(
                  color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final repo = ref.read(medicationRepositoryProvider);
      await repo.deactivateSchedule(schedule.id);
    }
  }
}
