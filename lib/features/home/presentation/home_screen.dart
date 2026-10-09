import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_bar_actions.dart';
import '../../../core/utils/date_formatter.dart';
import '../../capture/presentation/widgets/pending_proposals_strip.dart';
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
        centerTitle: false,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            recipientAsync.when(
              data: (recipient) =>
                  Text('Hello, ${recipient?.displayName ?? 'Caregiver'}'),
              loading: () => const Text('AILaga'),
              error: (_, __) => const Text('AILaga'),
            ),
            Text(
              DateFormatter.formatDate(DateTime.now()),
              style: const TextStyle(fontSize: 15, color: Color(0xFF5E5748)),
            ),
          ],
        ),
        actions: const [SosAppBarButton()],
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
                PendingProposalsStrip(),
                DashboardTasksSection(),
                DashboardMedicationSection(),
                DashboardAppointmentSection(),
                DashboardMeasurementSection(),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            const Center(child: Text('Something went wrong.')),
      ),
    );
  }
}
