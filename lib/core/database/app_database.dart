import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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
  AppDatabase() : super(_openConnection());
  
  /// For testing — accepts a custom executor
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ailaga.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
