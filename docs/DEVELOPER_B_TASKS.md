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

- [x] Define complete theme with:
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
- [x] Dark mode support (basic, can be refined later)
- [x] Accessibility: minimum contrast ratios, scalable text

**Acceptance:** Theme applied consistently. Text readable. Touch targets ≥48dp.

#### Task B2: Navigation Shell
**File:** `lib/app/router.dart`

- [x] Verify all routes are correctly wired to screens
- [x] Add bottom navigation or drawer for main sections:
  - Home (dashboard)
  - Medications
  - Measurements
  - Appointments
  - More (care notes, contacts, settings)
- [x] Add route guards:
  - Redirect to `/onboarding` if no care recipient exists
  - Normal flow otherwise
- [x] Deep link handling for notification taps
- [x] GoRouter error page (404)
- [x] Transition animations (subtle, not distracting)

**Acceptance:** All routes navigate correctly. Onboarding redirect works. Notification deep links resolve.

#### Task B3: App Entry Point
**File:** `lib/main.dart`

- [x] ProviderScope wrapping
- [x] Database initialization
- [x] Notification service initialization
- [x] Error handling (FlutterError.onError)
- [x] Splash/loading state while initializing

**Acceptance:** App starts cleanly. No crashes on first launch. Initialization completes before showing UI.

---

### Phase 2: Onboarding (Hours 2–4)

#### Task B4: Onboarding Flow
**File:** `lib/features/onboarding/presentation/onboarding_screen.dart`

Create a multi-step onboarding:

**Step 1: Welcome & Privacy**
- [x] App name and tagline
- [x] Privacy explanation: "Your data stays on this device. No account needed. No internet required."
- [x] Safety disclaimer: "AILaga is not a medical device or diagnostic tool."
- [x] "Get Started" button

**Step 2: Create Care Recipient**
- [x] Display name (required)
- [x] Date of birth (optional)
- [x] Allergies (optional)
- [x] Important notes (optional)
- [x] Call `CareRecipientRepository.create()`

**Step 3: Add Emergency Contact (Optional)**
- [x] Name, phone, relationship
- [x] Mark as emergency contact
- [x] "Skip" and "Add Contact" options
- [x] Call `FamilyContactRepository.create()` if added

**Step 4: First Medication (Optional)**
- [x] Quick medication schedule entry
- [x] "Skip" and "Add Medication" options
- [x] Call `MedicationRepository.createSchedule()` if added

**Step 5: Notification Permission**
- [x] Explain why notifications help
- [x] Request permission via permission_handler
- [x] Handle denial gracefully: "You can enable this later in Settings"

**Step 6: Ready**
- [x] "Start Using AILaga" → navigate to home

- [x] Store onboarding completion in app_settings (Implicitly handled by primary recipient check)
- [x] Skipped optional steps don't block completion

**Acceptance:** Complete onboarding creates a care recipient. Skipping optional steps works. Permission denial doesn't block. Can't re-trigger after completion.

---

### Phase 3: Home Dashboard (Hours 4–8)

#### Task B5: Home Dashboard Screen
**File:** `lib/features/home/presentation/home_screen.dart`

