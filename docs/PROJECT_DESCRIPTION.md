# AILaga — Project Description & Tech Stack

> *AI + alaga* (Filipino: "to care for")
> Last updated: 2026-10-10 (mandatory Phone helper initialization flow added)

---

## What it is

**AILaga** is a private, offline-first, AI-assisted caregiving companion for Filipino families managing daily care of an elderly or dependent family member at home.

The core problem: a caregiver — typically a working adult or a kasambahay (live-in helper) — has to log medications, vitals, and observations, pass that information to the next caregiver, and communicate clearly with doctors. The data entry is friction; the handoffs are verbal and lossy; the records live in WhatsApp threads and paper notebooks.

AILaga solves this by letting caregivers **speak or snap a photo** instead of filling forms. The on-device AI listens ("*Nainom na ni Lola ang Metformin, 130/85 ang BP*"), proposes structured records, and the caregiver confirms in one tap. Everything stays on the phone — no account, no cloud, no internet required after the initial model download.

### The one-line concept

> **"Sabihin mo lang. Kami na ang magtatala."**
> Just say it (or snap it). AILaga files it, you confirm, and it tells the family. All on the phone, even in airplane mode.

### Core design rule

> **AI proposes → deterministic code validates → the caregiver confirms → provenance is stored.**

AI is the *input* layer (voice, camera) and the *language* layer (handovers, Q&A). It is never the source of truth, never the safety path, and never gives medical advice.

---

## Features

### Capture
Voice (hold-to-talk, 30 s clips), camera (prescription labels, monitor displays), or typed text → AI extracts structured proposals → caregiver reviews and confirms via the Review tray. The AI proposes; it never writes directly to the database.

### Care records
- **Medications** — schedules with dose times, per-dose occurrence tracking (taken / skipped / pending)
- **Vital measurements** — blood pressure, pulse, temperature, weight, blood glucose
- **Appointments** — upcoming and past doctor visits
- **Care notes** — free-text observations with timestamps

All records carry provenance (`manual` vs `ai_assisted`), immutable source quotes, and review status.

### Review tray
Every AI-proposed record is shown with its verbatim source quote from the transcript. `Sure` badge = validator passed, exact match. `Check` badge = fuzzy match, ambiguous time, or out-of-range value. Edit opens the existing CRUD screen pre-filled. Confirm writes to real tables.

### Daily Care Brief
Deterministic summary of today's medications, vitals, and notes. AI optionally narrates it in Filipino, Taglish, or English for a chosen audience (sibling abroad, kasambahay, doctor). A `NarrationVerifier` strips any sentence not grounded in the source records before it is shown.

### Smart Handover
Structured caregiver shift handover with audience-aware language — plain Filipino for the kasambahay, clinical English for the doctor. Built entirely from repository facts, not AI memory.

### Ask the record
Natural-language Q&A over the actual care data ("*Nainom ba ang gamot ngayong umaga?*", "*Ano ang BP ngayong linggo?*"). Scoped read-only tool agent, ≤3 tool rounds, 20 s timeout. Medical-advice questions get a fixed refusal. Answers include source record chips.

### Doctor-ready PDF reports
Exports measurement trends, medication adherence, and care notes as a formatted PDF. Every number is pulled directly from the database — nothing is generated or estimated.

### Emergency SOS
Shake-to-trigger or button. Countdown overlay with cancel. Opens the system dialer for 911 and family contacts. Completely independent of AI and network — works with no model, no internet, no cloud.

### Camera PPG
Estimates pulse by analyzing fingertip brightness changes over the camera lens (photoplethysmography in pure Dart). No AI — deterministic signal processing: detrend → 3-sample smooth → peak-pick → median inter-peak interval. Caregiver reviews the estimate before saving with `source_type: camera_estimate`.

### Health Connect
Optional import of readings from wearable/companion apps on Android. Caregiver reviews before anything is written.

### Privacy proof panel
Reads Android `TrafficStats` per-UID via a Kotlin platform channel. Shows real bytes sent/received since the AI session started and the current airplane-mode status. The number is either real or "unavailable" — never fabricated.

---

## AI Models

