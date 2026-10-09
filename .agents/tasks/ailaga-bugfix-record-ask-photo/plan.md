# Implementation Plan — AILaga Bug Fix: Record, Ask, Photo Analyze

> Ground truth: `dart analyze lib/` → **0 issues**. All three bugs are runtime behavioral failures, not compile errors.
> Build command: `flutter pub get && dart run build_runner build --delete-conflicting-outputs`
> Test command: `dart test` (flutter test fails due to `.dart_tool/version` Windows lock; `dart test` is clean)
> Generated files (`*.g.dart`) must NOT be edited by hand.

---

## Root Cause Summary

### BUG 1 — Record Functionality
**Root cause:** `VoiceCaptureService.start()` (line 37 of `lib/services/ai/local/capture/voice_capture_service.dart`) calls `_recorder.hasPermission()` and throws `AiUnavailable` when it returns false. In `record ^7.1.1`, `hasPermission()` **checks** permission status; it does **not request** it. On a fresh install (no prior grant) it returns false and recording fails silently — the mic permission dialog never appears. The screen at `lib/features/capture/presentation/voice_capture_screen.dart` catches the `AiUnavailable` exception (line ~213) and shows "Microphone not available" — correct error path, but the request step is missing entirely.

**Secondary concern:** The `record` package requires `RECORD_AUDIO` in the manifest (present ✓) but also expects `permission_handler` to have called `Permission.microphone.request()` before the first `start()` on Android 6+ devices. The `ensurePermission()` helper exists in the service but is never called by the UI — `_toggleRecording()` calls `_voiceService.start()` directly.

### BUG 2 — Ask Functionality
**Root cause:** `GemmaLiteRtEngine.ensureLoaded()` (lines 43–59 of `lib/services/ai/local/engines/gemma_litert_engine.dart`) calls `FlutterGemma.initialize(inferenceEngines: [LiteRtLmEngine()])` inside the engine method. According to `flutter_gemma` 1.11.3 docs, `FlutterGemma.initialize(...)` **must be called once in `main()`** (before `runApp`); calling it lazily inside an inference method can produce async race conditions and the model context can be lost between calls. `main.dart` never calls `FlutterGemma.initialize(...)`.

**Secondary concern:** `FlutterGemma.installModel(...).fromFile(modelPath).install()` is re-called inside `ensureLoaded()` every time `_model == null` — after each 60s idle unload (`unloadIfIdle`) the engine will try to re-install the already-installed model file on every inference call, which may error out mid-conversation.

**Deterministic (Basic mode) Ask works correctly** — `AskAgent._deterministicAnswer()` via `AskTools` is functional without the model.

### BUG 3 — Photo Analyze Functionality
**Root cause (primary):** In `SnapCaptureScreen._processPhoto()` (line ~151 of `lib/features/capture/presentation/snap_capture_screen.dart`), the "Use this photo" button is **not disabled in Basic mode** (when `NullEngine` is the active engine). The `isBasic` guard at the top disables Camera/Gallery buttons, but after `_photo != null` the Process button is always enabled. Tapping it calls `engine.extractFromImage(...)` on `NullEngine`, which returns `Stream.error(AiUnavailable(...))` → the `await for` in `_processPhoto` throws → the outer `catch (e)` shows the generic "Something went wrong. Try again." snackbar. The user sees an error, not a clear "install the helper" message.

**Root cause (secondary):** `SnapService.snapPhoto()` calls `image_picker` directly with no prior permission check. On Android, `image_picker` triggers the OS camera permission dialog automatically, but if the user has previously denied and checked "Don't ask again", the call returns `null` silently with no user feedback. The screen silently does nothing when `input == null` — no explanation is shown.

---

## Implementation Plan

- [ ] 1. Fix microphone permission request in `VoiceCaptureService`.
      `start()` currently calls `hasPermission()` (check only) and throws on false. Change it to: call `AudioRecorder().hasPermission()` first; if false, call `Permission.microphone.request()` from `permission_handler`, then re-check. Only throw `AiUnavailable` if permission is still denied after the explicit request.
      Add `import 'package:permission_handler/permission_handler.dart';` to the service.
      Files to modify: `lib/services/ai/local/capture/voice_capture_service.dart`
      Files NOT to change: AndroidManifest.xml (RECORD_AUDIO is already present), voice_capture_screen.dart (error handling is correct), any UI layout file.
      Verify: `dart test test/services/` — existing tests pass. On device: tap Record → OS permission dialog appears → grant → recording starts.

