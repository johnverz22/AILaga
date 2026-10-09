# AILaga — Developer B: UI Shell, Summaries, Reports & Onboarding

## Role: "Experience & Intelligence Developer"

You own the **home dashboard**, **onboarding flow**, **care brief/handover generation**, **PDF reports**, **AI service interface**, **settings**, and **app-level UX polish**.
You depend on Developer A's repository interfaces and data layer being stable.

---

## Integration Contract with Developer A

### What Developer A provides (you depend on these):
- ✅ Working Drift database with all tables
- ✅ Repository interfaces and implementations for:
  - CareRecipientRepository
  - MedicationRepository (schedules + occurrences)
  - MeasurementRepository
  - AppointmentRepository
  - CareNoteRepository
  - FamilyContactRepository
  - EmergencyRepository
- ✅ Riverpod providers for all repositories
- ✅ Notification service
- ✅ Core utilities (date formatting, validators, UUID)
- ✅ Emergency SOS screen and workflow

### What you provide (Developer A depends on these):
- Home dashboard (the main screen users see)
- Onboarding flow (calls A's repository to create first profile)
- Settings screen (configures notification permissions, emergency settings)

### What you own independently:
- Care Brief generation (queries A's repositories, formats output)
- Handover generation (queries A's repositories, editable draft)
- PDF report generation (queries A's repositories, generates PDF)
- AI service interface + deterministic fallback
- App theme and visual design
- Navigation shell and routing

---

## Task List (Priority Order)

### Phase 1: App Shell & Theme (Hours 0–2)

#### Task B1: App Theme Polish
**File:** `lib/app/theme.dart`

- [ ] Define complete theme with:
  - Primary: Deep teal (#00695C or similar)
  - Secondary: Warm amber for actions
  - Error/SOS: Strong red (#D32F2F)
  - Surface colors for cards
  - Typography scale: body 16sp, subtitle 14sp, title 20sp, headline 24sp
  - Card theme with rounded corners (12dp)
  - ElevatedButton theme: min height 48dp, rounded
  - Input decoration theme: outlined, consistent
  - AppBar theme: no elevation, centered title
  - Bottom navigation theme (if used)
- [ ] Dark mode support (basic, can be refined later)
- [ ] Accessibility: minimum contrast ratios, scalable text

**Acceptance:** Theme applied consistently. Text readable. Touch targets ≥48dp.

#### Task B2: Navigation Shell
**File:** `lib/app/router.dart`

- [ ] Verify all routes are correctly wired to screens
- [ ] Add bottom navigation or drawer for main sections:
  - Home (dashboard)
  - Medications
  - Measurements
  - Appointments
  - More (care notes, contacts, settings)
- [ ] Add route guards:
  - Redirect to `/onboarding` if no care recipient exists
  - Normal flow otherwise
- [ ] Deep link handling for notification taps
- [ ] GoRouter error page (404)
- [ ] Transition animations (subtle, not distracting)

**Acceptance:** All routes navigate correctly. Onboarding redirect works. Notification deep links resolve.

#### Task B3: App Entry Point
**File:** `lib/main.dart`

- [ ] ProviderScope wrapping
- [ ] Database initialization
- [ ] Notification service initialization
- [ ] Error handling (FlutterError.onError)
- [ ] Splash/loading state while initializing

**Acceptance:** App starts cleanly. No crashes on first launch. Initialization completes before showing UI.

---

### Phase 2: Onboarding (Hours 2–4)

#### Task B4: Onboarding Flow
**File:** `lib/features/onboarding/presentation/onboarding_screen.dart`

Create a multi-step onboarding:

**Step 1: Welcome & Privacy**
- [ ] App name and tagline
- [ ] Privacy explanation: "Your data stays on this device. No account needed. No internet required."
- [ ] Safety disclaimer: "AILaga is not a medical device or diagnostic tool."
- [ ] "Get Started" button

**Step 2: Create Care Recipient**
- [ ] Display name (required)
- [ ] Date of birth (optional)
- [ ] Allergies (optional)
- [ ] Important notes (optional)
- [ ] Call `CareRecipientRepository.create()`

**Step 3: Add Emergency Contact (Optional)**
- [ ] Name, phone, relationship
- [ ] Mark as emergency contact
- [ ] "Skip" and "Add Contact" options
- [ ] Call `FamilyContactRepository.create()` if added

**Step 4: First Medication (Optional)**
- [ ] Quick medication schedule entry
- [ ] "Skip" and "Add Medication" options
- [ ] Call `MedicationRepository.createSchedule()` if added

**Step 5: Notification Permission**
- [ ] Explain why notifications help
- [ ] Request permission via permission_handler
- [ ] Handle denial gracefully: "You can enable this later in Settings"

**Step 6: Ready**
- [ ] "Start Using AILaga" → navigate to home

- [ ] Store onboarding completion in app_settings
- [ ] Skipped optional steps don't block completion

**Acceptance:** Complete onboarding creates a care recipient. Skipping optional steps works. Permission denial doesn't block. Can't re-trigger after completion.

---

### Phase 3: Home Dashboard (Hours 4–8)

#### Task B5: Home Dashboard Screen
**File:** `lib/features/home/presentation/home_screen.dart`

- [ ] Greeting with care recipient name
- [ ] SOS button — prominent, always visible (red, top-right or floating)
- [ ] Tapping SOS → navigates to Emergency screen (Developer A's)

**Sections (each is a separate widget):**

#### Task B6: Dashboard Medication Section
**File:** `lib/features/home/presentation/widgets/dashboard_medication_section.dart`

- [ ] Show today's medication occurrences from `MedicationRepository.watchTodayOccurrences()`
- [ ] Color-coded status: taken (green ✓), skipped (orange ⊘), pending (gray ○), overdue (red outline ⊙)
- [ ] Quick-action buttons: Mark Taken, Mark Skipped
- [ ] "Overdue" = past scheduled time + still pending. NOT "missed"
- [ ] Tap → navigate to medication detail
- [ ] Empty state: "No medications scheduled for today"

**Acceptance:** Real-time updates when status changes. Overdue items highlighted. No "missed" language.

#### Task B7: Dashboard Appointment Section
**File:** `lib/features/home/presentation/widgets/dashboard_appointment_section.dart`

- [ ] Show next upcoming appointment
- [ ] Date, time, provider, purpose
- [ ] "No upcoming appointments" empty state
- [ ] Tap → navigate to appointments list

**Acceptance:** Shows correct next appointment. Updates when appointments change.

#### Task B8: Dashboard Measurement Section
**File:** `lib/features/home/presentation/widgets/dashboard_measurement_section.dart`

- [ ] Show most recent measurement of each type
- [ ] Value, unit, timestamp, source
- [ ] "No measurements recorded" empty state
- [ ] Tap → navigate to measurements list
- [ ] "Add Measurement" quick action

**Acceptance:** Shows latest readings. Correct values and units.

#### Task B9: Dashboard Tasks Section
**File:** `lib/features/home/presentation/widgets/dashboard_tasks_section.dart`

- [ ] Show unconfirmed/pending items across features:
  - Pending medication occurrences
  - Unreviewed care notes
  - Upcoming appointments (today)
- [ ] Count badge or summary
- [ ] Tap → navigate to relevant section

**Acceptance:** Accurate count of pending items. Updates in real-time.

---

### Phase 4: Care Brief (Hours 8–11)

#### Task B10: Care Brief Data Model
**File:** `lib/features/care_brief/domain/care_brief_entity.dart`

```dart
class CareBriefEntity {
  final DateTime generatedAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String careRecipientName;
  final List<MedicationBriefItem> medicationStatuses;
  final List<MeasurementBriefItem> recentMeasurements;
  final List<AppointmentBriefItem> todayAppointments;
  final List<String> unconfirmedTasks;
  final List<CareNoteBriefItem> recentObservations;
  final List<String> itemsRequiringReview;
  final String formattedText; // Full formatted summary
}
```

- [ ] Define all sub-item models
- [ ] Include source record IDs for traceability

**Acceptance:** Model captures all brief sections with source references.

#### Task B11: Deterministic Care Brief Service
**Files:**
- `lib/features/care_brief/domain/care_brief_service.dart`
- `lib/features/care_brief/data/deterministic_care_brief_service.dart`
- `lib/features/care_brief/data/care_brief_providers.dart`

- [ ] Query all repositories for the selected period
- [ ] Build brief using deterministic templates:
  ```
  📋 Daily Care Brief — [Date]
  Generated: [timestamp]
  Care Recipient: [name]

  💊 Medications
  ✅ [Med Name] — Taken at [time]
  ⏳ [Med Name] — Pending (scheduled [time])
  ⊘ [Med Name] — Skipped at [time]
  ❓ [Med Name] — Not confirmed

  📊 Recent Measurements
  Blood Pressure: 120/80 mmHg (manual, [time])
  Temperature: 36.5°C (manual, [time])

  📅 Today's Appointments
  [Time] — [Provider] — [Purpose]

  ⚠️ Items Requiring Attention
  - [count] unconfirmed medication(s)
  - [count] unreviewed care note(s)

  📝 Recent Observations
  [time] — [note text]
  ```
- [ ] Every statement traceable to a saved record
- [ ] Explicitly mark unknown/unconfirmed items
- [ ] Handle empty sections gracefully
- [ ] Show "No data for this period" instead of fabricating

**Acceptance:** Brief matches source data exactly. No invented data. Unconfirmed items labeled. Empty sections handled.

#### Task B12: Care Brief Screen
**Files:**
- `lib/features/care_brief/presentation/care_brief_screen.dart`
- `lib/features/care_brief/presentation/widgets/brief_section_card.dart`

- [ ] Date/date range selector (default: today)
- [ ] Formatted brief display with sections
- [ ] Expandable sections
- [ ] Source record links (tap to see original)
- [ ] "Generate Handover" action → navigate to handover
- [ ] "Generate PDF" action → navigate to reports
- [ ] Loading state while generating
- [ ] Error state if data query fails (NOT fabricated summary)

**Acceptance:** Brief displays correctly for any date range. Source tracing works. Actions navigate correctly.

---

### Phase 5: Caregiver Handover (Hours 11–13)

#### Task B13: Handover Entity & Service
**Files:**
- `lib/features/handover/domain/handover_entity.dart`
- `lib/features/handover/domain/handover_service.dart`
- `lib/features/handover/data/deterministic_handover_service.dart`
- `lib/features/handover/data/handover_providers.dart`

- [ ] Handover includes:
  - Period covered
  - Completed tasks (taken meds, completed appointments)
  - Unconfirmed items
  - Relevant observations
  - Upcoming appointments
  - Recent measurements
  - Special notes from caregiver
- [ ] Template format:
  ```
  🤝 Caregiver Handover
  Period: [start] to [end]
  Prepared by: [optional caregiver name]
  Generated: [timestamp]

  ✅ Completed
  - [Med] taken at [time]
  - [Appointment] completed

  ⏳ Needs Attention
  - [Med] not confirmed since [time]
  - [Note] unreviewed

  📊 Recent Vitals
  - BP: 120/80 mmHg ([time])

  📅 Upcoming
  - [Appointment] on [date]

  📝 Notes
  [caregiver can add free text here]
  ```
- [ ] Unknown/unconfirmed items clearly labeled

**Acceptance:** Handover accurately reflects period data. No assumptions about unconfirmed items.

#### Task B14: Handover Screen
**File:** `lib/features/handover/presentation/handover_screen.dart`

- [ ] Period selector
- [ ] Generated draft displayed in editable text field
- [ ] Caregiver can edit any part before sharing
- [ ] "Copy to Clipboard" action
- [ ] "Share" action → system share sheet (share_plus)
- [ ] Review step before sharing
- [ ] Loading/error states

**Acceptance:** Handover generates, is editable, copies, and shares correctly. Edit doesn't affect source records.

---

### Phase 6: PDF Reports (Hours 13–16)

#### Task B15: PDF Generator Service
**Files:**
- `lib/services/pdf/pdf_generator.dart`
- `lib/features/reports/domain/report_entity.dart`
- `lib/features/reports/domain/report_service.dart`
- `lib/features/reports/data/pdf_report_service.dart`
- `lib/features/reports/data/report_providers.dart`

**PDF Contents:**
- [ ] Header: "AILaga Care Report", care recipient name, report period, generation timestamp
- [ ] Measurements table: type, value, unit, timestamp, source
- [ ] Medication history table: medication, scheduled time, status, status time
- [ ] Appointments: date, provider, purpose, status
- [ ] Selected care notes: timestamp, observation text
- [ ] Footer: "Generated by AILaga. This is not a medical diagnosis."

**PDF Rules:**
- [ ] Use the `pdf` package (not printing) for generation
- [ ] Use `printing` package for preview and sharing
- [ ] Clean, professional formatting
- [ ] Include units and timestamps everywhere
- [ ] Record sources where available
- [ ] Exclude unrelated personal information
- [ ] Only include data within selected date range

**Acceptance:** PDF is readable, professional, correctly scoped to date range. All values match source data.

#### Task B16: Reports Screen
**File:** `lib/features/reports/presentation/reports_screen.dart`

- [ ] Date range selector (start date, end date)
- [ ] Preset ranges: Today, Last 7 days, Last 30 days, Custom
- [ ] Preview button → show PDF preview
- [ ] Share button → system share (printing package share)
- [ ] Save button → save to device
- [ ] Loading state during generation
- [ ] Error handling (no data for range)

**Acceptance:** PDF generates for any valid range. Preview renders. Share opens system share sheet.

---

### Phase 7: AI Service Interface (Hours 16–18)

#### Task B17: AI Service Interface
**Files:**
- `lib/services/ai/care_summary_service.dart`
- `lib/services/ai/care_summary_models.dart`
- `lib/services/ai/deterministic_care_summary_service.dart`

```dart
abstract interface class CareSummaryService {
  Future<CareSummaryResult> generateDailyBrief(CareSummaryInput input);
  Future<CareSummaryResult> generateHandover(CareSummaryInput input);
  Future<StructuredCareNoteResult> structureCareNote(String originalText);
}

class CareSummaryInput {
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<MedicationOccurrenceEntity> occurrences;
  final List<MeasurementEntity> measurements;
  final List<AppointmentEntity> appointments;
  final List<CareNoteEntity> notes;
  final List<String> unresolvedTasks;
}

class CareSummaryResult {
  final String summaryText;
  final List<String> sourceRecordIds;
  final List<String> unconfirmedItems;
  final List<String> ambiguousStatements;
  final GenerationStatus status; // success, partial, fallback, error
}

class StructuredCareNoteResult {
  final String structuredText;
  final String originalText; // preserved
  final List<String> ambiguousItems;
  final bool requiresReview;
}
```

- [ ] Deterministic implementation (template-based, same as care brief service)
- [ ] AI implementation stub (P1, with TODO)
- [ ] Safety rules enforced in interface contract:
  - No diagnosis generation
  - No medication recommendations
  - No invented data
  - Source preservation required
  - Caregiver confirmation required for structured notes
- [ ] Fallback strategy: if AI unavailable → use deterministic

**Acceptance:** Deterministic service produces correct output. Interface is clean for future AI implementation.

---

### Phase 8: Settings & Polish (Hours 18–21)

#### Task B18: Settings Screen
**File:** `lib/features/settings/presentation/settings_screen.dart`

- [ ] **Notifications section:**
  - Permission status indicator (enabled/disabled)
  - "Open Settings" if permission denied
  - Reminder timing preferences
- [ ] **Emergency section:**
  - Emergency number configuration
  - Gesture shortcut enable/disable
- [ ] **Privacy section:**
  - "Your data is stored locally on this device"
  - "No account or internet required"
  - "Sharing reports sends data outside this app"
- [ ] **AI section (P1):**
  - AI availability status
  - "AI summaries are optional. Template-based summaries are always available."
- [ ] **Health Connect section (P1):**
  - Integration status
  - Permission management
- [ ] **Data section:**
  - Delete all data (with double confirmation)
  - Export data (future, show as "Coming soon")
- [ ] **About section:**
  - Version number
  - "AILaga is not a medical device"

**Acceptance:** All settings functional. Permission changes reflected. Data deletion works with confirmation.

#### Task B19: Empty States & Error Handling
**Across all screens:**

- [ ] Every list has an empty state with:
  - Relevant icon
  - Helpful message
  - Action button (e.g., "Add your first medication")
- [ ] Loading states (skeleton or spinner)
- [ ] Error states with retry action
- [ ] Form validation errors shown inline
- [ ] Snackbar confirmations for actions (saved, deleted, etc.)
- [ ] Confirmation dialogs for destructive actions

**Acceptance:** No blank screens. Users always know what happened and what to do next.

#### Task B20: Accessibility & Responsiveness
- [ ] Semantic labels for all interactive elements
- [ ] Test with TalkBack (or accessibility scanner)
- [ ] Large text scaling support (up to 1.5x)
- [ ] Touch targets minimum 48dp
- [ ] Color is not the only indicator (use icons + text)
- [ ] High contrast mode support (basic)

**Acceptance:** All interactive elements have semantic labels. Text scales without overflow.

---

### Phase 9: Testing & Demo (Hours 21–24)

#### Task B21: Integration Tests
- [ ] Onboarding flow end-to-end
- [ ] Dashboard populates from real data
- [ ] Care brief matches source records
- [ ] Handover generates, edits, shares
- [ ] PDF generates with correct content
- [ ] Navigation works for all routes
- [ ] Empty states display correctly

#### Task B22: Demo Data & Scenario
Create a demo script/utility:

- [ ] Create sample care recipient: "Lola Maria", DOB 1945-03-15
- [ ] Add contacts: "Ana" (daughter, emergency), "Jun" (son)
- [ ] Add medications: Metformin 500mg (8am, 8pm), Amlodipine 5mg (8am)
- [ ] Add measurements: BP 130/85, temp 36.8°C, glucose 110 mg/dL
- [ ] Add appointment: Dr. Santos, Oct 15, annual checkup
- [ ] Add care note: "Lola complained of mild headache after lunch"
- [ ] Create mixed statuses: some taken, some pending, one skipped
- [ ] Generate brief, handover, and PDF
- [ ] Trigger and cancel SOS

**Acceptance:** Demo runs smoothly end-to-end. Tells a coherent caregiving story.

---

## Files You Own (Do NOT let Developer A modify without coordination)

```
lib/app/theme.dart                  # Visual design
lib/features/home/                  # Dashboard
lib/features/onboarding/            # First launch
lib/features/care_brief/            # Summary generation
lib/features/handover/              # Handover generation
lib/features/reports/               # PDF reports
lib/features/settings/              # Settings
lib/services/ai/                    # AI interface
lib/services/pdf/                   # PDF generation
```

## Files You Share (Coordinate changes)

```
lib/main.dart                       # Both may need initialization
lib/app/router.dart                 # Both add routes
lib/core/database/app_database.dart # Schema is shared (A owns)
pubspec.yaml                        # Dependency changes
```

---

## Coordination Protocol

1. **Don't modify Developer A's files** without a message
2. **Use A's providers directly** — don't create duplicate database queries
3. **Provider naming:** Follow A's convention: `{feature}RepositoryProvider`
4. **Merge strategy:** A merges first (data layer), you rebase onto A's branch
5. **If A's provider isn't ready:** Create a mock provider with sample data, then swap when A delivers
6. **UI patterns:** Keep consistent card styles, spacing, and interaction patterns across all your screens
