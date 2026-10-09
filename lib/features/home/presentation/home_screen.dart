import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../care_recipient/data/care_recipient_providers.dart';
import 'widgets/dashboard_tasks_section.dart';
import 'widgets/dashboard_medication_section.dart';
import 'widgets/dashboard_appointment_section.dart';
import 'widgets/dashboard_measurement_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipientAsync = ref.watch(primaryCareRecipientProvider);

    return Scaffold(
      appBar: AppBar(
        title: recipientAsync.when(
          data: (recipient) => Text('Hello, ${recipient?.displayName ?? 'Caregiver'}'),
          loading: () => const Text('AILaga'),
          error: (_, __) => const Text('AILaga'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () => context.push('/emergency'),
              icon: const Icon(Icons.sos),
              label: const Text('SOS'),
            ),
          ),
        ],
      ),
      body: recipientAsync.when(
        data: (recipient) {
          if (recipient == null) {
            return const Center(child: Text('No care recipient found.'));
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              // Refresh logic if any
            },
            child: ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: const [
                DashboardTasksSection(),
                DashboardMedicationSection(),
                DashboardAppointmentSection(),
                DashboardMeasurementSection(),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
