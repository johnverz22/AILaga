# AILaga — Developer A: Data Layer, Core Records & Emergency

## Role: "Foundation & Safety Developer"

You own the **data layer**, **core CRUD features**, and the **emergency SOS** system.
Developer B (UI & Summaries) depends on your repository interfaces and database being stable.

---

## Integration Contract with Developer B

### What you provide (Developer B depends on these):
- ✅ Working Drift database with all tables
- ✅ Repository interfaces (abstract classes in `domain/`)
- ✅ Repository implementations (concrete classes in `data/`)
- ✅ Riverpod providers for all repositories
- ✅ Core utility functions (date formatting, validators, UUID)
- ✅ Notification service interface + implementation
- ✅ Emergency event recording and contact dialing

### What Developer B provides (you depend on these):
- Home dashboard screen (uses your providers)
- Care Brief generation (queries your repositories)
- Handover generation (queries your repositories)
- PDF report generation (queries your repositories)
- Onboarding flow (calls your repository to create profile)
- Settings screen

### Integration points (coordinate on these):
- `CareRecipientRepository` — both use it
- `MedicationRepository` — you build it, B displays on dashboard
- `MeasurementRepository` — you build it, B uses in briefs/reports
- Provider naming conventions — use consistent pattern

---

## Task List (Priority Order)

### Phase 1: Database & Core Infrastructure (Hours 0–3)

#### Task A1: Drift Database Setup
**File:** `lib/core/database/app_database.dart`
**Status:** Scaffold exists, needs code generation and verification

- [ ] Run `dart run build_runner build` to generate `app_database.g.dart`
- [ ] Verify all 9 tables compile and generate correctly
- [ ] Test database creation on a fresh start
- [ ] Verify foreign key enforcement works (`PRAGMA foreign_keys = ON`)
- [ ] Add indexes for common lookups:
  - `medication_occurrences.scheduled_at`
  - `measurement_logs.measured_at`
  - `appointments.scheduled_at`
  - `care_notes.observed_at`
  - `medication_occurrences.medication_schedule_id`

**Acceptance:** Database opens, all tables exist, foreign keys enforced.

#### Task A2: Core Utilities
**Files:**
- `lib/core/utilities/date_utils.dart`
- `lib/core/utilities/validators.dart`
- `lib/core/utilities/uuid_generator.dart`
- `lib/core/errors/app_exception.dart`

- [ ] Implement date formatting helpers (UTC ↔ local, display formats)
- [ ] Implement `formatRelativeTime` (e.g., "2 hours ago")
- [ ] Implement input validators:
  - Phone number (flexible, not country-locked)
  - Measurement ranges (BP: 50-300, temp: 30-45°C, pulse: 20-300, etc.)
  - Required field validation
  - Date range validation
- [ ] UUID v4 generation wrapper
- [ ] Define exception hierarchy: `AppException`, `DatabaseException`, `ValidationException`

**Acceptance:** All utility functions have unit tests, validators reject out-of-range values.

#### Task A3: Database Provider
**File:** `lib/core/database/database_provider.dart`

- [ ] Create a Riverpod provider that lazily initializes the database
- [ ] Ensure single instance across the app
- [ ] Handle database path resolution via `path_provider`

**Acceptance:** Provider resolves correctly, database initializes on first access.

---

### Phase 2: Care Recipient & Family Contacts (Hours 3–5)

#### Task A4: Care Recipient Repository
**Files:**
- `lib/features/care_recipient/domain/care_recipient_entity.dart`
- `lib/features/care_recipient/domain/care_recipient_repository.dart`
- `lib/features/care_recipient/data/care_recipient_repository_impl.dart`
- `lib/features/care_recipient/data/care_recipient_providers.dart`

**Repository methods:**
```dart
abstract class CareRecipientRepository {
  Future<CareRecipientEntity?> getById(String id);
  Future<CareRecipientEntity?> getPrimary(); // first/only recipient
  Future<List<CareRecipientEntity>> getAll();
  Future<void> create(CareRecipientEntity entity);
  Future<void> update(CareRecipientEntity entity);
  Future<void> delete(String id); // with confirmation at UI layer
  Stream<CareRecipientEntity?> watchPrimary();
}
```

- [ ] Implement entity with all fields from schema
- [ ] Implement Drift-backed repository
- [ ] Create Riverpod providers: `careRecipientRepositoryProvider`, `primaryCareRecipientProvider`
- [ ] Handle first-time case (no recipient exists)

**Acceptance:** Can create, read, update a care recipient. Data persists across app restart.

