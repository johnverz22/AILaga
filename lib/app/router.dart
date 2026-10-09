import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/care_recipient/presentation/care_recipient_screen.dart';
import '../features/care_recipient/presentation/edit_care_recipient_screen.dart';
import '../features/medications/presentation/medications_screen.dart';
import '../features/medications/presentation/add_medication_screen.dart';
import '../features/medications/presentation/medication_detail_screen.dart';
import '../features/measurements/presentation/measurements_screen.dart';
import '../features/measurements/presentation/add_measurement_screen.dart';
import '../features/appointments/presentation/appointments_screen.dart';
import '../features/appointments/presentation/add_appointment_screen.dart';
import '../features/care_notes/presentation/care_notes_screen.dart';
import '../features/care_notes/presentation/add_care_note_screen.dart';
import '../features/care_brief/presentation/care_brief_screen.dart';
import '../features/handover/presentation/handover_screen.dart';
import '../features/emergency/presentation/emergency_screen.dart';
import '../features/family_contacts/presentation/family_contacts_screen.dart';
import '../features/family_contacts/presentation/add_family_contact_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/care_recipient/data/care_recipient_providers.dart';

// Shell Navigation Widget
class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Get the current location to determine selected tab
    final location = GoRouterState.of(context).uri.path;

    int getIndex() {
      if (location.startsWith('/medications')) return 1;
      if (location.startsWith('/measurements')) return 2;
      if (location.startsWith('/appointments')) return 3;
      if (location.startsWith('/care-notes') ||
          location.startsWith('/settings') ||
          location.startsWith('/family-contacts') ||
          location.startsWith('/reports') ||
          location.startsWith('/care-brief') ||
          location.startsWith('/handover') ||
          location.startsWith('/care-recipient')) {
        return 4;
      }
      return 0; // default to Home
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: getIndex(),
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/medications');
              break;
            case 2:
              context.go('/measurements');
              break;
            case 3:
              context.go('/appointments');
              break;
            case 4:
              context.push(
                  '/settings'); // Or a 'More' menu page, for now push settings
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.medication), label: 'Meds'),
          BottomNavigationBarItem(
              icon: Icon(Icons.monitor_weight), label: 'Vitals'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Appts'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'More'),
        ],
      ),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      // Async wait for the care recipient to resolve if it's loading
      final careRecipientAsync = ref.read(primaryCareRecipientProvider);

      // If we don't have a care recipient and are not on onboarding, redirect to onboarding
      final isGoingToOnboarding = state.uri.path == '/onboarding';

      // If it's loaded and empty, force onboarding
      if (careRecipientAsync.hasValue && careRecipientAsync.value == null) {
        if (!isGoingToOnboarding) return '/onboarding';
      }

      // If it's loaded and present, prevent going to onboarding
      if (careRecipientAsync.hasValue && careRecipientAsync.value != null) {
        if (isGoingToOnboarding) return '/';
      }

      return null; // no redirect
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/emergency',
        builder: (context, state) => const EmergencyScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/medications',
            builder: (context, state) => const MedicationsScreen(),
          ),
          GoRoute(
            path: '/measurements',
            builder: (context, state) => const MeasurementsScreen(),
          ),
          GoRoute(
            path: '/appointments',
            builder: (context, state) => const AppointmentsScreen(),
          ),
          // Additional main screens that fit within the shell
          GoRoute(
            path: '/care-recipient',
            builder: (context, state) => const CareRecipientScreen(),
          ),
          GoRoute(
            path: '/care-notes',
            builder: (context, state) => const CareNotesScreen(),
          ),
          GoRoute(
            path: '/care-brief',
            builder: (context, state) => const CareBriefScreen(),
          ),
          GoRoute(
            path: '/handover',
            builder: (context, state) => const HandoverScreen(),
          ),
          GoRoute(
            path: '/family-contacts',
            builder: (context, state) => const FamilyContactsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
        ],
      ),
      // Screens without bottom navigation (full screen forms)
      GoRoute(
        path: '/care-recipient/edit',
        builder: (context, state) => const EditCareRecipientScreen(),
      ),
      GoRoute(
        path: '/medications/add',
        builder: (context, state) {
          final extra = state.extra;
          String recipientId;
          String? scheduleId;
          if (extra is String) {
            recipientId = extra;
          } else if (extra is Map) {
            recipientId = extra['recipientId'] as String;
            scheduleId = extra['scheduleId'] as String?;
          } else {
            recipientId = '';
          }
          return AddMedicationScreen(
            recipientId: recipientId,
            scheduleId: scheduleId,
          );
        },
      ),
      GoRoute(
        path: '/medications/:id',
        builder: (context, state) => MedicationDetailScreen(
          medicationId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/measurements/add',
        builder: (context, state) {
          final recipientId =
              state.extra is String ? state.extra as String : '';
          return AddMeasurementScreen(recipientId: recipientId);
        },
      ),
      GoRoute(
        path: '/appointments/add',
        builder: (context, state) {
          final extra = state.extra;
          String recipientId = '';
          String? appointmentId;
          if (extra is String) {
            recipientId = extra;
          } else if (extra is Map) {
            recipientId = extra['recipientId'] as String;
            appointmentId = extra['appointmentId'] as String?;
          }
          return AddAppointmentScreen(
            recipientId: recipientId,
            appointmentId: appointmentId,
          );
        },
      ),
      GoRoute(
        path: '/care-notes/add',
        builder: (context, state) {
          final recipientId =
              state.extra is String ? state.extra as String : '';
          return AddCareNoteScreen(recipientId: recipientId);
        },
      ),
      GoRoute(
        path: '/family-contacts/add',
        builder: (context, state) {
          final extra = state.extra;
          String recipientId;
          String? contactId;
          if (extra is String) {
            recipientId = extra;
          } else if (extra is Map) {
            recipientId = extra['recipientId'] as String;
            contactId = extra['contactId'] as String?;
          } else {
            recipientId = '';
          }
          return AddFamilyContactScreen(
            recipientId: recipientId,
            contactId: contactId,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
  );
});