- [x] Greeting with care recipient name
- [x] SOS button — prominent, always visible (red, top-right or floating)
- [x] Tapping SOS → navigates to Emergency screen (Developer A's)

**Sections (each is a separate widget):**

#### Task B6: Dashboard Medication Section
**File:** `lib/features/home/presentation/widgets/dashboard_medication_section.dart`

- [x] Show today's medication occurrences from `MedicationRepository.watchTodayOccurrences()`
- [x] Color-coded status: taken (green ✓), skipped (orange ⊘), pending (gray ○), overdue (red outline ⊙)
- [x] Quick-action buttons: Mark Taken, Mark Skipped
- [x] "Overdue" = past scheduled time + still pending. NOT "missed"
- [x] Tap → navigate to medication detail
- [x] Empty state: "No medications scheduled for today"

**Acceptance:** Real-time updates when status changes. Overdue items highlighted. No "missed" language.

#### Task B7: Dashboard Appointment Section
**File:** `lib/features/home/presentation/widgets/dashboard_appointment_section.dart`

- [x] Show next upcoming appointment
- [x] Date, time, provider, purpose
- [x] "No upcoming appointments" empty state
- [x] Tap → navigate to appointments list

**Acceptance:** Shows correct next appointment. Updates when appointments change.

#### Task B8: Dashboard Measurement Section
**File:** `lib/features/home/presentation/widgets/dashboard_measurement_section.dart`

- [x] Show most recent measurement of each type
- [x] Value, unit, timestamp, source
- [x] "No measurements recorded" empty state
- [x] Tap → navigate to measurements list
- [x] "Add Measurement" quick action

**Acceptance:** Shows latest readings. Correct values and units.

#### Task B9: Dashboard Tasks Section
**File:** `lib/features/home/presentation/widgets/dashboard_tasks_section.dart`

- [x] Show unconfirmed/pending items across features:
  - Pending medication occurrences
  - Unreviewed care notes
  - Upcoming appointments (today)
- [x] Count badge or summary
- [x] Tap → navigate to relevant section

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

- [x] Define all sub-item models
- [x] Include source record IDs for traceability

**Acceptance:** Model captures all brief sections with source references.

#### Task B11: Deterministic Care Brief Service
**Files:**
- `lib/features/care_brief/domain/care_brief_service.dart`
- `lib/features/care_brief/data/deterministic_care_brief_service.dart`
- `lib/features/care_brief/data/care_brief_providers.dart`

- [x] Query all repositories for the selected period
- [x] Build brief using deterministic templates:
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
- [x] Every statement traceable to a saved record
- [x] Explicitly mark unknown/unconfirmed items
- [x] Handle empty sections gracefully
- [x] Show "No data for this period" instead of fabricating

**Acceptance:** Brief matches source data exactly. No invented data. Unconfirmed items labeled. Empty sections handled.

#### Task B12: Care Brief Screen
**Files:**
- `lib/features/care_brief/presentation/care_brief_screen.dart`
- `lib/features/care_brief/presentation/widgets/brief_section_card.dart`

- [x] Date/date range selector (default: today)
- [x] Formatted brief display with sections
- [x] Expandable sections
- [x] Source record links (tap to see original)
- [x] "Generate Handover" action → navigate to handover
- [x] "Generate PDF" action → navigate to reports
- [x] Loading state while generating
- [x] Error state if data query fails (NOT fabricated summary)

**Acceptance:** Brief displays correctly for any date range. Source tracing works. Actions navigate correctly.

---

### Phase 5: Caregiver Handover (Hours 11–13)

#### Task B13: Handover Entity & Service
**Files:**
- `lib/features/handover/domain/handover_entity.dart`
- `lib/features/handover/domain/handover_service.dart`
- `lib/features/handover/data/deterministic_handover_service.dart`
- `lib/features/handover/data/handover_providers.dart`

- [x] Handover includes:
  - Period covered
  - Completed tasks (taken meds, completed appointments)
  - Unconfirmed items
  - Relevant observations
  - Upcoming appointments
  - Recent measurements
  - Special notes from caregiver
- [x] Template format:
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
- [x] Unknown/unconfirmed items clearly labeled

**Acceptance:** Handover accurately reflects period data. No assumptions about unconfirmed items.

#### Task B14: Handover Screen
**File:** `lib/features/handover/presentation/handover_screen.dart`

- [x] Period selector
- [x] Generated draft displayed in editable text field
- [x] Caregiver can edit any part before sharing
- [x] "Copy to Clipboard" action
- [x] "Share" action → system share sheet (share_plus)
- [x] Review step before sharing
- [x] Loading/error states

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
- [x] Header: "AILaga Care Report", care recipient name, report period, generation timestamp
- [x] Measurements table: type, value, unit, timestamp, source
- [x] Medication history table: medication, scheduled time, status, status time
- [x] Appointments: date, provider, purpose, status
- [x] Selected care notes: timestamp, observation text
- [x] Footer: "Generated by AILaga. This is not a medical diagnosis."

**PDF Rules:**
- [x] Use the `pdf` package (not printing) for generation
- [x] Use `printing` package for preview and sharing
- [x] Clean, professional formatting
- [x] Include units and timestamps everywhere
- [x] Record sources where available
- [x] Exclude unrelated personal information
- [x] Only include data within selected date range

**Acceptance:** PDF is readable, professional, correctly scoped to date range. All values match source data.

#### Task B16: Reports Screen
**File:** `lib/features/reports/presentation/reports_screen.dart`

- [x] Date range selector (start date, end date)
- [x] Preset ranges: Today, Last 7 days, Last 30 days, Custom
- [x] Preview button → show PDF preview
- [x] Share button → system share (printing package share)
- [x] Save button → save to device
- [x] Loading state during generation
- [x] Error handling (no data for range)

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

- [x] Deterministic implementation (template-based, same as care brief service)
- [x] AI implementation stub (P1, with TODO)
- [x] Safety rules enforced in interface contract:
  - No diagnosis generation
  - No medication recommendations
  - No invented data
  - Source preservation required
  - Caregiver confirmation required for structured notes
- [x] Fallback strategy: if AI unavailable → use deterministic

**Acceptance:** Deterministic service produces correct output. Interface is clean for future AI implementation.

---

### Phase 8: Settings & Polish (Hours 18–21)

#### Task B18: Settings Screen
**File:** `lib/features/settings/presentation/settings_screen.dart`

- [x] **Notifications section:**
  - Permission status indicator (enabled/disabled)
  - "Open Settings" if permission denied
  - Reminder timing preferences
- [x] **Emergency section:**
  - Emergency number configuration
  - Gesture shortcut enable/disable
- [x] **Privacy section:**
  - "Your data is stored locally on this device"
  - "No account or internet required"
  - "Sharing reports sends data outside this app"
- [x] **AI section (P1):**
  - AI availability status
  - "AI summaries are optional. Template-based summaries are always available."
- [x] **Health Connect section (P1):**
  - Integration status
  - Permission management
- [x] **Data section:**
  - Delete all data (with double confirmation)
  - Export data (future, show as "Coming soon")
- [x] **About section:**
  - Version number
  - "AILaga is not a medical device"

**Acceptance:** All settings functional. Permission changes reflected. Data deletion works with confirmation.

#### Task B19: Empty States & Error Handling
**Across all screens:**

- [x] Every list has an empty state with:
  - Relevant icon
  - Helpful message
  - Action button (e.g., "Add your first medication")
- [x] Loading states (skeleton or spinner)
- [x] Error states with retry action
- [x] Form validation errors shown inline
- [x] Snackbar confirmations for actions (saved, deleted, etc.)
- [x] Confirmation dialogs for destructive actions

**Acceptance:** No blank screens. Users always know what happened and what to do next.

#### Task B20: Accessibility & Responsiveness
- [x] Semantic labels for all interactive elements
- [x] Test with TalkBack (or accessibility scanner)
- [x] Large text scaling support (up to 1.5x)
- [x] Touch targets minimum 48dp
- [x] Color is not the only indicator (use icons + text)
- [x] High contrast mode support (basic)

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
lib/services/ai/                    # AI interface (Owned by C, B keeps B17 interface)
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