| Model | Purpose | Runtime | Size on disk |
|---|---|---|---|
| **Gemma 4 E2B** `gemma-4-E2B-it-gpu.litertlm` | Voice extraction, image OCR extraction, tool-calling, narration, Ask Q&A | LiteRT-LM (CPU + GPU/OpenCL) | **2.01 GB** — default |
| **Gemma 4 E2B — Qualcomm NPU** `gemma-4-E2B-it_qualcomm_sm8750.litertlm` | Same, NPU-compiled for Snapdragon 8 Gen 4 Hexagon HTP | LiteRT-LM + Qualcomm QNN | 3.02 GB |
| **Gemma 4 E2B — Google Tensor G5** `gemma-4-E2B-it_Google_Tensor_G5.litertlm` | Same, NPU-compiled for Pixel 9 series | LiteRT-LM + Tensor NPU | 3.11 GB |
| **Gemma 4 E2B — Google Tensor G6** `gemma-4-E2B-it_Google_Tensor_G6.litertlm` | Same, NPU-compiled for Pixel 10 series | LiteRT-LM + Tensor NPU | 3.31 GB |
| **Apple Intelligence / FoundationModels** (iOS 26+) | All AI tasks on iPhone — no download, OS-managed | Apple FoundationModels API | 0 (built into OS) |

All model files are sourced from [`litert-community/gemma-4-E2B-it-litert-lm`](https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm) on HuggingFace (Apache 2.0).

**Why Gemma 4 E2B:** it is the only model that handles text + audio + image in a single file (128 K context, native function calling, Apache 2.0), runs on arm64 Android at 2.01 GB, and is confirmed multilingual at 140+ languages including Filipino/Taglish.

**GPU performance (confirmed, S26 Ultra):**

| Backend | Prefill | Decode | Time-to-first-token | Memory |
|---|---|---|---|---|
| CPU (XNNPack) | 557 tok/s | 46.9 tok/s | 1.8 s | 1 733 MB |
| GPU (OpenCL) | 3 808 tok/s | 52.1 tok/s | 0.3 s | 676 MB |

The app automatically selects GPU (OpenCL / Metal) as the default backend, falling back to CPU when the GPU delegate is unavailable.

---

## Frameworks & Libraries

### App framework

| Package | Version | Purpose |
|---|---|---|
| Flutter | 3.47.5 | Cross-platform UI (Android + iOS) |
| Dart | 3.13.4 | Language |
| `flutter_riverpod` | ^2.6.1 | Reactive state management — providers, async state, `ref.watch` |
| `go_router` | ^14.8.1 | Declarative navigation with route guards |

### On-device AI

| Package | Version | Purpose |
|---|---|---|
| `flutter_gemma` (`flutter_edge_ai`) | 1.11.3 | Flutter plugin for LiteRT-LM — model install, `getActiveModel`, sessions, multimodal input, function calling, GPU (OpenCL/Metal) and NPU (Qualcomm QNN/Google Tensor) backends |
| `flutter_gemma_litertlm` | 1.8.2 | Native LiteRT-LM prebuilt shared libraries (Android arm64, iOS arm64) |
| LiteRT-LM v0.18.x | bundled | Google's on-device GenAI orchestration: KV-cache, prompt templating, function calling, hardware dispatch |

### Database & persistence

| Package | Version | Purpose |
|---|---|---|
| `drift` | ^2.35.2 | Type-safe SQLite ORM with code generation |
| `sqlite3_flutter_libs` | ^0.5.28 | Bundled SQLite binary |
| `flutter_secure_storage` | ^9.2.4 | Android Keystore / iOS Secure Enclave for sensitive settings |

**Database tables:** care_recipients, family_contacts, medication_schedules, medication_occurrences, measurements, appointments, care_notes, ai_captures, ai_proposals.

### Notifications

| Package | Version | Purpose |
|---|---|---|
| `flutter_local_notifications` | ^18.0.1 | Medication reminders and scheduled alarms |
| `timezone` | ^0.10.1 | IANA timezone database for scheduled notifications |
| `flutter_timezone` | ^5.1.1 | Device local timezone detection |

### PDF & sharing

| Package | Version | Purpose |
|---|---|---|
| `pdf` | ^3.11.2 | Programmatic PDF document generation |
| `printing` | ^5.13.5 | PDF preview and system print dialog |
| `share_plus` | ^10.1.4 | Share handover messages and PDF exports |

### Camera & media

| Package | Version | Purpose |
|---|---|---|
| `camera` | ^0.12.1 | Live camera feed for camera-PPG pulse measurement and Snap capture |
| `image_picker` | ^1.2.4 | Gallery / camera photo selection for prescription scanning |
| `record` | ^7.1.1 | Microphone recording (WAV, 16 kHz mono) for voice capture |

### Sensors & hardware

