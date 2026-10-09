import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../care_recipient/data/care_recipient_providers.dart';
import '../../../appointments/data/appointment_providers.dart';
import '../../../appointments/domain/appointment_entity.dart';

final nextAppointmentProvider =
    StreamProvider.autoDispose<AppointmentEntity?>((ref) {
  final recipient = ref.watch(primaryCareRecipientProvider).value;
  if (recipient == null) return Stream.value(null);

  return ref
      .watch(appointmentRepositoryProvider)
      .watchUpcoming(recipient.id)
      .map((list) {
    if (list.isEmpty) return null;
    return list.first; // Assuming watchUpcoming returns them sorted by date
  });
});

class DashboardAppointmentSection extends ConsumerWidget {
  const DashboardAppointmentSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextAppointmentAsync = ref.watch(nextAppointmentProvider);
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
                Text('Next Appointment', style: theme.textTheme.titleMedium),
                TextButton(
                  onPressed: () => context.push('/appointments'),
                  child: const Text('All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            nextAppointmentAsync.when(
              data: (appointment) {
                if (appointment == null) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No upcoming appointments'),
                    ),
                  );
                }

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event, color: Colors.blue),
                  title: Text(appointment.providerOrFacility ??
                      'Unknown Provider'), // Use providerOrFacility instead of providerName
                  subtitle: Text(
                      '${DateFormatter.formatDate(appointment.scheduledAt)} at ${DateFormatter.formatTime(appointment.scheduledAt)}\n${appointment.purpose}'), // Use scheduledAt instead of date
                  isThreeLine: true,
                  onTap: () => context.push('/appointments'),
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
