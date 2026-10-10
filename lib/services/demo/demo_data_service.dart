import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utilities/uuid_generator.dart';
import '../../features/appointments/data/appointment_providers.dart';
import '../../features/appointments/domain/appointment_entity.dart';
import '../../features/appointments/domain/appointment_repository.dart';
import '../../features/care_notes/data/care_note_providers.dart';
import '../../features/care_notes/domain/care_note_entity.dart';
import '../../features/care_notes/domain/care_note_repository.dart';
import '../../features/care_recipient/data/care_recipient_providers.dart';
import '../../features/care_recipient/domain/care_recipient_entity.dart';
import '../../features/care_recipient/domain/care_recipient_repository.dart';
import '../../features/family_contacts/data/family_contact_providers.dart';
import '../../features/family_contacts/domain/family_contact_entity.dart';
import '../../features/family_contacts/domain/family_contact_repository.dart';
import '../../features/measurements/data/measurement_providers.dart';
import '../../features/measurements/domain/measurement_entity.dart';
import '../../features/measurements/domain/measurement_repository.dart';
import '../../features/measurements/domain/measurement_type.dart';
import '../../features/medications/data/medication_providers.dart';
import '../../features/medications/domain/medication_entity.dart';
import '../../features/medications/domain/medication_status.dart';
import '../../features/medications/domain/medication_repository.dart';

final demoDataServiceProvider = Provider<DemoDataService>((ref) {
  return DemoDataService(
    recipients: ref.watch(careRecipientRepositoryProvider),
    contacts: ref.watch(familyContactRepositoryProvider),
    medications: ref.watch(medicationRepositoryProvider),
    measurements: ref.watch(measurementRepositoryProvider),
    appointments: ref.watch(appointmentRepositoryProvider),
    notes: ref.watch(careNoteRepositoryProvider),
  );
});

/// Seeds the B22 demo dataset — a complete caregiving story that makes
/// the dashboard, care brief, SOS screen, and reports populated on first
/// launch. Writes through the real repositories so every record carries
/// proper provenance (manual source type).
///
/// Callers are responsible for deciding when this is appropriate — the
/// service itself does not wipe existing data.
class DemoDataService {
  final CareRecipientRepository _recipients;
  final FamilyContactRepository _contacts;
  final MedicationRepository _medications;
  final MeasurementRepository _measurements;
  final AppointmentRepository _appointments;
  final CareNoteRepository _notes;

  DemoDataService({
    required CareRecipientRepository recipients,
    required FamilyContactRepository contacts,
    required MedicationRepository medications,
    required MeasurementRepository measurements,
    required AppointmentRepository appointments,
    required CareNoteRepository notes,
  })  : _recipients = recipients,
        _contacts = contacts,
        _medications = medications,
        _measurements = measurements,
        _appointments = appointments,
        _notes = notes;

  /// Inserts the demo dataset only when no care recipient exists.
  /// Returns the new recipient id, or null when data was already present.
  Future<String?> seedIfEmpty() async {
    if (await _recipients.getPrimary() != null) return null;
    return _seed();
  }

  /// Inserts the dataset unconditionally — caller must wipe first when
  /// replacing real data.
  Future<String> seed() => _seed();

  Future<String> _seed() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recipientId = UuidGenerator.generate();

    // --- Care recipient: "Lola Maria", B22 persona ---------------------
    await _recipients.create(CareRecipientEntity(
      id: recipientId,
      displayName: 'Lola Maria',
      dateOfBirth: DateTime(1945, 3, 15),
      allergies: 'Penicillin',
      importantNotes: 'Type 2 diabetes. High blood pressure.',
      emergencyInfo: 'Type 2 diabetes. Allergic to penicillin. '
          'Lives with daughter Ana.',
      createdAt: now,
      updatedAt: now,
    ));

    // --- Family contacts ----------------------------------------------
    await _contacts.create(FamilyContactEntity(
      id: UuidGenerator.generate(),
      careRecipientId: recipientId,
      displayName: 'Ana',
      relationship: 'Daughter',
      phoneNumber: '09171234567',
      isEmergencyContact: true,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    ));
    await _contacts.create(FamilyContactEntity(
      id: UuidGenerator.generate(),
      careRecipientId: recipientId,
      displayName: 'Jun',
      relationship: 'Son',
      phoneNumber: '09187654321',
      isEmergencyContact: false,
      sortOrder: 1,
      createdAt: now,
      updatedAt: now,
    ));