#### Task A5: Care Recipient Screens
**Files:**
- `lib/features/care_recipient/presentation/care_recipient_screen.dart`
- `lib/features/care_recipient/presentation/edit_care_recipient_screen.dart`
- `lib/features/care_recipient/presentation/widgets/care_recipient_card.dart`

- [ ] Profile display screen with all fields
- [ ] Edit form with validation (display name required)
- [ ] Allergies and important notes as multiline text
- [ ] Emergency info section
- [ ] Link to family contacts from profile
- [ ] Delete profile with confirmation dialog

**Acceptance:** Full CRUD on care recipient through UI. Form validation works.

#### Task A6: Family Contact Repository
**Files:**
- `lib/features/family_contacts/domain/family_contact_entity.dart`
- `lib/features/family_contacts/domain/family_contact_repository.dart`
- `lib/features/family_contacts/data/family_contact_repository_impl.dart`
- `lib/features/family_contacts/data/family_contact_providers.dart`

**Repository methods:**
```dart
abstract class FamilyContactRepository {
  Future<List<FamilyContactEntity>> getByCareRecipient(String recipientId);
  Future<List<FamilyContactEntity>> getEmergencyContacts(String recipientId);
  Future<void> create(FamilyContactEntity entity);
  Future<void> update(FamilyContactEntity entity);
  Future<void> delete(String id);
  Future<void> reorder(List<String> orderedIds);
  Stream<List<FamilyContactEntity>> watchByCareRecipient(String recipientId);
}
```

- [ ] Implement entity with all fields
- [ ] Implement Drift-backed repository
- [ ] Support reordering (update sortOrder)
- [ ] Create providers

**Acceptance:** Can add, edit, delete, reorder family contacts. Emergency contacts filterable.

#### Task A7: Family Contact Screens
**Files:**
- `lib/features/family_contacts/presentation/family_contacts_screen.dart`
- `lib/features/family_contacts/presentation/add_family_contact_screen.dart`
- `lib/features/family_contacts/presentation/widgets/family_contact_card.dart`

- [ ] Contact list with reorderable tiles
- [ ] Add/edit form with phone number validation
- [ ] Emergency contact toggle
- [ ] Call button → opens system dialer via `url_launcher`
- [ ] SMS button → opens SMS composer via `url_launcher`
- [ ] Delete with confirmation

**Acceptance:** Full CRUD, call/SMS open system apps, emergency contacts marked clearly.

---

### Phase 3: Medications (Hours 5–8)

#### Task A8: Medication Repository
**Files:**
- `lib/features/medications/domain/medication_entity.dart`
- `lib/features/medications/domain/medication_status.dart`
- `lib/features/medications/domain/medication_repository.dart`
- `lib/features/medications/data/medication_repository_impl.dart`
- `lib/features/medications/data/medication_providers.dart`

**Repository methods:**
```dart
abstract class MedicationRepository {
  // Schedules
  Future<List<MedicationScheduleEntity>> getActiveSchedules(String recipientId);
  Future<List<MedicationScheduleEntity>> getAllSchedules(String recipientId);
  Future<MedicationScheduleEntity?> getScheduleById(String id);
  Future<void> createSchedule(MedicationScheduleEntity entity);
  Future<void> updateSchedule(MedicationScheduleEntity entity);
  Future<void> deactivateSchedule(String id); // soft deactivate
  Stream<List<MedicationScheduleEntity>> watchActiveSchedules(String recipientId);

  // Occurrences
  Future<List<MedicationOccurrenceEntity>> getOccurrencesForDate(String scheduleId, DateTime date);
  Future<List<MedicationOccurrenceEntity>> getOccurrencesForDateRange(String recipientId, DateTime start, DateTime end);
  Future<List<MedicationOccurrenceEntity>> getPendingOccurrences(String recipientId);
  Future<void> generateOccurrences(String scheduleId, DateTime fromDate, DateTime toDate); // idempotent!
  Future<void> updateOccurrenceStatus(String occurrenceId, MedicationStatus status, {String? note});
  Stream<List<MedicationOccurrenceEntity>> watchTodayOccurrences(String recipientId);
}
```

**Critical rules:**
- [ ] `generateOccurrences` must be IDEMPOTENT — check for existing before inserting
- [ ] Use unique constraint on (scheduleId, scheduledAt) to prevent duplicates
- [ ] `deactivateSchedule` sets `isActive = false`, does NOT delete history
- [ ] `updateSchedule` does NOT rewrite past occurrences
- [ ] Schedule times stored as JSON array of "HH:mm" strings

**Acceptance:** Idempotent occurrence generation verified. Status updates persist. History preserved on deactivation.