- [ ] 2. Fix `FlutterGemma.initialize(...)` placement — move to `main.dart`.
      Remove the `FlutterGemma.initialize(inferenceEngines: [LiteRtLmEngine()])` call from `GemmaLiteRtEngine.ensureLoaded()` (lines 46–48). Add `await FlutterGemma.initialize(inferenceEngines: [LiteRtLmEngine()])` to `main()` in `main.dart`, after `WidgetsFlutterBinding.ensureInitialized()` and before `runApp(...)`. Wrap in try/catch so a platform failure (tests, simulator) falls back silently — the `NullEngine` default handles that case.
      Files to modify: `lib/main.dart`, `lib/services/ai/local/engines/gemma_litert_engine.dart`
      Files NOT to change: `ai_providers.dart`, `app.dart`, engine_lifecycle.dart, any UI file.
      Verify: `dart analyze lib/` — 0 issues. `dart test` — all tests pass. On device (when model is installed): Ask screen responds with AI answer instead of "Something went wrong."

- [ ] 3. Fix model re-install loop in `GemmaLiteRtEngine.ensureLoaded()`.
      After removing `FlutterGemma.initialize` (step 2), fix the re-install pattern: `FlutterGemma.installModel(...).fromFile(modelPath).install()` is called every time `_model == null` (i.e., after every idle unload). Replace with a guard: only call `.install()` if the model is not already registered (`FlutterGemma.hasActiveModel()` returns false). Add the `_initialized` flag to also track the install step separately from the session load step, so unload→reload does not re-run the install.
      Files to modify: `lib/services/ai/local/engines/gemma_litert_engine.dart`
      Files NOT to change: any other file.
      Verify: `dart test` — existing engine tests pass. On device: second Ask query after idle unload does not error with "install failed."

- [ ] 4. Fix the "Use this photo" Process button disabled state in Basic mode.
      In `SnapCaptureScreen`, the Process button (rendered inside `if (_photo != null)`) is never guarded by `isBasic`. Add the same `isBasic` guard that the Camera/Gallery buttons already have: disable the button when `isBasic == true` and show an explanatory message ("Phone helper is off. To analyze photos, install it in Settings → Phone helper.") below the photo when a photo is selected but Basic mode is active.
      This is the minimum change to restore correct behavior — no layout changes, no button moves.
      Files to modify: `lib/features/capture/presentation/snap_capture_screen.dart`
      Files NOT to change: button positions/layout structure (per Part B Rule 6), bottom nav, any unrelated screen.
      Verify: `dart analyze lib/` — 0 issues. `dart test test/features/capture/` — existing tests pass. Manual: in Basic mode (no model installed), after picking a photo the Process button is disabled and the message is visible.

- [ ] 5. Add camera permission denial feedback in `SnapCaptureScreen._pick()`.
      `_snapService.snapPhoto()` (and `pickFromGallery()`) return `null` when the user denies camera permission (silently, after "Don't ask again"). After the null check `if (input != null && mounted)`, add an `else` branch that shows a `ScaffoldMessenger` SnackBar: "Camera access denied. Allow it in Settings to use photos." This is a minimal addition — no layout changes.
      Also: before calling `_pick(camera: true)`, request `Permission.camera` via `permission_handler` and explain the rationale if denied. Add `import 'package:permission_handler/permission_handler.dart';` to `snap_capture_screen.dart`.
      Files to modify: `lib/features/capture/presentation/snap_capture_screen.dart`
      Files NOT to change: AndroidManifest.xml (CAMERA is already present), SnapService, any layout structure.
      Verify: `dart analyze lib/` — 0 issues. Manual: first camera tap on a fresh install shows the OS dialog; denial shows the SnackBar message.

- [ ] 6. Add a null-safety guard and descriptive error message in `_processPhoto()`.
      Currently `_processPhoto()` catches all exceptions and shows the same generic "Something went wrong." Update the catch to distinguish `AiUnavailable` (message: "Phone helper is off. Install it in Settings → Phone helper to analyze photos.") from other errors (keep the generic message). This ensures if the engine somehow degrades mid-session the user gets an actionable message, not a cryptic error.
      Files to modify: `lib/features/capture/presentation/snap_capture_screen.dart`
      Files NOT to change: any other file.
      Verify: `dart analyze lib/` — 0 issues. `dart test test/features/capture/` — existing tests pass.

---

## Files the Coder Must Read Before Touching Any Code

