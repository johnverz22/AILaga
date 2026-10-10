import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../care_recipient/data/care_recipient_providers.dart';
import '../../../appointments/data/appointment_providers.dart';
import '../../../appointments/domain/appointment_entity.dart';
import 'dashboard_section.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

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

    return DashboardSection(
      icon: Symbols.event_rounded,
      iconColor: Theme.of(context).colorScheme.secondary,
      title: 'Next Appointment',
      action: TextButton(
        onPressed: () => context.push('/appointments'),
        child: const Text('All'),
      ),
      children: [
        nextAppointmentAsync.when(
          data: (appointment) {
            if (appointment == null) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No upcoming appointments'),
              );
            }

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              minVerticalPadding: 12,
              leading: Icon(Symbols.event_rounded,
                  color: Theme.of(context).colorScheme.secondary, size: 28),
              title: Text(
                appointment.providerOrFacility ?? 'Unknown Provider',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                  '${DateFormatter.formatDate(appointment.scheduledAt)} at ${DateFormatter.formatTime(appointment.scheduledAt)}\n${appointment.purpose}'),
              isThreeLine: true,
              trailing: Icon(Symbols.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
              onTap: () => context.push('/appointments'),
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
