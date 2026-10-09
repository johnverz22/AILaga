import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/appointment_providers.dart';
import '../domain/appointment_entity.dart';
import 'widgets/appointment_card.dart';
import '../../care_recipient/data/care_recipient_providers.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Appointments screen with two tabs: Upcoming and Past.
class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipientAsync = ref.watch(primaryCareRecipientProvider);
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Appointments'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
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
                      Icon(Symbols.calendar_month_rounded,
                          size: 64,
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.4)),
                      const SizedBox(height: 20),
                      Text('No care recipient found',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        onPressed: () =>
                            context.push('/care-recipient/edit'),
                        child: const Text('Add Care Recipient'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return _AppointmentTabs(recipientId: recipient.id);
          },
        ),
        floatingActionButton: recipientAsync.whenOrNull(
          data: (r) => r != null
              ? FloatingActionButton.extended(
                  onPressed: () =>
                      context.push('/appointments/add', extra: r.id),
                  icon: const Icon(Symbols.add_rounded),
                  label: const Text('Add Appointment'),
                )
              : null,
        ),
      ),
    );
  }
}

class _AppointmentTabs extends ConsumerWidget {
  final String recipientId;
  const _AppointmentTabs({required this.recipientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TabBarView(
      children: [
        _AppointmentList(
          recipientId: recipientId,
          upcoming: true,
        ),
        _AppointmentList(
          recipientId: recipientId,
          upcoming: false,
        ),
      ],
    );
  }
}

class _AppointmentList extends ConsumerWidget {
  final String recipientId;
  final bool upcoming;
  const _AppointmentList(
      {required this.recipientId, required this.upcoming});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return FutureBuilder<List<AppointmentEntity>>(
      future: _fetch(ref),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final appointments = snap.data ?? [];

        if (appointments.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Symbols.event_available_rounded,
                      size: 64,
                      color: theme.colorScheme.primary
                          .withValues(alpha: 0.4)),
                  const SizedBox(height: 20),
                  Text(
                    upcoming
                        ? 'No upcoming appointments'
                        : 'No past appointments',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async =>
              (context as Element).markNeedsBuild(),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 96),
            itemCount: appointments.length,
            itemBuilder: (ctx, i) {
              final appt = appointments[i];
              return AppointmentCard(
                appointment: appt,
                onTap: () => context.push(
                  '/appointments/add',
                  extra: {
                    'recipientId': recipientId,
                    'appointmentId': appt.id,
                  },
                ),
                onMarkCompleted: appt.status == 'scheduled'
                    ? () => _updateStatus(ref, appt.id, 'completed')
                    : null,
                onMarkCancelled: appt.status == 'scheduled'
                    ? () => _updateStatus(ref, appt.id, 'cancelled')
                    : null,
                onDelete: () => _confirmDelete(context, ref, appt),
              );
            },
          ),
        );
      },
    );
  }

  Future<List<AppointmentEntity>> _fetch(WidgetRef ref) async {
    final repo = ref.read(appointmentRepositoryProvider);
    final all = await repo.getByRecipient(recipientId);
    final now = DateTime.now();
    if (upcoming) {
      return all
          .where((a) =>
              a.scheduledAt.isAfter(now) && a.status == 'scheduled')
          .toList();
    } else {
      return all
          .where((a) =>
              a.scheduledAt.isBefore(now) || a.status != 'scheduled')
          .toList()
        ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    }
  }

  Future<void> _updateStatus(
      WidgetRef ref, String id, String status) async {
    await ref.read(appointmentRepositoryProvider).updateStatus(id, status);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppointmentEntity appt,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Appointment?'),
        content: Text(
            'Delete "${appt.purpose ?? 'this appointment'}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete',
                style: TextStyle(
                    color: Theme.of(ctx).colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(appointmentRepositoryProvider).delete(appt.id);
    }
  }
}
