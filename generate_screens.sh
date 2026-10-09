#!/bin/bash
mkdir -p lib/features/home/presentation
mkdir -p lib/features/onboarding/presentation
mkdir -p lib/features/care_recipient/presentation
mkdir -p lib/features/medications/presentation
mkdir -p lib/features/measurements/presentation
mkdir -p lib/features/appointments/presentation
mkdir -p lib/features/care_notes/presentation
mkdir -p lib/features/care_brief/presentation
mkdir -p lib/features/handover/presentation
mkdir -p lib/features/emergency/presentation
mkdir -p lib/features/family_contacts/presentation
mkdir -p lib/features/settings/presentation
mkdir -p lib/features/reports/presentation

create_screen() {
  local file=$1
  local class=$2
  cat << INNER_EOF > "$file"
import 'package:flutter/material.dart';

class $class extends StatelessWidget {
  const $class({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('$class')),
      body: const Center(
        child: Text('TODO: Implement'),
      ),
    );
  }
}
INNER_EOF
}

create_screen lib/features/home/presentation/home_screen.dart HomeScreen
create_screen lib/features/onboarding/presentation/onboarding_screen.dart OnboardingScreen
create_screen lib/features/care_recipient/presentation/care_recipient_screen.dart CareRecipientScreen
create_screen lib/features/care_recipient/presentation/edit_care_recipient_screen.dart EditCareRecipientScreen
create_screen lib/features/medications/presentation/medications_screen.dart MedicationsScreen
create_screen lib/features/medications/presentation/add_medication_screen.dart AddMedicationScreen

cat << 'INNER_EOF' > lib/features/medications/presentation/medication_detail_screen.dart
import 'package:flutter/material.dart';

class MedicationDetailScreen extends StatelessWidget {
  final String medicationId;
  const MedicationDetailScreen({super.key, required this.medicationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MedicationDetailScreen')),
      body: Center(
        child: Text('TODO: Implement for \$medicationId'),
      ),
    );
  }
}
INNER_EOF

create_screen lib/features/measurements/presentation/measurements_screen.dart MeasurementsScreen
create_screen lib/features/measurements/presentation/add_measurement_screen.dart AddMeasurementScreen
create_screen lib/features/appointments/presentation/appointments_screen.dart AppointmentsScreen
create_screen lib/features/appointments/presentation/add_appointment_screen.dart AddAppointmentScreen
create_screen lib/features/care_notes/presentation/care_notes_screen.dart CareNotesScreen
create_screen lib/features/care_notes/presentation/add_care_note_screen.dart AddCareNoteScreen
create_screen lib/features/care_brief/presentation/care_brief_screen.dart CareBriefScreen
create_screen lib/features/handover/presentation/handover_screen.dart HandoverScreen
create_screen lib/features/emergency/presentation/emergency_screen.dart EmergencyScreen
create_screen lib/features/family_contacts/presentation/family_contacts_screen.dart FamilyContactsScreen
create_screen lib/features/family_contacts/presentation/add_family_contact_screen.dart AddFamilyContactScreen
create_screen lib/features/settings/presentation/settings_screen.dart SettingsScreen
create_screen lib/features/reports/presentation/reports_screen.dart ReportsScreen

