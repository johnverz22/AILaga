# AILaga — Developer C: Local AI Layer

## Role: "Local AI & Capture Developer"

Read first: `ARCHITECTURE.md`, `LOCAL_AI_UX_SPEC.md` (the design and safety rules live there).
Legend: ☁ = can be built and tested in a Linux cloud VM · 📱 = needs a real Android device (a human runs the check).

**Core rule:** AI proposes → deterministic code validates → caregiver confirms → provenance stored.
AI never writes to repositories. SOS never touches AI. If the model is missing or fails, the app must behave like the current deterministic build.

> **Status (latest update):** all ☁ code paths are implemented and `flutter analyze` / `flutter test` are clean (114 tests). All 📱 items are code-complete but **unverified on device** — spikes S1–S6 have not been run and `docs/SPIKE_RESULTS.md` is empty. Do not demo any number until it is recorded there.

---

## 0. Amendments to existing docs (do these first, 15 min)

| File | Old statement | Replace with |
|---|---|---|
| `ARCHITECTURE.md` Key Design Decision 3 | "AI is optional: Deterministic template fallback for all summaries" | "Local AI handles capture, narration and query. Deterministic code is the source of truth, the validator and the fallback." |
| `AI_AGENT_INSTRUCTIONS.md` (B) | "Care Brief and Handover use deterministic templates, not AI" | "Brief/Handover facts are deterministic. Prose may be AI-narrated only through `NarrationVerifier`; template is the fallback." |
| `DEVELOPER_B_TASKS.md` ownership | `lib/services/ai/` owned by B | Moves to **C**. B keeps the B17 interface file contents; C extends. |
| `DEVELOPER_A_TASKS.md` | — | A adds schema in §A below |

---

## 1. Spikes — run BEFORE building (each ≤ 1 hour, on the demo phone) 📱

Record results in `docs/SPIKE_RESULTS.md` (pass/fail + numbers). **Do not claim any number in the demo that isn't in this file.**

| # | Question | Test | Pass criterion | If it fails |
|---|---|---|---|---|
| **S1** | Does Gemma 4 E2B understand spoken Taglish? | 10 scripted sentences (med + BP + symptom) × 2 speakers, via the plugin's example app | ≥ 8/10 get correct drug + both BP digits; transcript quote is substring-accurate | Try E4B (Path C); else sherpa-onnx Whisper + Gemma text (Path B) |
| **S2** | Is tool-call JSON reliable? | 30 prompts through `extractFromText` with the §6.3 prompt | ≥ 90% schema-valid, 0 invented numbers | Tighten prompt, add 1 retry, add few-shot |
| **S3** | Can it read a pill bottle / BP monitor LCD? | 10 photos (3 bottles, 3 printed reseta, 4 monitors) | ≥ 7/10 correct on name + strength / digits; unreadable → blank, not guessed | Cut Snap to Monitor-only or drop |
| **S4** | RAM, speed, heat | 5 consecutive voice runs + 1 narration + 1 photo; read RAM and wall time | No OOM / kill; 10 s clip → cards ≤ 15 s; record cold-load time and actual model file size | Lower tier; smaller model; E2B text-only |
| **S5** | Is own-UID traffic counter usable? | Kotlin `TrafficStats.getUidTxBytes/RxBytes(myUid)` before/after an AI run, airplane mode off then on | Counter changes when we send a request and stays flat during inference | Drop byte counter; keep network-state indicator |
| **S6** | Can a model be installed without internet? | `adb push` model, load through plugin, `demo` flavor with no INTERNET permission | Model loads and runs | Keep INTERNET in demo build; pre-install over Wi-Fi |

**Gate:** if S1 and S4 both fail, stop and tell the team. P0 cannot ship as designed; fall back to "Basic mode + typed-text extraction + AI narration only."

---

## 2. Tasks

### Phase C0 — Foundations (Hours 0–3)

#### C1 Engine interface + fakes ☁
**Files:** `lib/services/ai/local/local_ai_engine.dart`, `engines/scripted_engine.dart`, `engines/null_engine.dart`
- [x] Implement `LocalAiEngine` exactly as in spec §6.2
- [x] `ScriptedEngine`: returns canned `ProposalEmitted` sequences keyed by input text/fixture id (tests only; never selectable in release)
- [x] `NullEngine`: tier `basic`, all AI methods throw `AiUnavailable`
- [x] Riverpod: `localAiEngineProvider`, `aiTierProvider`
**Accept:** unit tests pass with Scripted and Null; app compiles with only these engines.

#### C2 Proposal models + validators ☁
**Files:** `proposals/proposal_models.dart`, `proposal_validator.dart`, `med_matcher.dart`, `time_resolver.dart`
- [x] Sealed `ProposedRecord` types (spec §6.2)
- [x] `ProposalValidator` calls A's existing validators (BP 50–300, temp 30–45, pulse 20–300, …); out-of-range → flag `check`, **no correction**
- [x] `MedMatcher`: normalize + trigram/Levenshtein vs **active** schedules; exact → `sure`, ≥ 0.8 → `check`, else unmatched
- [x] `TimeResolver`: Filipino/English phrases ("kanina", "kaninang umaga", "kagabi", "8am", "yesterday evening") against `now` + timezone; future time for "taken" → reject
- [x] Quote grounding: `source_quote` must be a substring of the transcript, else drop
**Accept:** table-driven tests, ≥ 40 cases including Taglish phrases and bad values. All ☁.

