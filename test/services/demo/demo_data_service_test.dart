import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ailaga/core/database/app_database.dart';
import 'package:ailaga/features/appointments/data/appointment_repository_impl.dart';
import 'package:ailaga/features/care_notes/data/care_note_repository_impl.dart';
import 'package:ailaga/features/care_recipient/data/care_recipient_repository_impl.dart';
import 'package:ailaga/features/family_contacts/data/family_contact_repository_impl.dart';
import 'package:ailaga/features/measurements/data/measurement_repository_impl.dart';
import 'package:ailaga/features/medications/data/medication_repository_impl.dart';
import 'package:ailaga/features/medications/domain/medication_status.dart';
import 'package:ailaga/services/demo/demo_data_service.dart';

/// B22 demo seed: one tap fills the app with a coherent caregiving
/// story — recipient, contacts, meds with mixed dose statuses,
/// measurements, an upcoming appointment, and a care note.
void main() {
  late AppDatabase db;
  late DemoDataService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = DemoDataService(
      recipients: CareRecipientRepositoryImpl(db),
      contacts: FamilyContactRepositoryImpl(db),
      medications: MedicationRepositoryImpl(db),
      measurements: MeasurementRepositoryImpl(db),
      appointments: AppointmentRepositoryImpl(db),
      notes: CareNoteRepositoryImpl(db),
    );
  });

  tearDown(() => db.close());

  test('seeds the full B22 dataset through repositories', () async {
    final recipientId = await service.seed();

    final recipient = await CareRecipientRepositoryImpl(db).getById(recipientId);
    expect(recipient!.displayName, 'Lola Maria');
    expect(recipient.dateOfBirth, DateTime(1945, 3, 15));

    final contacts = await FamilyContactRepositoryImpl(db)
        .getByCareRecipient(recipientId);
    expect(contacts.length, 2);
    expect(contacts.where((c) => c.isEmergencyContact).single.displayName,
        'Ana');

    final schedules = await MedicationRepositoryImpl(db)
        .getActiveSchedules(recipientId);
    expect(schedules.length, 2);

    // Dose history: at least one taken, exactly one skipped, and
    // future doses left pending.
    final occurrences = await MedicationRepositoryImpl(db)
        .getOccurrencesForDateRange(
            recipientId,
            DateTime.now().subtract(const Duration(days: 8)),
            DateTime.now().add(const Duration(days: 2)));
    final statuses = occurrences.map((o) => o.status).toSet();
    expect(statuses, containsAll(
        [MedicationStatus.taken, MedicationStatus.skipped]));
    expect(
        occurrences.where((o) => o.status == MedicationStatus.skipped),
        hasLength(1));

    final measurements = await MeasurementRepositoryImpl(db)
        .getByRecipient(recipientId);
    expect(measurements.length, greaterThanOrEqualTo(4));
    expect(
        measurements.map((m) => m.measurementType.databaseValue),
        containsAll(['blood_pressure', 'temperature', 'blood_glucose']));

    final appointments =
        await AppointmentRepositoryImpl(db).getByRecipient(recipientId);
    expect(appointments.single.providerOrFacility, 'Dr. Santos');
    expect(appointments.single.scheduledAt.isAfter(DateTime.now()), isTrue);

    final notes =
        await CareNoteRepositoryImpl(db).getByRecipient(recipientId);
    expect(notes.single.originalText, contains('headache'));
  });

  test('seedIfEmpty is a no-op when a recipient already exists', () async {
    await service.seedIfEmpty();
    final second = await service.seedIfEmpty();
    expect(second, isNull);

    final recipients = await CareRecipientRepositoryImpl(db).getAll();
    expect(recipients, hasLength(1));
  });
}
