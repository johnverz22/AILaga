# AILaga — Integration & Feature Guide

How the app's features fit together, which providers/services back them, and how
to wire new work without breaking the shared contracts. For user-facing
behavior, see `docs/USER_GUIDE.md`; for design rules, `docs/UI_PROMPT.md`.

## Architecture

Flutter 3.47 / Dart 3.13. Offline-first — no accounts, no network dependency.

| Layer | Tech | Where |
|-------|------|-------|
| State | Riverpod (`ProviderScope` built in `main.dart`) | `*_providers.dart` per feature |
| Routing | GoRouter + `ShellRoute` for bottom nav | `lib/app/router.dart` |
| Storage | Drift (SQLite), UTC timestamps | `lib/core/database/` |
| Errors | `AppException` subclasses → friendly UI text | `lib/core/errors/` |
| AI | `LocalAiEngine` abstraction, deterministic fallback | `lib/services/ai/` |

`main.dart` pre-creates `appDatabaseProvider` and `notificationServiceProvider`
in a `ProviderContainer` before `runApp`.

## Route map

Bottom-nav shell (`AppShell` + `SosSensorGuard` — shake/fall SOS is armed only
inside the shell):

| Tab | Path | Screen |
|-----|------|--------|
| Today | `/` | `HomeScreen` |
| Reports | `/brief`, `/handover` | `CareBriefScreen`, `HandoverScreen` |
| Settings | `/settings`, `/reports`, `/medications`, `/measurements`, `/appointments`, `/care-notes`, `/care-recipient`, `/family-contacts`, `/ai-privacy`, `/ai-setup`, `/health-connect` | list/detail screens |

Pushed (no bottom nav, automatic back button):

| Path | Screen | `state.extra` payload |
|------|--------|-----------------------|
| `/onboarding` | `OnboardingScreen` | — |
| `/emergency` | `EmergencyScreen` | — |
| `/capture` | `VoiceCaptureScreen` | — |
| `/capture/snap` | `SnapCaptureScreen` | — |
| `/ask` | `AskScreen` | — |
| `/medications/add` | `AddMedicationScreen` | `String` recipientId, or `Map{recipientId, scheduleId?}` (edit) |
| `/medications/:id` | `MedicationDetailScreen` | path param |
| `/measurements/add` | `AddMeasurementScreen` | `String` recipientId, or `Map{recipientId, initialValues?}` (prefill, e.g. from camera pulse) |
| `/measurements/pulse-cam` | `CameraPulseScreen` | `String` recipientId |
| `/appointments/add` | `AddAppointmentScreen` | `String` recipientId, or `Map{recipientId, appointmentId?}` |
| `/care-notes/add` | `AddCareNoteScreen` | `String` recipientId |
| `/family-contacts/add` | `AddFamilyContactScreen` | `String` recipientId, or `Map{recipientId, contactId?}` |
| `/care-recipient/edit` | `EditCareRecipientScreen` | — |

Redirect rule: no care recipient → forced to `/onboarding`; a recipient exists →
`/onboarding` bounces to `/`. Nav-bar items for Speak/Ask use `context.push` so
the back button returns to the previous tab.

## Shared contracts

### Database — `lib/core/database/app_database.dart`
Tables: `CareRecipients`, `FamilyContacts`, `MedicationSchedules`,
`MedicationOccurrences`, `MeasurementLogs`, `Appointments`, `CareNotes`,
`EmergencyEvents`, `AppSettings`, `AiCaptures`, `AiProposals`.

- Never edit generated `*.g.dart` — change the table, then run build_runner.
- `AppDatabase.deleteAllData()` wipes all tables in a transaction (children
  before parents) — used by Settings → Delete all data.
- UTC in the DB, local time in the UI (`intl` for formatting).

### Providers (canonical names — don't rename)