| Package | Version | Purpose |
|---|---|---|
| `sensors_plus` | ^6.1.1 | Accelerometer for shake-to-SOS detection |
| `url_launcher` | ^6.3.1 | Opens system dialer and SMS app for emergency contacts |
| `permission_handler` | ^11.3.1 | Microphone, camera, and storage permissions |

### Health data

| Package | Version | Purpose |
|---|---|---|
| `health` | ^13.3.1 | Android Health Connect + iOS HealthKit import |

### Utilities

| Package | Version | Purpose |
|---|---|---|
| `crypto` | ^3.0.7 | SHA-256 verification of downloaded model files |
| `intl` | ^0.20.2 | Date/time formatting, locale support (Filipino, English) |
| `path_provider` | ^2.1.5 | Application documents directory for model file storage |
| `path` | ^1.9.1 | Cross-platform path manipulation |
| `uuid` | ^4.5.1 | UUID generation for all entity IDs |
| `google_fonts` | ^8.1.0 | Inter / Noto Sans typography |
| `material_symbols_icons` | ^4.2960.0 | Material Symbols icon set |

### Dev tooling

| Package | Version | Purpose |
|---|---|---|
| `build_runner` | ^2.4.13 | Code generation runner |
| `drift_dev` | ^2.35.1 | Generates type-safe Drift table classes and query methods |
| `mocktail` | ^1.0.4 | Mock objects for unit tests |
| `fake_async` | ^1.3.3 | Fake timers/clocks for async test scenarios |

---

## Platform Code (Kotlin / Swift)

### Android — `MainActivity.kt`

Three `MethodChannel` implementations:

**`com.ailaga.ailaga/device`** — Device capability probe for AI tier detection and NPU model routing. Returns:
- `ramMb` — total RAM (ActivityManager.MemoryInfo)
- `sdkInt` — Android API level
- `abis` — supported ABIs (`Build.SUPPORTED_ABIS`)
- `freeStorageBytes` — available storage (StatFs)
- `platform` — `"android"`
- `socModel` — SoC chipset string: `Build.SOC_MODEL` (API 31+) + `Build.HARDWARE` + `Build.MODEL`, lower-cased. Used to auto-select the Qualcomm or Tensor NPU model file.

**`com.ailaga.ailaga/traffic`** — Per-UID network traffic for the privacy proof panel. Returns:
- `getUidRxBytes` — `TrafficStats.getUidRxBytes(Process.myUid())`
- `getUidTxBytes` — `TrafficStats.getUidTxBytes(Process.myUid())`

### iOS — Swift MethodChannels

- **`AppleAiChannel`** — Checks `FoundationModels` availability and runs text inference via Apple Intelligence
- **`AppleSpeechChannel`** — On-device ASR via `Speech` framework (transcribes WAV files)
- **`AppleVisionChannel`** — On-device OCR via `Vision` framework (reads prescription labels and monitor displays)

---

## App Startup Sequence

The app follows a five-stage deterministic cold-start sequence:

```
main()
 ├── ErrorHandler.init()                       on-device error log
 ├── FlutterGemma.initialize(LiteRtLmEngine)   register inference engine
 │     └── errors logged via ErrorHandler (not swallowed silently)
 ├── FlutterError.onError hook
 ├── ProviderContainer
 │   ├── appDatabaseProvider   (eager Drift SQLite open + migration)
 │   └── notificationServiceProvider   (eager plugin init)
 └── runApp → AilagaApp
         ├── ref.watch(routerProvider)
         ├── ref.listen(resolvedEngineProvider)   async engine swap
         └── EngineLifecycleGuard
               └── 60 s idle unload heartbeat

Router: initialLocation = '/splash'
 └── SplashScreen
       ├── 700 ms scale + fade animation
       ├── watches appReadyProvider (real initialization — not a fixed timer)
       └── when ready (min 1.4 s displayed):
             needsOnboarding   → /onboarding
             needsModelSetup   → /initialization  ← NEW
             unsupportedDevice → /  (Basic mode, skip init)
             modelReady        → /

/initialization  (InitializationScreen — NEW)
 ├── Checking state  — probes device tier + model status (spinner)
 ├── iOS            — Apple Intelligence check, no download needed
 ├── Unsupported    — plain explanation, Continue → HomeScreen
 ├── Not installed  — "Download" offer, real file size from HEAD request
 ├── Downloading    — live %, progress bar, Pause, resumable
 ├── Verifying      — SHA-256 check at 100%
 ├── Ready ✓        — 1.2 s display then auto-navigates to HomeScreen
 └── Error          — plain-words message, Retry / "Try later"

/  (HomeScreen)
 ├── PhoneHelperSetupBanner (NEW) — amber bar at top, visible until model
 │     is installed; tapping opens /initialization; hidden reactively
 │     when modelStatusProvider reports installed
 └── … dashboard sections as before
```