#### Task A9: Medication Screens
**Files:**
- `lib/features/medications/presentation/medications_screen.dart`
- `lib/features/medications/presentation/add_medication_screen.dart`
- `lib/features/medications/presentation/medication_detail_screen.dart`
- `lib/features/medications/presentation/widgets/medication_card.dart`
- `lib/features/medications/presentation/widgets/occurrence_tile.dart`

- [ ] Medication list screen showing active schedules
- [ ] Add/edit form: name (required), instructions, schedule times (multi-time picker), start date, end date, notes
- [ ] Detail screen with occurrence history
- [ ] Occurrence tile with status actions: Mark Taken, Mark Skipped, Mark Not Confirmed
- [ ] Visual distinction: taken (green), skipped (orange), pending (gray), overdue (red outline)
- [ ] "Overdue" label does NOT say "missed" — just shows time elapsed
- [ ] Deactivate schedule action (not delete)

**Acceptance:** Full medication CRUD. Occurrence status changes persist. Overdue shown without "missed" language.

---

### Phase 4: Measurements (Hours 8–10)

#### Task A10: Measurement Repository
**Files:**
- `lib/features/measurements/domain/measurement_entity.dart`
- `lib/features/measurements/domain/measurement_type.dart`
- `lib/features/measurements/domain/measurement_repository.dart`
- `lib/features/measurements/data/measurement_repository_impl.dart`
- `lib/features/measurements/data/measurement_providers.dart`

**Repository methods:**
```dart
abstract class MeasurementRepository {
  Future<List<MeasurementEntity>> getByRecipient(String recipientId, {MeasurementType? type});
  Future<List<MeasurementEntity>> getForDateRange(String recipientId, DateTime start, DateTime end);
  Future<MeasurementEntity?> getLatest(String recipientId, MeasurementType type);
  Future<void> create(MeasurementEntity entity);
  Future<void> update(MeasurementEntity entity);
  Future<void> delete(String id);
  Stream<List<MeasurementEntity>> watchRecent(String recipientId, {int limit = 10});
}
```

- [ ] Blood pressure stored as value1 (systolic) + value2 (diastolic)
- [ ] Validate ranges per type
- [ ] Source type tracking (manual, health_connect, other)

**Acceptance:** All measurement types can be recorded with proper validation. BP stores two values.

#### Task A11: Measurement Screens
**Files:**
- `lib/features/measurements/presentation/measurements_screen.dart`
- `lib/features/measurements/presentation/add_measurement_screen.dart`
- `lib/features/measurements/presentation/widgets/measurement_card.dart`

- [ ] Measurement history grouped by type or chronological
- [ ] Add form that adapts to measurement type:
  - Blood Pressure: systolic + diastolic fields + unit (mmHg)
  - Pulse: value + unit (bpm)
  - Temperature: value + unit (°C/°F)
  - Weight: value + unit (kg/lbs)
  - Blood Glucose: value + unit (mg/dL or mmol/L)
- [ ] Date/time picker for measurement time
- [ ] Source label display
- [ ] Range validation with user-friendly error messages (NOT silent correction)

**Acceptance:** Each measurement type has appropriate form fields. Validation rejects implausible values with clear messages.

---

### Phase 5: Appointments & Care Notes (Hours 10–12)

#### Task A12: Appointment Repository + Screens
**Files:** All files in `lib/features/appointments/`

- [ ] Repository with CRUD + date range queries + status updates
- [ ] Stream provider for upcoming appointments
- [ ] List screen with upcoming/past tabs
- [ ] Add/edit form: provider, purpose, date/time, notes
- [ ] Status management: scheduled → completed/cancelled
- [ ] Appointment card widget

**Acceptance:** Full CRUD. Status transitions work. Date range queries correct.

#### Task A13: Care Note Repository + Screens
**Files:** All files in `lib/features/care_notes/`

- [ ] Repository with CRUD + date range queries
- [ ] Chronological observation list
- [ ] Add note form with observed_at timestamp
- [ ] Source type tracking (manual vs ai_assisted)
- [ ] Review status (unreviewed/confirmed)
- [ ] Original text always preserved
- [ ] Structured summary field (nullable, set by AI later)

**Acceptance:** Notes persist with timestamps. Original text immutable. Source type displayed.

---

### Phase 6: Emergency SOS (Hours 12–15)

#### Task A14: Emergency Repository + Service
**Files:**
- `lib/features/emergency/domain/emergency_entity.dart`
- `lib/features/emergency/domain/emergency_repository.dart`
- `lib/features/emergency/domain/emergency_service.dart`
- `lib/features/emergency/data/emergency_repository_impl.dart`
- `lib/features/emergency/data/emergency_providers.dart`