#### C3 Basic-mode text extractor ☁
**File:** `proposals/basic_text_extractor.dart`
- [x] Deterministic regex/lexicon parser for typed text: BP `\d{2,3}\s*(/|over)\s*\d{2,3}`, glucose, temp, known med names, "uminom/nainom/binigyan/skip"
- [x] Emits the same `ProposedRecord`s → same Review tray
**Accept:** works with no model installed; it's the permanent fallback.

---

### Phase C1 — Review tray & staging (Hours 3–7)

#### A-request: schema ☁
- [x] `ai_captures`, `ai_proposals` tables (spec §6.7); migration; repository + providers
- [x] `source_type` += `ai_assisted` on measurements; `status_source` on occurrences; `app_settings` keys
- [x] Notify C + B to rerun `build_runner`

#### C4 Proposal repository + confirm use case ☁
**Files:** `proposals/proposal_repository.dart`, `lib/features/capture/application/confirm_proposals.dart`
- [x] `confirmAll(captureId)` writes real records via A's repositories in **one transaction**; idempotent
- [x] Sets `source=ai_assisted`, `review_status=confirmed`, links to capture id
- [x] Discard/edit statuses persist
**Accept:** confirming twice creates no duplicates; discarded proposals never reach real tables.

#### C5 Review tray UI ☁
**Files:** `lib/features/capture/presentation/review_tray_screen.dart`, `widgets/proposal_card.dart`
- [x] Heard-text header, card per proposal, **Sure/Check** badge, quote line, Edit/✕, "Kumpirmahin lahat"
- [x] **Edit** opens A's existing form pre-filled (route + extra args; no new form code) — all proposal kinds wired; saved edits mark the proposal `edited`, med taken/skipped stays pending so confirmAll can still mark the new schedule's occurrence
- [x] Rejected values show reason and can't be confirmed until edited — Check badge + confirm gate refuses to write out-of-range/unsupported proposals; they stay pending for edit/discard (audit fix F2/F4/F22)
- [x] Pending-proposals strip pinned at top of Ngayon — `PendingProposalsStrip` watches `watchPendingProposals` and opens the tray per pending capture
- [x] Semantics labels, ≥ 48 dp targets, icon + text (not color-only)
**Accept:** widget tests with `ScriptedEngine` fixtures — `test/features/capture/review_flow_test.dart` covers confirm/discard on a real in-memory DB; golden screenshots not done.

---

### Phase C2 — Voice capture (Hours 7–12)