### appReadyProvider

`lib/app/app_ready_provider.dart` — single `FutureProvider<AppReadyState>` combining:

| Check | Priority | Notes |
|---|---|---|
| `primaryCareRecipientProvider` | 1st | If absent → `needsOnboarding` |
| `Platform.isIOS` | 2nd | Apple Intelligence path — no download loop |
| `deviceTierProvider` | 3rd | Android `AiTier.basic` → `unsupportedDevice` |
| `modelStatusProvider` | 4th | `installed` → `modelReady`; else → `needsModelSetup` |

The router redirect and `SplashScreen` both consume `appReadyProvider` as the single source of truth for navigation decisions.

---

## AI Development Approach

The AI layer follows a strict **propose → validate → confirm → provenance** pipeline. AI never writes to the database.

```
Voice / Camera / Text
        ↓
   Engine inference
   (GemmaLiteRtEngine or AppleAiEngine)
        ↓
  ProposalValidator  ←── deterministic business rules
   • quote grounding       source_quote ⊆ transcript
   • range checks          BP 50–300, temp 30–45 °C …
   • med matching          MedMatcher (trigram + Levenshtein)
   • time resolution       TimeResolver (Taglish phrases → UTC)
        ↓
   Review tray (UI)
   Sure / Check badges, verbatim source quotes
        ↓
  ConfirmProposalsUseCase
   writes with source=ai_assisted, review_status=confirmed
        ↓
   Real database tables
```

**Fallback chain at every layer:**
- Engine fails → `NullEngine` + `BasicTextExtractor` (pure-Dart regex, no AI required)
- Narration verifier rejects output → deterministic template
- Model not installed → entire app works as a deterministic care log
- SOS, medication alarms, PDF accuracy → fully independent of AI layer

**Key safety rules enforced in code, not just prompts:**
1. `source_quote` not a substring of the transcript → proposal dropped
2. Out-of-range measurement → `check` flag, never auto-corrected
3. Unscheduled medication → "Hindi nakalista ang X" card, never silently confirmed
4. Future time for a "taken" event → proposal rejected
5. Medical-advice patterns in Ask responses → fixed refusal injected
6. SOS never routed through AI — it runs on the first app start with zero dependencies

**Phone helper initialization (mandatory, not optional):**

The model download is now a required first-run step, not a buried Settings action. The `InitializationScreen` gates entry to HomeScreen until the model is installed, the device is confirmed unsupported (Basic mode is acceptable), or the user explicitly chooses "Try later" (HomeScreen banner persists as a reminder). Every cold start re-evaluates `appReadyProvider` — returning users with an installed model see a 1–2 s "Checking…" flash and proceed instantly.

---

## Bugs Fixed During Implementation

| Bug | Location | Fix |
|---|---|---|
| `FlutterGemma.initialize()` errors silently swallowed | `lib/main.dart` | Now logged via `ErrorHandler.recordError()` for on-device debugging |
| Splash screen used a hardcoded 1600 ms timer, not real initialization | `splash_screen.dart` | Replaced with `appReadyProvider` watch; minimum 1.4 s display, then provider-driven navigation |
| Router redirect only checked for care recipient, ignored model state | `lib/app/router.dart` | New 4-state redirect via `appReadyProvider` covering onboarding, initialization, unsupported device, and ready |
| Download was only discoverable via Settings → Phone helper | `ai_setup_screen.dart` | `InitializationScreen` at `/initialization` is now the primary download path; AiSetupScreen is settings-only management |

---

## Existing Code & Assets

| Item | Source | License |
|---|---|---|
| All application code | Original — written for this project | Private |
| Gemma 4 E2B model files | `litert-community/gemma-4-E2B-it-litert-lm` on HuggingFace | Apache 2.0 |
| Google Fonts (Inter, Noto Sans) | Loaded at runtime via `google_fonts` | SIL Open Font License |
| Material Symbols icon font | Bundled via `material_symbols_icons` | Apache 2.0 |
| `assets/branding/app_mark.png` | Original app logo | Private |

No third-party datasets, pre-trained adapters, or fine-tuned model weights are used. Gemma 4 E2B is used as-is from the official LiteRT-community release with no modifications.
