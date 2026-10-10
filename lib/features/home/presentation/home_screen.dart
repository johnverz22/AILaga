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
import 'widgets/phone_helper_setup_banner.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipientAsync = ref.watch(primaryCareRecipientProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 16,
        title: recipientAsync.when(
          data: (recipient) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                recipient?.displayName ?? 'Caregiver',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                DateFormatter.formatDate(DateTime.now()),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          loading: () => const Text('AILaga', style: TextStyle(fontSize: 18)),
          error: (_, __) => const Text('AILaga', style: TextStyle(fontSize: 18)),
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
                PhoneHelperSetupBanner(),
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