#### C6 Model manager + device probe 📱/☁
**Files:** `model/device_probe.dart`, `model/model_manager.dart`, `lib/features/ai_setup/…`
- [x] Probe RAM/ABI/SDK → `AiTier` via Kotlin `device` channel — **thresholds are placeholders pending S4** (documented in code)
- [x] Resumable download, optional SHA-256 checksum, free-space check, delete, status stream
- [x] Settings → "Phone helper" (`/ai-setup`) — onboarding step not added (onboarding is B's flow; revisit)
- [x] Show the real file size from the server/file, not a hardcoded number (HEAD request → `sizeBytes`)
**Accept:** skip → Basic mode works (NullEngine stays active); mid-download resume + delete fallback written, 📱 untested.

#### C7 Gemma engine 📱
**File:** `engines/gemma_litert_engine.dart`
- [x] Wrap `flutter_gemma` + `flutter_gemma_litertlm` (pinned 1.11.x / 1.8.x); minSdk gate via `DeviceProbe.tierFor` (SDK < 30 → basic)
- [x] Lazy `ensureLoaded()`, serialized inferences, engine errors → `ExtractionFailed` → caller falls back to Basic
- [x] `extractFromAudio`, `extractFromText`, `extractFromImage`, `narrate`, `ask` implemented — **📱 unverified against real model**
- [ ] Parse function calls → drop malformed; retry policy needs device validation
- [ ] If S1 selected Path B: `sherpa_onnx` ASR adapter feeding `extractFromText`
**Accept:** S1–S4 results recorded — **not yet run.**

#### C8 Voice capture UI 📱
**Files:** `capture/voice_capture_service.dart`, `lib/features/capture/presentation/voice_capture_screen.dart`, capture sheet
- [x] Tap-to-record (not hold-to-talk yet), 16 kHz mono WAV via `record`, **hard stop at 30 s** auto-submits — countdown ring + seconds-left shown while recording (service `onHardStop` drives the stop)
- [x] Mic permission flow; denial/error → typed text path stays available
- [x] States: listening → thinking → cards — transcript deltas stream live into the "Processing…" view
- [x] Audio deleted after extraction — "Keep recordings" toggle in Phone helper settings (`ai_keep_recordings`); default off = delete
**Accept:** end-to-end on device in airplane mode — **not yet run.**

---

### Phase C3 — Narration & proof (Hours 12–16)

#### C9 Narrator + verifier ☁ (logic) / 📱 (real model)
**Files:** `narration/narrator.dart`, `narration/narration_verifier.dart`
- [x] `FactSet` builder over existing brief/handover queries (every fact has id + entities)
- [x] Prompt per spec §6.4 with `[r:ID]` markers; audiences Sibling/Helper/Doctor; languages Filipino/Taglish/English
- [x] Verifier: IDs exist, entities ⊆ cited facts, advice guard, drop/disclose, >40% dropped → template fallback with `GenerationStatus.fallback`
- [x] Implement as `CareSummaryService` (B17) so existing handover screen works unchanged
**Accept:** ☁ tests with 20 adversarial outputs (invented BP, wrong time, "inumin mo 2 tablets") → all removed or fallback. 📱 real narration passes verifier ≥ 80% of runs.

#### C10 Proof panel + ✈ badge 📱
**Files:** `proof/traffic_proof_channel.dart`, Kotlin `MainActivity` channel, `lib/features/settings/…/ai_privacy_panel.dart`
- [x] App-bar badge: "On-device" + airplane/offline state (connectivity read, no network calls)
- [x] Panel: model, runtime, tier, real UID tx/rx byte counters via `TrafficProofChannel` (Kotlin `traffic` channel implemented; accuracy **pending S5** — panel shows "Not measurable" off-platform, never a fabricated number)
- [~] `demo` flavor without INTERNET — added (`flutter build apk --release --flavor demo`; merged manifest verified INTERNET-free). Still needs S6 on-device run to confirm the model loads via `adb push`
**Accept:** badge flips with airplane mode; byte counter never fabricated.

---

### Phase C4 — P1 (Hours 16–21)

#### C11 Snap capture 📱
- [x] `snap_service.dart` camera/gallery (`image_picker`); intents Reseta/Label/Monitor in `snap_capture_screen.dart` (`/capture/snap`)
- [x] `extractFromImage` → `ProposedMedSchedule` / `ProposedMeasurement` wired to review tray — 📱 unreadable-field behavior depends on the real model
- [~] Unreadable fields blank + flagged — enforced by `ProposalValidator` (quote grounding drops unverifiable text); model-side blanking needs S3
- [x] Image discarded after use unless "Attach photo" toggled

#### C12 Ask the record ☁ (tools) / 📱 (model)
- [x] `ask_tools.dart` read-only wrappers
- [x] `ask_agent.dart`: max 3 tool rounds, 20 s timeout, same verifier, fixed refusal for advice questions
- [x] UI with suggestion chips and source chips

#### C13 Nav shell + Filipino labels (B) ☁
- [x] Bottom nav: Ngayon · Ulat · 🎙 · Tanong · Higit pa; SOS stays in app bar
- [x] `ui_language` setting (EN / Fil) for new strings only

---

### Phase C5 — Hardening & demo (Hours 21–24)

#### C14 Tests ☁
- [x] Full-flow widget test: review → confirm → records persisted (`review_flow_test.dart`, in-memory Drift DB); capture-screen pump with `ScriptedEngine` covered (`voice_capture_screen_test.dart` — also caught the Process button never re-enabling after typing)
- [x] Verifier adversarial suite (`narration_verifier_test.dart`: invented IDs, >40% dropped, advice phrasings, engine-error fallback); MedMatcher/TimeResolver/validator tables exist (~15 cases, target ≥ 40); confirm idempotency + discard + provenance (`confirm_proposals_test.dart`)
- [x] Offline/Basic-mode tests: `ask_agent_test.dart` covers NullEngine deterministic answers, engine timeout, refusal; `basic_text_extractor_test.dart` covers model-free extraction

#### C15 Demo data & rehearsal 📱
- [ ] Extend B22 seed with the demo sentence set from S1
- [ ] Record a labelled backup screen capture
- [ ] Run the §10 demo script 3× on the demo phone; log failures

---

## 3. Ownership

```
C owns:  lib/services/ai/**, lib/features/capture/, lib/features/ask/, lib/features/ai_setup/
A owns:  schema additions, android/ (Kotlin channel — C writes, A reviews), repositories
B owns:  nav shell, home timeline re-skin, handover/brief screens (chips), theme, seed data
Shared:  router.dart (add routes only), pubspec.yaml (flutter_gemma, sherpa_onnx if Path B, record, image_picker/camera)
```

## 4. Definition of done (P0)

- [ ] Airplane mode ON → speak the demo sentence → 3 correct cards → confirm → records exist with `ai_assisted`
- [ ] Handover generated in Filipino for "Kapatid abroad", verifier passes, tappable sources
- [ ] Delete model → app still fully usable in Basic mode with a visible banner
- [ ] SOS works in airplane mode, unchanged
- [ ] `docs/SPIKE_RESULTS.md` filled in; every number shown in the demo is in it
- [x] `flutter analyze` and `flutter test` clean — 219 tests, 0 analyzer issues (post-audit)