```dart
// Core
appDatabaseProvider            // AppDatabase
notificationServiceProvider    // NotificationService
primaryCareRecipientProvider   // Stream<CareRecipientEntity?> — the single recipient

// Repositories (one per feature, in {feature}/data/{feature}_providers.dart)
careRecipientRepositoryProvider
medicationRepositoryProvider
measurementRepositoryProvider
appointmentRepositoryProvider
careNoteRepositoryProvider
familyContactRepositoryProvider
emergencyRepositoryProvider
aiCaptureRepositoryProvider

// Streams for UI
activeSchedulesProvider        // Stream<List<MedicationScheduleEntity>>
todayOccurrencesProvider       // today's med doses
recentMeasurementsProvider     // Stream<List<MeasurementEntity>>
latestMeasurementProvider      // latest per type
upcomingAppointmentsProvider
recentCareNotesProvider
familyContactsProvider

// Services
careBriefServiceProvider       // CareBriefService (deterministic)
handoverServiceProvider        // HandoverService (deterministic)
reportServiceProvider          // ReportService (PDF reports)
pdfGeneratorProvider           // PdfGenerator
emergencyServiceProvider       // EmergencyService

// AI layer (lib/services/ai/local/ai_providers.dart)
localAiEngineProvider          // currently-resolved engine
resolvedEngineProvider         // engine after tier resolution
aiTierProvider                 // AiTier (basic / model / apple)
isAiAvailableProvider          // false → Basic mode everywhere
deviceCapabilitiesProvider / deviceTierProvider / tierDecisionProvider
modelManagerProvider / modelStatusProvider   // on-device model download state

// Hardware toggles (AppSettings table)
shakeSosEnabledProvider        // default true
fallDetectionEnabledProvider   // default false
```

### Conventions

- Files: `{feature}_entity.dart`, `{feature}_repository.dart`,
  `{feature}_repository_impl.dart`, `{feature}_providers.dart`,
  `{feature}_screen.dart`.
- Repositories throw `AppException` subclasses; the UI shows friendly text —
  never raw `Error: $e`.
- Relative imports within a feature; package imports cross-feature.
- ≥48dp touch targets, icon + word on every action button.
- App-bar pattern: `SosAppBarButton` (from `lib/app/app_bar_actions.dart`) as the
  trailing action on every screen; `OnDeviceBadge` in the leading slot only on
  shell screens that don't need a back button.

## Feature catalog

### Onboarding (`features/onboarding`)
Six-step pager: welcome → care recipient → emergency contact → medication →
notifications → ready. Creates the `CareRecipient` that unlocks the router.
Centered pages are scrollable (`LayoutBuilder` + `SingleChildScrollView`) —
keep that pattern on any new full-screen step so large text can't overflow.

### Today dashboard (`features/home`)
`HomeScreen` + widget sections (medications due, measurements, appointments,
notes). All data streams from the repositories — nothing hardcoded. Med
Taken/Skip actions write `MedicationOccurrences` via `medicationRepositoryProvider`.

### Records CRUD (`features/{medications,measurements,appointments,care_notes,family_contacts,care_recipient}`)
Each feature: list screen → add/edit screen → detail where relevant.
Add/edit screens accept `extra` payloads per the route table above — pass a
`String` recipientId for "add", or a `Map` with the entity id for "edit", or
`initialValues` to prefill (`/measurements/add` only).

### Emergency SOS (`features/emergency` + `services/hardware/sos_sensor_service.dart`)
- `EmergencyScreen` shows recipient info and opens the dialer / SMS composer via
  `url_launcher` — never claim a call or text was sent.
- `SosSensorService` emits `SosSensorEvent`s from accelerometer data:
  shake (default on) and fall detection (opt-in, off by default). Toggles live
  in the `AppSettings` table via `AppSettingsService` (`hw_shake_sos`,
  `hw_fall_detection`).
- `SosSensorGuard` (wraps the nav shell) listens and pushes `/emergency` with a
  countdown overlay. Pushed pages outside the shell are not armed.
- SOS never touches AI, model, or network.

### Voice capture (`features/capture` + `services/ai/local/capture`)
`VoiceCaptureScreen`: record / type / photo → transcript → proposals →
`ReviewTrayScreen` → `ConfirmProposalsUseCase`.

- `VoiceCaptureService` wraps the mic (`record` package): `ensurePermission()`,
  `start()`, `stop() → WavAudioClip?`, `discard()`, `dispose()`.
- `SnapCaptureScreen` (`/capture/snap`): pick photo → intent
  (Monitor / Prescription / Label) → `SnapService` → proposals.
- Proposals land in `AiProposals` with `status: pending` and a `source_quote`
  that must be a substring of the transcript (validator drops it otherwise).
- `ConfirmProposalsUseCase.confirmAll(captureId)` writes approved proposals to
  the real repositories **in one transaction, idempotently**. `confirmOne` /
  `discardOne` for individual cards. AI never writes directly.

### Ask (`features/ask` + `services/ai/local/ask`)
`AskScreen` is a chat UI over `AskAgent`. `AskTools` (`ToolExecutor`) exposes
read-only queries — medication occurrences, measurements, care notes,
appointments, adherence — so answers come from real data. Refusals/failures
surface as friendly text; in Basic mode the agent answers deterministically.

### Reports (`features/care_brief`, `features/handover`, `features/reports`)
- `CareBriefScreen` (`/brief`, Reports tab): date-selected day brief from
  `DeterministicCareBriefService` — meds, measurements, appointments,
  attention items, observations. Medication names are resolved from schedules.
