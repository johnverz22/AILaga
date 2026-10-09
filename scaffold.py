import os

base_dir = "/Users/john/Develop/ailaga"

def write_file(path, content):
    full_path = os.path.join(base_dir, path)
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, 'w') as f:
        f.write(content.strip() + '\n')

files = {
    'pubspec.yaml': """
name: ailaga
description: "AILaga — AI-Powered Family Caregiving Companion"
publish_to: 'none'
version: 0.1.0+1

environment:
  sdk: ^3.13.4

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  go_router: ^14.8.1
  drift: ^2.23.1
  sqlite3_flutter_libs: ^0.5.28
  path_provider: ^2.1.5
  path: ^1.9.1
  uuid: ^4.5.1
  intl: ^0.20.2
  flutter_local_notifications: ^18.0.1
  flutter_secure_storage: ^9.2.4
  pdf: ^3.11.2
  share_plus: ^10.1.4
  url_launcher: ^6.3.1
  sensors_plus: ^6.1.1
  permission_handler: ^11.3.1
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  printing: ^5.13.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  drift_dev: ^2.23.1
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.9.4
  riverpod_generator: ^2.6.3
  mocktail: ^1.0.4

flutter:
  uses-material-design: true
""",
    'lib/main.dart': """
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: initialize database
  runApp(
    const ProviderScope(
      child: AilagaApp(),
    ),
  );
}
""",
    'lib/app/app.dart': """
import 'package:flutter/material.dart';
import 'router.dart';
import 'theme.dart';

class AilagaApp extends StatelessWidget {
  const AilagaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AILaga',
      theme: appTheme,
      routerConfig: appRouter,
    );
  }
}
""",
    'lib/app/router.dart': """
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../features/home/presentation/home_screen.dart';
// TODO: import other screens

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    // TODO: implement other routes
  ],
);
""",
    'lib/app/theme.dart': """
import 'package:flutter/material.dart';

final appTheme = ThemeData(
  primaryColor: const Color(0xFF00695C), // Deep teal/green
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00695C)),
  useMaterial3: true,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(48, 48), // Large touch targets
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontSize: 16),
    titleLarge: TextStyle(fontSize: 20),
  ),
  cardTheme: const CardTheme(
    elevation: 2,
    margin: EdgeInsets.all(8),
  ),
);
""",
    'lib/core/database/app_database.dart': """
import 'package:drift/drift.dart';

part 'app_database.g.dart';

@DataClassName('CareRecipient')
class CareRecipients extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text().withLength(min: 1, max: 200)();
  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  TextColumn get allergies => text().nullable()();
  TextColumn get importantNotes => text().nullable()();
  TextColumn get emergencyInfo => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('FamilyContact')
class FamilyContacts extends Table {
  TextColumn get id => text()();
  TextColumn get careRecipientId => text().references(CareRecipients, #id)();
  TextColumn get displayName => text().withLength(min: 1, max: 200)();
  TextColumn get relationship => text().nullable()();
  TextColumn get phoneNumber => text().withLength(min: 1, max: 30)();
  BoolColumn get isEmergencyContact => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MedicationSchedule')
class MedicationSchedules extends Table {
  TextColumn get id => text()();
  TextColumn get careRecipientId => text().references(CareRecipients, #id)();
  TextColumn get medicationName => text().withLength(min: 1, max: 300)();
  TextColumn get prescribedInstructions => text().nullable()();
  TextColumn get scheduleTimes => text()(); // JSON array of time strings
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MedicationOccurrence')
class MedicationOccurrences extends Table {
  TextColumn get id => text()();
  TextColumn get medicationScheduleId => text().references(MedicationSchedules, #id)();
  DateTimeColumn get scheduledAt => dateTime()();
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending, taken, skipped, not_confirmed
  DateTimeColumn get statusUpdatedAt => dateTime().nullable()();
  TextColumn get statusNote => text().nullable()();
  TextColumn get recordedByLabel => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MeasurementLog')
class MeasurementLogs extends Table {
  TextColumn get id => text()();
  TextColumn get careRecipientId => text().references(CareRecipients, #id)();
  TextColumn get measurementType => text()(); // blood_pressure, pulse, temperature, weight, blood_glucose
  RealColumn get value1 => real()(); // primary value (or systolic for BP)
  RealColumn get value2 => real().nullable()(); // diastolic for BP, null for others
  TextColumn get unit => text()();
  DateTimeColumn get measuredAt => dateTime()();
  DateTimeColumn get recordedAt => dateTime()();
  TextColumn get sourceType => text().withDefault(const Constant('manual'))(); // manual, health_connect, other
  TextColumn get sourceLabel => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Appointment')
class Appointments extends Table {
  TextColumn get id => text()();
  TextColumn get careRecipientId => text().references(CareRecipients, #id)();
  TextColumn get providerOrFacility => text().nullable()();
  TextColumn get purpose => text().nullable()();
  DateTimeColumn get scheduledAt => dateTime()();
  TextColumn get notes => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('scheduled'))(); // scheduled, completed, cancelled
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CareNote')
class CareNotes extends Table {
  TextColumn get id => text()();
  TextColumn get careRecipientId => text().references(CareRecipients, #id)();
  DateTimeColumn get observedAt => dateTime()();
  DateTimeColumn get recordedAt => dateTime()();
  TextColumn get originalText => text().withLength(min: 1)();
  TextColumn get structuredSummary => text().nullable()();
  TextColumn get sourceType => text().withDefault(const Constant('manual'))(); // manual, ai_assisted
  TextColumn get reviewStatus => text().withDefault(const Constant('unreviewed'))(); // unreviewed, confirmed
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('EmergencyEvent')
class EmergencyEvents extends Table {
  TextColumn get id => text()();
  TextColumn get careRecipientId => text().references(CareRecipients, #id)();
  DateTimeColumn get triggeredAt => dateTime()();
  TextColumn get triggerType => text()(); // button, gesture
  DateTimeColumn get cancelledAt => dateTime().nullable()();
  TextColumn get selectedAction => text().nullable()();
  TextColumn get actionStatus => text().withDefault(const Constant('triggered'))(); // triggered, cancelled, action_opened, unknown
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AppSetting')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [
  CareRecipients,
  FamilyContacts,
  MedicationSchedules,
  MedicationOccurrences,
  MeasurementLogs,
  Appointments,
  CareNotes,
  EmergencyEvents,
  AppSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());
  
  static final AppDatabase _instance = AppDatabase._();
  factory AppDatabase() => _instance;

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

// TODO: implement _openConnection
QueryExecutor _openConnection() {
  throw UnimplementedError();
}
""",
    'lib/core/database/migrations.dart': """
// TODO: implement migrations
""",
    'lib/core/database/database_provider.dart': """
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});
""",
    'lib/core/errors/app_exception.dart': """
class AppException implements Exception {
  final String message;
  AppException(this.message);
}
""",
    'lib/core/errors/error_handler.dart': """
class ErrorHandler {
  // TODO: implement
}
""",
    'lib/core/security/secure_storage_service.dart': """
abstract class SecureStorageService {
  // TODO: implement
}
class SecureStorageServiceImpl implements SecureStorageService {}
""",
    'lib/core/notifications/notification_service.dart': """
abstract class NotificationService {
  // TODO: implement
}
class NotificationServiceImpl implements NotificationService {}
""",
    'lib/core/notifications/notification_provider.dart': """
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationServiceImpl();
});
""",
    'lib/core/utilities/date_utils.dart': """
class AppDateUtils {
  // TODO: implement
}
""",
    'lib/core/utilities/validators.dart': """
class Validators {
  // TODO: implement
}
""",
    'lib/core/utilities/uuid_generator.dart': """
import 'package:uuid/uuid.dart';

class UuidGenerator {
  static const _uuid = Uuid();
  static String generate() => _uuid.v4();
}
""",
    # Care Recipient
    'lib/features/care_recipient/domain/care_recipient_entity.dart': """
class CareRecipientEntity {
  // TODO: implement
}
""",
    'lib/features/care_recipient/domain/care_recipient_repository.dart': """
abstract class CareRecipientRepository {
  // TODO: implement
}
""",
    'lib/features/care_recipient/data/care_recipient_repository_impl.dart': """
import '../domain/care_recipient_repository.dart';
class CareRecipientRepositoryImpl implements CareRecipientRepository {
  // TODO: implement
}
""",
    'lib/features/care_recipient/data/care_recipient_providers.dart': """
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'care_recipient_repository_impl.dart';

final careRecipientRepositoryProvider = Provider((ref) => CareRecipientRepositoryImpl());
""",
    'lib/features/care_recipient/presentation/care_recipient_screen.dart': """
import 'package:flutter/material.dart';
class CareRecipientScreen extends StatelessWidget {
  const CareRecipientScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Care Recipient')));
}
""",
    'lib/features/care_recipient/presentation/edit_care_recipient_screen.dart': """
import 'package:flutter/material.dart';
class EditCareRecipientScreen extends StatelessWidget {
  const EditCareRecipientScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}
""",
    'lib/features/care_recipient/presentation/widgets/care_recipient_card.dart': """
import 'package:flutter/material.dart';
class CareRecipientCard extends StatelessWidget {
  const CareRecipientCard({super.key});
  @override
  Widget build(BuildContext context) => const Card();
}
""",
    # Medications
    'lib/features/medications/domain/medication_entity.dart': """
class MedicationScheduleEntity {}
class MedicationOccurrenceEntity {}
""",
    'lib/features/medications/domain/medication_repository.dart': """
abstract class MedicationRepository {}
""",
    'lib/features/medications/domain/medication_status.dart': """
enum MedicationStatus { pending, taken, skipped, notConfirmed }
""",
    'lib/features/medications/data/medication_repository_impl.dart': """
import '../domain/medication_repository.dart';
class MedicationRepositoryImpl implements MedicationRepository {}
""",
    'lib/features/medications/data/medication_providers.dart': """
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'medication_repository_impl.dart';
final medicationRepositoryProvider = Provider((ref) => MedicationRepositoryImpl());
""",
    'lib/features/medications/presentation/medications_screen.dart': """
import 'package:flutter/material.dart';
class MedicationsScreen extends StatelessWidget {
  const MedicationsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}
""",
    'lib/features/medications/presentation/add_medication_screen.dart': """
import 'package:flutter/material.dart';
class AddMedicationScreen extends StatelessWidget {
  const AddMedicationScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}
""",
    'lib/features/medications/presentation/medication_detail_screen.dart': """
import 'package:flutter/material.dart';
class MedicationDetailScreen extends StatelessWidget {
  const MedicationDetailScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}
""",
    'lib/features/medications/presentation/widgets/medication_card.dart': """
import 'package:flutter/material.dart';
class MedicationCard extends StatelessWidget {
  const MedicationCard({super.key});
  @override
  Widget build(BuildContext context) => const Card();
}
""",
    'lib/features/medications/presentation/widgets/occurrence_tile.dart': """
import 'package:flutter/material.dart';
class OccurrenceTile extends StatelessWidget {
  const OccurrenceTile({super.key});
  @override
  Widget build(BuildContext context) => const ListTile();
}
""",
    # Measurements
    'lib/features/measurements/domain/measurement_entity.dart': """
class MeasurementEntity {}
""",
    'lib/features/measurements/domain/measurement_type.dart': """
enum MeasurementType { bloodPressure, pulse, temperature, weight, bloodGlucose }
""",
    'lib/features/measurements/domain/measurement_repository.dart': """
abstract class MeasurementRepository {}
""",
    'lib/features/measurements/data/measurement_repository_impl.dart': """
import '../domain/measurement_repository.dart';
class MeasurementRepositoryImpl implements MeasurementRepository {}
""",
    'lib/features/measurements/data/measurement_providers.dart': """
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'measurement_repository_impl.dart';
final measurementRepositoryProvider = Provider((ref) => MeasurementRepositoryImpl());
""",
    'lib/features/measurements/presentation/measurements_screen.dart': """
import 'package:flutter/material.dart';
class MeasurementsScreen extends StatelessWidget {
  const MeasurementsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}
""",
    'lib/features/measurements/presentation/add_measurement_screen.dart': """
import 'package:flutter/material.dart';
class AddMeasurementScreen extends StatelessWidget {
  const AddMeasurementScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}
""",
    'lib/features/measurements/presentation/widgets/measurement_card.dart': """
import 'package:flutter/material.dart';
class MeasurementCard extends StatelessWidget {
  const MeasurementCard({super.key});
  @override
  Widget build(BuildContext context) => const Card();
}
""",
    # Appointments
    'lib/features/appointments/domain/appointment_entity.dart': """
class AppointmentEntity {}
""",
    'lib/features/appointments/domain/appointment_repository.dart': """
abstract class AppointmentRepository {}
""",
    'lib/features/appointments/data/appointment_repository_impl.dart': """
import '../domain/appointment_repository.dart';
class AppointmentRepositoryImpl implements AppointmentRepository {}
""",
    'lib/features/appointments/data/appointment_providers.dart': """
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'appointment_repository_impl.dart';
final appointmentRepositoryProvider = Provider((ref) => AppointmentRepositoryImpl());
""",
    'lib/features/appointments/presentation/appointments_screen.dart': """
import 'package:flutter/material.dart';
class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}
""",
    'lib/features/appointments/presentation/add_appointment_screen.dart': """
import 'package:flutter/material.dart';
class AddAppointmentScreen extends StatelessWidget {
  const AddAppointmentScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}
""",
    'lib/features/appointments/presentation/widgets/appointment_card.dart': """
import 'package:flutter/material.dart';
class AppointmentCard extends StatelessWidget {
  const AppointmentCard({super.key});
  @override
  Widget build(BuildContext context) => const Card();
}
""",
    # Care Notes
    'lib/features/care_notes/domain/care_note_entity.dart': """
class CareNoteEntity {}
""",
    'lib/features/care_notes/domain/care_note_repository.dart': """
abstract class CareNoteRepository {}
""",
    'lib/features/care_notes/data/care_note_repository_impl.dart': """
import '../domain/care_note_repository.dart';
class CareNoteRepositoryImpl implements CareNoteRepository {}
""",
    'lib/features/care_notes/data/care_note_providers.dart': """
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'care_note_repository_impl.dart';
final careNoteRepositoryProvider = Provider((ref) => CareNoteRepositoryImpl());
""",
    'lib/features/care_notes/presentation/care_notes_screen.dart': """
import 'package:flutter/material.dart';
class CareNotesScreen extends StatelessWidget {
  const CareNotesScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}
""",
    'lib/features/care_notes/presentation/add_care_note_screen.dart': """
import 'package:flutter/material.dart';
class AddCareNoteScreen extends StatelessWidget {
  const AddCareNoteScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}
""",
    'lib/features/care_notes/presentation/widgets/care_note_card.dart': """
import 'package:flutter/material.dart';
class CareNoteCard extends StatelessWidget {
  const CareNoteCard({super.key});
  @override
  Widget build(BuildContext context) => const Card();
}
""",
    # Family Contacts
    'lib/features/family_contacts/domain/family_contact_entity.dart': """
class FamilyContactEntity {}
""",
    'lib/features/family_contacts/domain/family_contact_repository.dart': """
abstract class FamilyContactRepository {}
""",
    'lib/features/family_contacts/data/family_contact_repository_impl.dart': """
import '../domain/family_contact_repository.dart';
class FamilyContactRepositoryImpl implements FamilyContactRepository {}
""",
    'lib/features/family_contacts/data/family_contact_providers.dart': """
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'family_contact_repository_impl.dart';
final familyContactRepositoryProvider = Provider((ref) => FamilyContactRepositoryImpl());
""",
    'lib/features/family_contacts/presentation/family_contacts_screen.dart': """
import 'package:flutter/material.dart';
class FamilyContactsScreen extends StatelessWidget {
  const FamilyContactsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}
""",
    'lib/features/family_contacts/presentation/add_family_contact_screen.dart': """
import 'package:flutter/material.dart';
class AddFamilyContactScreen extends StatelessWidget {
  const AddFamilyContactScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}
""",
    'lib/features/family_contacts/presentation/widgets/family_contact_card.dart': """
import 'package:flutter/material.dart';
class FamilyContactCard extends StatelessWidget {
  const FamilyContactCard({super.key});
  @override
  Widget build(BuildContext context) => const Card();
}
""",
    # Emergency
    'lib/features/emergency/domain/emergency_entity.dart': """
class EmergencyEventEntity {}
""",
    'lib/features/emergency/domain/emergency_repository.dart': """
abstract class EmergencyRepository {}
""",
    'lib/features/emergency/domain/emergency_service.dart': """
abstract class EmergencyService {}
""",
    'lib/features/emergency/data/emergency_repository_impl.dart': """
import '../domain/emergency_repository.dart';
class EmergencyRepositoryImpl implements EmergencyRepository {}
""",
    'lib/features/emergency/data/emergency_providers.dart': """
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'emergency_repository_impl.dart';
final emergencyRepositoryProvider = Provider((ref) => EmergencyRepositoryImpl());
""",
    'lib/features/emergency/presentation/emergency_screen.dart': """
import 'package:flutter/material.dart';
class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}
""",
    'lib/features/emergency/presentation/widgets/sos_button.dart': """
import 'package:flutter/material.dart';
class SosButton extends StatelessWidget {
  const SosButton({super.key});
  @override
  Widget build(BuildContext context) => ElevatedButton(
    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
    onPressed: () {},
    child: const Text('SOS', style: TextStyle(color: Colors.white)),
  );
}
""",
    'lib/features/emergency/presentation/widgets/countdown_overlay.dart': """
import 'package:flutter/material.dart';
class CountdownOverlay extends StatelessWidget {
  const CountdownOverlay({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox();
}
""",
    # Care Brief
    'lib/features/care_brief/domain/care_brief_entity.dart': """
class CareBriefEntity {}
""",
    'lib/features/care_brief/domain/care_brief_service.dart': """
abstract class CareBriefService {}
""",
    'lib/features/care_brief/data/deterministic_care_brief_service.dart': """
import '../domain/care_brief_service.dart';
class DeterministicCareBriefService implements CareBriefService {}
""",
    'lib/features/care_brief/data/care_brief_providers.dart': """
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'deterministic_care_brief_service.dart';
final careBriefServiceProvider = Provider((ref) => DeterministicCareBriefService());
""",
    'lib/features/care_brief/presentation/care_brief_screen.dart': """
import 'package:flutter/material.dart';
class CareBriefScreen extends StatelessWidget {
  const CareBriefScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}
""",
    'lib/features/care_brief/presentation/widgets/brief_section_card.dart': """
import 'package:flutter/material.dart';
class BriefSectionCard extends StatelessWidget {
  const BriefSectionCard({super.key});
  @override
  Widget build(BuildContext context) => const Card();
}
""",
    # Handover
    'lib/features/handover/domain/handover_entity.dart': """
class HandoverEntity {}
""",
    'lib/features/handover/domain/handover_service.dart': """
abstract class HandoverService {}
""",
    'lib/features/handover/data/deterministic_handover_service.dart': """
import '../domain/handover_service.dart';
class DeterministicHandoverService implements HandoverService {}
""",
    'lib/features/handover/data/handover_providers.dart': """
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'deterministic_handover_service.dart';
final handoverServiceProvider = Provider((ref) => DeterministicHandoverService());
""",
    'lib/features/handover/presentation/handover_screen.dart': """
import 'package:flutter/material.dart';
class HandoverScreen extends StatelessWidget {
  const HandoverScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}
""",
    # Reports
    'lib/features/reports/domain/report_entity.dart': """
class ReportEntity {}
""",
    'lib/features/reports/domain/report_service.dart': """
abstract class ReportService {}
""",
    'lib/features/reports/data/pdf_report_service.dart': """
import '../domain/report_service.dart';
class PdfReportService implements ReportService {}
""",
    'lib/features/reports/data/report_providers.dart': """
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pdf_report_service.dart';
final reportServiceProvider = Provider((ref) => PdfReportService());
""",
    'lib/features/reports/presentation/reports_screen.dart': """
import 'package:flutter/material.dart';
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}
""",
    # Settings
    'lib/features/settings/presentation/settings_screen.dart': """
import 'package:flutter/material.dart';
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}
""",
    # Onboarding
    'lib/features/onboarding/presentation/onboarding_screen.dart': """
import 'package:flutter/material.dart';
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}
""",
    # Home Dashboard
    'lib/features/home/presentation/home_screen.dart': """
import 'package:flutter/material.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Home Dashboard')));
}
""",
    'lib/features/home/presentation/widgets/dashboard_medication_section.dart': """
import 'package:flutter/material.dart';
class DashboardMedicationSection extends StatelessWidget {
  const DashboardMedicationSection({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox();
}
""",
    'lib/features/home/presentation/widgets/dashboard_appointment_section.dart': """
import 'package:flutter/material.dart';
class DashboardAppointmentSection extends StatelessWidget {
  const DashboardAppointmentSection({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox();
}
""",
    'lib/features/home/presentation/widgets/dashboard_measurement_section.dart': """
import 'package:flutter/material.dart';
class DashboardMeasurementSection extends StatelessWidget {
  const DashboardMeasurementSection({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox();
}
""",
    'lib/features/home/presentation/widgets/dashboard_tasks_section.dart': """
import 'package:flutter/material.dart';
class DashboardTasksSection extends StatelessWidget {
  const DashboardTasksSection({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox();
}
""",
    # Services
    'lib/services/ai/care_summary_service.dart': """
abstract class CareSummaryService {}
""",
    'lib/services/ai/care_summary_models.dart': """
class CareSummaryRequest {}
class CareSummaryResponse {}
""",
    'lib/services/ai/deterministic_care_summary_service.dart': """
import 'care_summary_service.dart';
class DeterministicCareSummaryService implements CareSummaryService {}
""",
    'lib/services/health_connect/health_connect_service.dart': """
abstract class HealthConnectService {}
""",
    'lib/services/pdf/pdf_generator.dart': """
class PdfGenerator {}
"""
}

for path, content in files.items():
    write_file(path, content)

print("Scaffold complete.")