| File | Why |
|------|-----|
| `lib/services/ai/local/capture/voice_capture_service.dart` | BUG 1 root — `start()` permission logic |
| `lib/features/capture/presentation/voice_capture_screen.dart` | BUG 1 — caller of `_voiceService.start()`, error handling |
| `lib/main.dart` | BUG 2 — where `FlutterGemma.initialize` must move to |
| `lib/services/ai/local/engines/gemma_litert_engine.dart` | BUG 2 + 3 — `ensureLoaded()` init + re-install logic |
| `lib/services/ai/local/ai_providers.dart` | BUG 2 — engine provider wiring, `resolvedEngineProvider` |
| `lib/app/app.dart` | BUG 2 — `ref.listen(resolvedEngineProvider, ...)` engine swap |
| `lib/features/ask/presentation/ask_screen.dart` | BUG 2 — `_sendQuery()` → `askAgentProvider` → `AskAgent.ask()` |
| `lib/features/ask/data/ask_providers.dart` | BUG 2 — `askAgentProvider` construction |
| `lib/services/ai/local/ask/ask_agent.dart` | BUG 2 — deterministic fallback vs engine path |
| `lib/features/capture/presentation/snap_capture_screen.dart` | BUG 3 — `isBasic` guard gap, `_pick()` null handling, `_processPhoto()` catch |
| `lib/services/ai/local/capture/snap_service.dart` | BUG 3 — `snapPhoto()` / `pickFromGallery()` — no permission pre-check |
| `android/app/src/main/AndroidManifest.xml` | Confirm RECORD_AUDIO + CAMERA present (they are ✓) |
| `lib/services/ai/local/engines/null_engine.dart` | Understand `AiUnavailable` errors returned from all null engine methods |
| `lib/services/ai/local/local_ai_engine.dart` | `AiUnavailable` exception class definition |
| `pubspec.yaml` | Confirm `permission_handler: ^11.3.1`, `record: ^7.1.1`, `image_picker: ^1.2.4` (all present ✓) |
| `test/features/capture/confirm_proposals_test.dart` | Run to verify no regression in capture tests |
| `test/services/ai/local/ask/ask_agent_test.dart` | Run to verify no regression in Ask agent tests |

---

## Excluded Items — Confirmed Safe

All Part B exclusions are safe to ignore in this fix:

| Excluded item | Safe? | Reason |
|---|---|---|
| Enable Notifications overflow | ✓ Safe | Not touched by any of the 3 bug fixes |
| Lola personalization labels | ✓ Safe | No text or label changes in scope |
| Message Screen / Capture Screen bottom nav | ✓ Safe | Bottom nav in `router.dart` / `AppShell` is not modified |
| Today Screen badges / greeting | ✓ Safe | `home_screen.dart` not in scope |
| Reports Screen | ✓ Safe | `reports_screen.dart` not in scope |
| Capture Screen button positions | ✓ Safe | Steps 4–6 only touch guard logic and snackbar text, not layout structure or button positions |

---

## Verification Approach per Feature

**Record (after steps 1):**
```
dart test test/services/ai/local/
```
Expected: all passing. Manual device test: tap Record on fresh install → OS mic permission dialog → grant → waveform animates → Stop → audio WAV created → processing starts.

**Ask (after steps 2–3):**
```
dart analyze lib/
dart test test/services/ai/local/ask/
```
Expected: 0 issues, all tests pass. Manual device test (model installed): Ask "What was the last BP?" → answer displayed with source chip. Manual device test (no model): same question → deterministic answer "No BP readings yet." / "Last BP: …"

**Photo Analyze (after steps 4–6):**
```
dart analyze lib/
dart test test/features/capture/
```
Expected: 0 issues, all tests pass. Manual device test (no model): Camera button opens OS dialog → photo selected → Process button is disabled + message shown. Manual device test (model installed): Camera → photo → Process → "Reading…" spinner → Review Tray with proposals.

---

## Remaining Blockers (Not Fixable in Code)

1. **Model not installed:** The Gemma 4 E2B model (~2.9 GB) must be downloaded via Settings → Phone helper. Without it, all AI-assisted features (AI mode of Record, Photo Analyze) run in Basic mode (deterministic fallback). This is by design and correctly communicated to the user via existing banners.
2. **Spikes S1–S6 unrun:** Transcription accuracy, RAM headroom, photo OCR quality, and tool-call JSON reliability on the real Android demo phone are unverified. The code paths are correct; real-world fidelity depends on hardware.
3. **minSdk 26 vs LiteRT minSdk 30:** `build.gradle.kts` sets `minSdk = 26`. `DeviceProbe.decide()` gates the Gemma engine on `AiThresholds.minSdkForLiteRt` (defined in `ai_thresholds.dart`). On devices with SDK 26–29 the engine correctly falls back to Basic mode, but the LiteRT native library will fail to load before the gate is reached. This does not crash the app (NullEngine stays active), but it should be verified on the demo device.