- `HandoverScreen` (`/handover`): shift-handover text via
  `DeterministicHandoverService`; Copy / Share buttons; optional Filipino
  narration (language feature, not UI text). Appointments are only reported as
  completed when `status == 'completed'`.
- `ReportsScreen` (`/reports`): `ReportService.generateReport` →
  `PdfGenerator.generate` → share/print via `share_plus`.

### Settings (`features/settings`)
Real state only: notification permission status, actual reminder timing
(pills at due time, appointments 30 min early — see `NotificationService`),
emergency number, app version from `pubspec.yaml`. "Delete all data" →
`cancelAllNotifications()` + `AppDatabase.deleteAllData()` + invalidate
`primaryCareRecipientProvider` (router redirects to onboarding).
Sub-panels: `AiPrivacyPanel` (`/ai-privacy`, real TrafficStats counters or
"Not measurable on this device"), `HealthConnectScreen` (`/health-connect`),
`AiSetupScreen` (`/ai-setup`).

### AI engine layer (`services/ai/local`)
- `LocalAiEngine` interface: `tier()`, `ensureLoaded()`,
  `extractFromAudio/Text/Image()` → `Stream<ExtractionEvent>`,
  `narrate()`, `ask()` → `Stream<AskEvent>`.
- Engines: `NullEngine` + `BasicTextExtractor` (Basic mode — always works),
  `GemmaLitertEngine` (on-device model via `ModelManager`), `AppleAiEngine`
  (Apple Intelligence via `apple_channels.dart`), `ScriptedEngine` (tests/demo).
- `resolvedEngineProvider` picks the engine from `deviceTierProvider`; engine
  failure or missing model → `NullEngine`, and every feature still works.
- `TrafficProofChannel` reads Android `TrafficStats` for the privacy panel —
  display real counters or "Not measurable", never fabricated numbers.

### Hardware & integrations (`services/`)
- `NotificationService` (`flutter_local_notifications`): `init`,
  `requestPermissions`, `scheduleMedicationReminder`,
  `scheduleAppointmentReminder` (fires 30 min early), `cancel*`,
  `onNotificationTap` stream.
- `HealthConnectService` (`health` package, Android): `status()`,
  `requestAccess()`, `fetchReadings()` → `HealthConnectReading`s imported as
  measurements with real `sourceLabel`s.
- `PpgAnalyzer` + `CameraPulseScreen`: fingertip-over-lens pulse estimate.
  Output is saved with `sourceType: camera_estimate` and labeled as an
  estimate, not a medical reading.
- `AppSettingsService`: string key/value store in `AppSettings` table
  (`getBool`/`setBool` helpers).

## Invariants (never break)

1. AI proposes → deterministic validation → caregiver confirms → repositories
   are written. AI code never writes to data tables.
2. Validation flags bad values (`check`); it never auto-corrects or invents.
3. `source_quote` must be a substring of the transcript, else drop the proposal.
4. Missing model / engine failure → Basic mode; every feature still works.
5. SOS works with no AI, no network, no model.
6. UI numbers (latency, traffic, model size) must be real measurements —
   record them in `docs/SPIKE_RESULTS.md` before citing them.
7. Never claim calls/SMS were delivered — only that the dialer/composer opened.

## Ownership lanes

Per `AGENTS.md`:
- **A**: `lib/core/`, domain+data of care_recipient, medications, measurements,
  appointments, care_notes, family_contacts, emergency.
- **B**: nav shell, home, onboarding, care_brief, handover, reports, settings,
  theme.
- **C**: `lib/services/ai/**`, capture, ask, ai_setup.
- **Shared**: `lib/app/router.dart` (add routes only), `pubspec.yaml`.

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after Drift table changes
flutter analyze     # must be clean
flutter test        # must pass
flutter run

# Release artifacts
flutter build apk --release
flutter build ipa --release
```

## Adding a feature — checklist

1. Entity + repository in `{feature}/domain|data`; provider named
   `{feature}RepositoryProvider`; regenerate with build_runner.
2. Screen under `presentation/`; app bar gets `SosAppBarButton`.
3. Route in `router.dart` — inside `ShellRoute` if it should keep the nav bar,
   top-level if it's a full-screen flow needing a back button and bottom
   actions. Pass ids via `state.extra` (`String` id, or `Map` for edit/prefill).
4. Friendly `AppException` handling; no raw error text in the UI.
5. Icon + word buttons, ≥48dp targets, theme colors (no hardcoded greys).
6. `flutter analyze` + `flutter test`; add a widget test if the layout is
   overflow-prone at textScale 2.0.