    // --- Medications ---------------------------------------------------
    final metforminId = UuidGenerator.generate();
    final amlodipineId = UuidGenerator.generate();
    // Start a week ago so history exists; occurrences generated below.
    final startDate = today.subtract(const Duration(days: 7));
    await _medications.createSchedule(MedicationScheduleEntity(
      id: metforminId,
      careRecipientId: recipientId,
      medicationName: 'Metformin 500mg',
      prescribedInstructions: '1 tablet with food',
      scheduleTimes: jsonEncode(['08:00', '20:00']),
      startDate: startDate,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    ));
    await _medications.createSchedule(MedicationScheduleEntity(
      id: amlodipineId,
      careRecipientId: recipientId,
      medicationName: 'Amlodipine 5mg',
      prescribedInstructions: '1 tablet daily',
      scheduleTimes: jsonEncode(['08:00']),
      startDate: startDate,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    ));

    // Occurrences for the past week + tomorrow so the dashboard shows
    // today's dose cards and the brief has history.
    for (final id in [metforminId, amlodipineId]) {
      await _medications.generateOccurrences(
          id, startDate, today.add(const Duration(days: 1)));
    }
    await _markDoseHistory(recipientId, amlodipineId, today, now);

    // --- Measurements --------------------------------------------------
    Future<void> measure(
            MeasurementType type, double v1, double? v2, DateTime at) =>
        _measurements.create(MeasurementEntity(
          id: UuidGenerator.generate(),
          careRecipientId: recipientId,
          measurementType: type,
          value1: v1,
          value2: v2,
          unit: type.defaultUnit,
          measuredAt: at,
          recordedAt: at,
          sourceType: 'manual',
          createdAt: now,
          updatedAt: now,
        ));

    // A few days of history so the brief and 7-day report aren't sparse.
    await measure(MeasurementType.bloodPressure, 130, 85,
        today.add(const Duration(hours: 8)));
    await measure(MeasurementType.bloodPressure, 128, 82,
        today.subtract(const Duration(days: 1)).add(const Duration(hours: 8)));
    await measure(MeasurementType.temperature, 36.8, null,
        today.subtract(const Duration(days: 1)).add(const Duration(hours: 19)));
    await measure(MeasurementType.bloodGlucose, 110, null,
        today.subtract(const Duration(days: 1)).add(const Duration(hours: 7)));
    await measure(MeasurementType.pulse, 72, null,
        today.add(const Duration(hours: 8)));

    // --- Appointment: Dr. Santos, upcoming ----------------------------
    await _appointments.create(AppointmentEntity(
      id: UuidGenerator.generate(),
      careRecipientId: recipientId,
      providerOrFacility: 'Dr. Santos',
      purpose: 'Annual checkup',
      scheduledAt: today.add(const Duration(days: 2, hours: 10)),
      status: 'scheduled',
      createdAt: now,
      updatedAt: now,
    ));

    // --- Care note -----------------------------------------------------
    await _notes.create(CareNoteEntity(
      id: UuidGenerator.generate(),
      careRecipientId: recipientId,
      observedAt: today.add(const Duration(hours: 13)),
      recordedAt: now,
      originalText: 'Lola complained of mild headache after lunch',
      sourceType: 'manual',
      reviewStatus: 'confirmed',
      createdAt: now,
      updatedAt: now,
    ));

    return recipientId;
  }

  /// Marks a believable week of dose history (B22 mixed statuses):
  /// every past dose taken, the most recent Amlodipine skipped, and
  /// anything still due left pending for the demo to act on.
  Future<void> _markDoseHistory(String recipientId, String amlodipineId,
      DateTime today, DateTime now) async {
    final occurrences = await _medications.getOccurrencesForDateRange(
        recipientId,
        today.subtract(const Duration(days: 7)),
        today.add(const Duration(days: 2)));

    MedicationOccurrenceEntity? lastAmlodipine;
    for (final o in occurrences) {
      // Leave future doses pending — the demo can mark them live.
      if (o.scheduledAt.isAfter(now)) continue;
      await _medications.updateOccurrenceStatus(o.id, MedicationStatus.taken);
      if (o.medicationScheduleId == amlodipineId &&
          (lastAmlodipine == null ||
              o.scheduledAt.isAfter(lastAmlodipine.scheduledAt))) {
        lastAmlodipine = o;
      }
    }
    if (lastAmlodipine != null) {
      await _medications.updateOccurrenceStatus(
          lastAmlodipine.id, MedicationStatus.skipped,
          note: 'Lola felt dizzy, skipped');
    }
  }
}
