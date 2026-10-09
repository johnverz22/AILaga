import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
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

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/care-recipient',
      builder: (context, state) => const CareRecipientScreen(),
    ),
    GoRoute(
      path: '/care-recipient/edit',
      builder: (context, state) => const EditCareRecipientScreen(),
    ),
    GoRoute(
      path: '/medications',
      builder: (context, state) => const MedicationsScreen(),
    ),
    GoRoute(
      path: '/medications/add',
      builder: (context, state) => const AddMedicationScreen(),
    ),
    GoRoute(
      path: '/medications/:id',
      builder: (context, state) => MedicationDetailScreen(
        medicationId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/measurements',
      builder: (context, state) => const MeasurementsScreen(),
    ),
    GoRoute(
      path: '/measurements/add',
      builder: (context, state) => const AddMeasurementScreen(),
    ),
    GoRoute(
      path: '/appointments',
      builder: (context, state) => const AppointmentsScreen(),
    ),
    GoRoute(
      path: '/appointments/add',
      builder: (context, state) => const AddAppointmentScreen(),
    ),
    GoRoute(
      path: '/care-notes',
      builder: (context, state) => const CareNotesScreen(),
    ),
    GoRoute(
      path: '/care-notes/add',
      builder: (context, state) => const AddCareNoteScreen(),
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
      path: '/emergency',
      builder: (context, state) => const EmergencyScreen(),
    ),
    GoRoute(
      path: '/family-contacts',
      builder: (context, state) => const FamilyContactsScreen(),
    ),
    GoRoute(
      path: '/family-contacts/add',
      builder: (context, state) => const AddFamilyContactScreen(),
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
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Page Not Found')),
    body: Center(
      child: Text('Route not found: ${state.uri}'),
    ),
  ),
);