- [ ] Emergency event recording (create, update status)
- [ ] Emergency service interface:
  ```dart
  abstract class EmergencyService {
    Future<String> triggerEmergency(String recipientId, String triggerType);
    Future<void> cancelEmergency(String eventId);
    Future<void> recordAction(String eventId, String action, String status);
    Future<void> callNumber(String phoneNumber);
    Future<void> openSmsComposer(String phoneNumber, String message);
  }
  ```
- [ ] Implementation using url_launcher for call/SMS
- [ ] Never claim successful delivery

**Acceptance:** Events recorded with accurate timestamps. Call/SMS open system apps without false success claims.

#### Task A15: Emergency SOS Screen
**Files:**
- `lib/features/emergency/presentation/emergency_screen.dart`
- `lib/features/emergency/presentation/widgets/sos_button.dart`
- `lib/features/emergency/presentation/widgets/countdown_overlay.dart`

- [ ] Full-screen emergency UI with large, clear elements
- [ ] Configurable emergency number (default: 911, or 117 for PH)
- [ ] Emergency call button → opens dialer
- [ ] Trusted contacts list with one-tap call
- [ ] SMS preparation with user confirmation
- [ ] Cancellation countdown (5 seconds) with prominent cancel button
- [ ] Accidental trigger protection
- [ ] Clear status feedback: "Dialer opened" not "Help is on the way"
- [ ] Works offline, no AI dependency

**Acceptance:** SOS triggers in <1 second. Cancel works during countdown. No false delivery claims. Works in airplane mode.

#### Task A16: Shake Gesture Detection (P1, after SOS stable)
**Files:**
- `lib/features/emergency/presentation/shake_detector.dart`
- Kotlin: `android/app/src/main/kotlin/com/ailaga/ailaga/MainActivity.kt`

- [ ] Three-shake detection using sensors_plus
- [ ] Configurable sensitivity
- [ ] Enable/disable from settings
- [ ] Only active when app is in foreground
- [ ] Not presented as a health-event detector

**Acceptance:** Gesture triggers SOS flow. Can be disabled. Only works in-app.

---

### Phase 7: Notification Service (Hours 15–17)

#### Task A17: Local Notification Service
**Files:**
- `lib/core/notifications/notification_service.dart`
- `lib/core/notifications/notification_provider.dart`

- [ ] Initialize flutter_local_notifications with Android config
- [ ] Schedule medication reminders based on occurrence times
- [ ] Schedule appointment reminders (e.g., 30 min before)
- [ ] Cancel reminders when schedule deactivated
- [ ] Handle notification tap → navigate to relevant screen
- [ ] Permission request flow with explanation
- [ ] Reconciliation on app start:
  - Generate occurrences for today
  - Schedule notifications for pending occurrences
  - Cancel notifications for past occurrences
- [ ] Handle permission denied gracefully with user explanation
- [ ] Persist schedule IDs for cancellation

**Acceptance:** Notifications fire on time (under test conditions). Permission denial shows explanation. Reconciliation is idempotent. No duplicates after restart.

---

### Phase 8: Testing & Integration (Hours 17–20)

#### Task A18: Unit Tests for Core Business Rules
**Files:** `test/` directory

- [ ] Medication occurrence idempotent generation
- [ ] Measurement validation (all types, edge cases)
- [ ] Phone number validation
- [ ] Date utility functions
- [ ] Emergency event state machine

#### Task A19: Integration Verification
- [ ] Verify all providers resolve correctly
- [ ] Verify database opens with all tables
- [ ] Verify CRUD operations for each repository
- [ ] Verify notification scheduling
- [ ] Test force-close → reopen → data persists
- [ ] Test airplane mode → all features work

---

## Files You Own (Do NOT let Developer B modify without coordination)

```
lib/core/                          # All core infrastructure
lib/features/care_recipient/       # All layers
lib/features/medications/          # All layers
lib/features/measurements/         # All layers
lib/features/appointments/         # All layers
lib/features/care_notes/           # All layers
lib/features/family_contacts/      # All layers
lib/features/emergency/            # All layers
android/                           # Platform configuration
test/                              # Unit tests for your code
```

## Files You Share (Coordinate changes)

```
lib/main.dart                      # Both may need initialization
lib/app/router.dart                # Both add routes
lib/core/database/app_database.dart # Schema is shared
pubspec.yaml                       # Dependency changes
```

---

## Coordination Protocol

1. **Don't modify Developer B's files** without a message
2. **Announce schema changes** — if you need to alter a table, tell B immediately
3. **Provider naming convention:** `{featureName}RepositoryProvider`, `{featureName}ListProvider`, etc.
4. **Merge strategy:** You merge first (data layer), B rebases onto your branch
5. **Test before merge:** All your unit tests must pass before declaring a task done
