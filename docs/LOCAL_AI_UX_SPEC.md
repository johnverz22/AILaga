# AILaga v2 — Local AI Layer & UX Redesign

> **AILaga = AI + *alaga* (to care for).**
> Spec date: 2026-10-09. Written against `ARCHITECTURE.md`, `DEVELOPER_A_TASKS.md`, `DEVELOPER_B_TASKS.md`, `AI_AGENT_INSTRUCTIONS.md`, `INTEGRATION_GUIDE.md`.
> I only had the docs, not the `lib/` source. File paths below follow your `ARCHITECTURE.md`. Anything marked **UNVERIFIED** was not confirmed by a source this session and must be tested on the demo phone.

---

## 0. Diagnosis (read this first)

**As specified, AILaga contains no AI.** The evidence is in your own docs:

| Doc | What it says |
|---|---|
| `ARCHITECTURE.md` | "AI is optional: Deterministic template fallback for all summaries" |
| `AI_AGENT_INSTRUCTIONS.md` | "Care Brief and Handover use deterministic templates, not AI" |
| `DEVELOPER_B_TASKS.md` B17 | "AI implementation stub (P1, with TODO)" |
| `DEVELOPER_B_TASKS.md` B18 | AI section is "(P1)" and only shows "availability status" |

The hackathon scores **25% Local AI Implementation** ("local inference is fundamental") and part of the 15% Innovation on the AI itself. The brief also says to reject thin wrappers and trivial models. A medication tracker, SOS screen and PDF export are solid engineering, but a judge opening the app will see a well-built reminder app with the word "AI" in the name. **That is the problem this spec fixes.**

The good news: your design already left the hooks. `care_notes` has `source_type (manual | ai_assisted)`, a review status, an immutable original text and a nullable AI "structured summary"; every record tracks its origin; `CareSummaryService.structureCareNote()` and `GenerationStatus.fallback` exist. The safety rules are the right ones. We keep all of them and put real AI *inside* them.

### The one-line concept

> **"Sabihin mo lang. Kami na ang magtatala."** — Just tell it (or snap it). AILaga files it, you confirm, and it tells the family. All on the phone, even in airplane mode.

### The core design rule

> **AI proposes → deterministic code validates → the caregiver confirms → provenance is stored.**

AI is the *input* layer (voice, camera), the *language* layer (handovers in Filipino/Taglish/English) and the *query* layer (ask the record). It is **never** the source of truth, never the safety path (SOS stays AI-free) and never gives medical advice. This is how we get real local AI without breaking "no fabrication."

---

## 1. Constraints extracted from the hackathon brief

| Constraint | Source | What it means for this spec |
|---|---|---|
| Theme: Local AI — meaningful AI computation on-device | Rules | Inference must be fundamental, not a wrapper |
| "Remains genuinely useful when the cloud disappears" | Core challenge | Airplane-mode demo is the centerpiece |
| Must be a **working** product | Deliverable | Every AI feature needs a deterministic fallback so the demo can't brick |
| Show why local beats cloud | Deliverable | Privacy proof panel + cost/connectivity story |
| Judging: 25 Problem · 25 Local AI · 20 Technical · 15 Innovation · 15 Demo | Criteria | Half the score is usefulness + how real the AI is |
| Area: Accessibility / Personal assistant / Productivity / Privacy | Areas | We fit Accessibility + Personal assistant + Privacy |
| 24-hour build | Constraints | Priority tiers P0/P1/P2 in §9; cut list in §12 |
| Build team: 2 devs (A, B) with agentic IDEs | Your docs | Add a third lane ("Developer C — Local AI") |
| Demo device: Android phone | Your stack (Flutter + Kotlin) | **Spike S4 decides the real RAM/model tier** |
| Audience: Philippines (accessibility), but "local" means on-device | Rules | Filipino/Taglish is a *feature*, not the theme |
| Build tooling: Devin multi-agent in a Linux cloud VM | Constraints | Every task flagged ☁ (VM-testable) or 📱 (needs real device) |
| Reject: generic chatbot, keyword filter, trivial model | Rules | Ask-the-record is *scoped & tool-grounded*, not a chatbot |
| Prefer a visual airplane-mode demo moment | Rules | ✈ badge + "0 bytes sent" panel |

---

## 2. Verified local-AI tooling (as of 2026-10-09)

| Need | Choice | Verified facts | Limits / UNVERIFIED |
|---|---|---|---|
| Runtime | **LiteRT-LM** via Flutter plugin **flutter_gemma** (aka `flutter_edge_ai` 2.0.0) | LiteRT-LM is Google's production orchestration layer for on-device LLMs; its docs point Flutter users to the community `flutter_gemma` package [1][2]. Plugin supports Android/iOS/desktop, `.litertlm` and `.task` formats, audio + image input, embeddings/RAG, function calling, and Genkit hybrid routing [2][3] | Community-maintained, not Google-official [1]. LiteRT needs **minSdk 30** per plugin docs [2] → check our `minSdkVersion`. Release builds need `INTERNET` permission [2] (see §6.6) |
| Main model | **Gemma 4 E2B** (fallback tier: E4B on high-RAM phones) | Text + image + **audio** input, native function calling, 128K context, Apache-2.0 [4][5][6]. Audio input capped at **30 seconds** [6]. 4-bit needs roughly 5 GB RAM (GGUF figure) [6][7] | Phone RAM and tok/s on *our* device: **UNVERIFIED** (Spike S4). Filipino is not confirmed to be in the "35+ out-of-box languages" list (pre-trained on 140+) [4]: **UNVERIFIED** (Spike S1) |
| Audio quality | One third-party MacBook benchmark found E4B far better than E2B at audio ASR and said E2B "chokes" on it [8] | Single non-peer-reviewed source | Treat as a **risk**, not a fact → Spike S1 decides path A/B/C (§6.2) |
| Speech fallback | **sherpa-onnx** (`sherpa_onnx` Dart pkg) | Offline ASR incl. Whisper models, VAD, language ID, Android + Dart support [9] | Whisper-tiny/base **Tagalog / Taglish code-switch accuracy: UNVERIFIED** |
| Reference sizes | LiteRT-LM table lists Gemma-3n-E2B ≈ 2.9 GB and E4B ≈ 4.2 GB on disk; desktop M3 CPU speeds 233/28 and 170/20 tok/s prefill/decode [1] | Older Gemma 3n numbers on a laptop | **Gemma 4 E2B on-disk size and phone speed: UNVERIFIED** |
| Platform-native AI | **Gemini Nano / ML Kit GenAI** (AICore) | Summarization, proofreading, rewriting, image description, speech recognition on-device; only on supported devices; advanced speech mode Pixel 10 only per one guide [10][11] | Not usable as our primary path on arbitrary PH phones. **Optional accelerator only** |
| Desktop prompt tuning in VM | LiteRT-LM runs on Linux desktop [1] | — | CPU speed in a cloud VM and Gemma 4 E2B model availability for CLI: **UNVERIFIED**. Plugin docs warn software GPU (llvmpipe) is not enough for Gemma 4 [2] |

**Decision:** one multimodal model (Gemma 4 E2B) for audio, vision, tool-calling and narration. One download, one runtime, one story. sherpa-onnx is the *contingency* for speech only.

---

## 3. The user and the problem

**Primary user: "Ana," 38.** Works full-time. Her mother, Lola Maria (81, diabetic, hypertensive), lives with her. A kasambahay (Ate Nena) is with Lola during the day; Ana's brother Jun is abroad and wants updates. Ana does not have time to open five forms. She talks while doing things, sends photos in the family chat, and writes in Taglish.

**Evidence the problem is real (Philippines):**
- Long-term care of older Filipinos falls mostly to family and kin [12]; the constitution frames elder care as a family duty [13].
- For dementia, one cohort study put the annual burden around ₱196,000 per patient, ~86% of it unpaid family caregiver time [14]. A 2024 scoping review found care cost is a major barrier and health financing leans on out-of-pocket payment [15].
- *Not proven by sources I found:* that voice/photo logging specifically reduces caregiver burden. That's our hypothesis; validate it in a 10-minute chat with a real caregiver before the demo.

**Why local is essential (the honest version, since cloud *can* technically do this):**
1. **Privacy:** it's health data on a vulnerable person, plus voice and photos of prescriptions. A family shouldn't have to upload that to an account just to log a pill.
2. **Connectivity:** brownouts, provincial signal, hospital basements. Logging and handover must work at 2 a.m. with no bars.
3. **Cost:** no per-call cloud bill, no subscription, no account. Matters for out-of-pocket households [15].
4. **Latency/reliability in a care moment:** it should respond the same whether the network is up or not.

---

## 4. UX redesign

### 4.1 Principles

1. **Capture beats forms.** The fastest path to a record is voice or camera, not a data-entry screen. Forms remain as the *edit* path.
2. **Nothing AI-made is saved without a human tap.** Review is fast (one-tap confirm-all), but it is always there.
3. **Show your work.** Every AI statement has a visible source (quote from speech, region of photo, or record link).
4. **Make "local" visible.** A persistent ✈ On-device badge and a proof panel.
5. **Degrade gracefully.** No model, low RAM or error → the app behaves exactly like today's deterministic version, with an honest banner.
6. **Bilingual by default.** Filipino / English UI labels; AI understands Taglish.
7. **Big, calm, one-handed.** Older and less tech-comfortable caregivers (Accessibility area).

### 4.2 New navigation (replaces Home / Meds / Measurements / Appointments / More)

```
┌───────────────────────────────────────────────┐
│ Lola Maria        ✈ On-device         🆘 SOS │  ← app bar (SOS unchanged, A-owned)
├───────────────────────────────────────────────┤
│                                               │
│   [ screen content ]                          │
│                                               │
├───────────────────────────────────────────────┤
│  Ngayon   Ulat     ( 🎙 )     Tanong   Higit │
│  Today    Brief   Capture     Ask      More  │
└───────────────────────────────────────────────┘
```

| Tab | Purpose | Built from |
|---|---|---|
| **Ngayon / Today** | One timeline of the day: meds, vitals, appointments, notes interleaved, plus a **Review tray** on top | B's dashboard sections re-skinned into a timeline |
| **Ulat / Brief** | Care brief, Smart Handover, Doctor Prep, PDF | B's care_brief + handover + reports |
| **🎙 Capture (center FAB)** | Sheet: **Sabihin** (voice) · **Kunan** (camera) · **I-type** (text) | **New** |
| **Tanong / Ask** | Ask the care record in plain language | **New** |
| **Higit pa / More** | Medications, Measurements, Appointments, Notes, Contacts, Settings, AI Privacy panel | A's existing screens, unchanged |

SOS stays in the app bar on every screen and **never touches AI**.

### 4.3 Screens

#### S-1 Capture sheet (center FAB)
Three large buttons, 56 dp+: 🎙 **Sabihin** · 📷 **Kunan** · ⌨ **I-type**. A hint line shows an example ("Halimbawa: *'Nainom na ni Lola ang Metformin, 130/85 ang BP.'*").

#### S-2 Voice capture
- **Hold-to-talk** (or tap-to-toggle in Accessibility setting), live waveform, ring countdown to the **30 s** audio cap [6]. If a clip hits 30 s it auto-chunks and continues (P1).
- States: *Nakikinig…* → *Iniintindi…* (thinking, shows streamed transcript) → proposal cards slide in one by one.
- Original audio is **not kept** by default (setting: "Keep recordings" off). The **transcript** is saved as the immutable original text.

#### S-3 Review tray (the trust moment)
Opens right after capture and lives atop **Ngayon** while anything is pending.

```
Narinig ko (I heard):
"Binigyan ko na si Lola ng Metformin kanina, 130 over 85 yung BP, medyo masakit daw ulo niya."

┌─ 💊 Metformin 500mg — Nainom, 8:05 PM   ─────────── ✓ Sure
│   "binigyan ko na … ng Metformin kanina"   [Edit] [✕]
├─ 🩺 BP 130/85 mmHg — 8:05 PM            ─────────── ✓ Sure
│   "130 over 85 yung BP"                    [Edit] [✕]
└─ 📝 Note: "medyo masakit daw ulo niya"   ─────────── ⚠ Check
    Saved word-for-word. Not diagnosed.      [Edit] [✕]

            [ ✓ Kumpirmahin lahat (3) ]      [ Itapon ]
```
- Each card shows the **verbatim quote** that produced it.
- Badges: **Sure** (validator passed, exact med match) vs **Check** (fuzzy match, ambiguous time, or out-of-range value).
- **Edit** opens A's existing add/edit form **pre-filled** (zero new form code).
- Rejected values (e.g. BP 1300/85) are **not corrected**; the card shows *"Hindi malinaw — pakitingnan"* and requires editing (inherits "no silent corrections").
- Confirm writes real records with `source = ai_assisted`, `review_status = confirmed`, and links back to the capture.

#### S-4 Snap capture (camera)
Mode chips: **Reseta/Label** · **Monitor** (BP/glucose/thermometer display) · **Papel** (lab result, P1).
- *Reseta/Label* → a **medication schedule proposal** (name, strength, instruction text, default times). If the frequency isn't legible, leave it **blank and flagged**; the model never guesses a dose.
- *Monitor* → a measurement proposal with the value shown on the screen.
- Same Review tray. The photo is discarded after confirm unless "Attach to record" is toggled.

#### S-5 Smart Handover (upgrade of B14)
Chips: **Para kanino?** `[Kapatid sa abroad] [Kasambahay] [Doktor]` · **Wika** `[Filipino] [Taglish] [English]` · **Haba** `[Maikli] [Detalyado]`.
- AI writes the message **from the structured facts** (same query B already builds) in the chosen voice. Kasambahay version = short, plain, action-first; Doktor version = clinical, with numbers; Sibling version = warm + highlights.
- Underlined phrases are tappable → opens the source record.
- Transparency chip: *"Tinanggal ang 1 pangungusap na hindi ma-verify"* when the verifier (§6.4) strips something.
- Deterministic template remains available via a **Template** toggle and is the automatic fallback.
- Still editable, shareable, copyable (B14 unchanged).

#### S-6 Ask the record (Tanong)
Scoped Q&A over *this* care recipient's data only.
- Suggestion chips: *"Nainom ba ang gamot ngayong umaga?"*, *"Ano ang BP ngayong linggo?"*, *"Ilang beses na-skip ang Metformin?"*
- Answer = 1–2 sentences + a small chart/number + **source chips**.
- Out-of-scope or medical-advice questions get a fixed refusal: *"Hindi ako puwedeng magbigay ng medical advice. Narito ang nasa record…"* followed by relevant data.
- It is an **agent over repositories**, not a chat model with opinions (§6.5).

#### S-7 Doctor Prep (P1, in Ulat)
Before an appointment: auto 1-pager of what changed since the last visit (BP range, adherence %, notes mentioning symptoms) as **descriptive facts**, plus "Mga itatanong" built *only* from the caregiver's own flagged notes. Exports through B's existing PDF generator.

#### S-8 AI Setup & Model Manager (new onboarding step + Settings > AI)
- Device check (RAM, ABI, SDK). Shows tier: **Full AI** / **Lite** / **Basic (no AI)**.
- "I-download ang AI ni Lola (~X GB, Wi-Fi)" with resumable progress, storage warning, and **Skip** (Basic mode). Size is shown from the actual file, not a guess.
- After install: *"Handa na. Gumagana kahit walang internet."*
- Settings: model name/version, storage used, **Delete model**, "AI mode: Auto / Always template."

#### S-9 Local AI Proof panel (More > Privacy, also tap the ✈ badge)
- Model name, runtime, "running on: this device."
- **"Data sent by AILaga since AI session start: 0 B"** read from Android traffic counters for the app's UID (platform channel, §6.6).
- Network state ("Airplane mode: ON").
- "Try it: turn on airplane mode, then record something."

### 4.4 What stays unchanged
SOS (A14/A15/A16), medication occurrence logic, notifications, validators, PDF accuracy rules, onboarding steps 1–6 (we insert one AI Setup step), all CRUD screens (now the *edit* path).

---

## 5. Trust & safety rules (extended)

Inherited and kept: no diagnosis · no medication recommendations · no invented data · source preservation · caregiver confirmation · no silent corrections · SOS independent of AI.

New, enforced in code (not just prompts):

1. **Propose-only tools.** The model can only call `propose_*` functions. It has no write access to repositories. Only the Review tray's *Confirm* writes.
2. **Schema-validated output.** Malformed/unknown tool calls are dropped and counted; after 2 retries fall back to saving the transcript as an unreviewed care note.
3. **Range validation via A's validators** (BP 50–300, temp 30–45 °C, etc.). Failures become **Check** cards, never auto-fixed.
4. **Quote grounding.** Each proposal must include a `source_quote` that is a **substring of the transcript**. No quote → no card.
5. **Medication matching is deterministic.** Names are matched to *active* schedules (normalized trigram/Levenshtein). Unmatched → "Hindi nakalista ang X. Idagdag?" It never creates a "taken" for a drug that isn't scheduled without the caregiver's explicit confirm.
6. **Time resolution is deterministic.** The model outputs the phrase ("kanina", "kaninang umaga"); `TimeResolver` converts it against `now`/timezone and rejects future times for "taken".
7. **Narration verifier** (§6.4): every number, time and drug name in generated text must exist in the source facts; unsupported sentences are removed and disclosed.
8. **Prompt-injection hygiene.** Text read from photos and transcripts is *data*; tool allowlist is fixed; model can't change settings.
9. **Advice guard.** A post-generation check blocks diagnostic/dosing-advice patterns in narrations and Ask answers. This is a *backstop only*; the primary control is that the model is given facts, not asked for opinions.
10. **Never present scripted output as live AI.** `ScriptedEngine` is for tests/CI. If the real model fails during a demo, show Basic mode with its banner. Do not fake it.

---

## 6. Technical design

### 6.1 Module layout (extends `ARCHITECTURE.md`)

```
lib/services/ai/                       # ownership moves B → C (B17 interface kept)
  care_summary_service.dart            # existing B17 interface (unchanged)
  deterministic_care_summary_service.dart
  local/
    local_ai_engine.dart               # engine interface
    engines/
      gemma_litert_engine.dart         # flutter_gemma wrapper      📱
      scripted_engine.dart             # fixtures for tests/CI      ☁
      null_engine.dart                 # "Basic mode"               ☁
    model/
      device_probe.dart                # RAM/ABI/SDK → tier         📱
      model_manager.dart               # download/verify/delete     📱
    capture/
      voice_capture_service.dart       # mic → WAV ≤30 s            📱
      snap_service.dart                # camera/gallery → image     📱
      extraction_context.dart          # active meds, now, tz
    proposals/
      proposal_models.dart             # sealed ProposedRecord
      proposal_validator.dart          # wraps A's validators       ☁
      med_matcher.dart                 #                            ☁
      time_resolver.dart               # Taglish time phrases       ☁
      proposal_repository.dart         # staging tables (A schema)  ☁
      basic_text_extractor.dart        # deterministic fallback     ☁
    narration/
      narrator.dart                    # facts → text
      narration_verifier.dart          # entity/source check        ☁
    ask/
      ask_agent.dart                   # tool-loop over repos
      ask_tools.dart                   #                            ☁
    proof/
      traffic_proof_channel.dart       # Kotlin MethodChannel       📱
lib/features/capture/                  # UI (C): sheet, voice, snap, review tray
lib/features/ask/                      # UI (C)
lib/features/ai_setup/                 # UI (C): model manager screens
```

### 6.2 Engine interface

```dart
enum AiTier { full, lite, basic }

abstract interface class LocalAiEngine {
  String get engineId;
  Future<AiTier> tier();
  Future<void> ensureLoaded();
  Future<void> unloadIfIdle(Duration idle);

  Stream<ExtractionEvent> extractFromAudio(AudioClip clip, ExtractionContext ctx);
  Stream<ExtractionEvent> extractFromText(String text, ExtractionContext ctx);
  Stream<ExtractionEvent> extractFromImage(ImageInput img, ImageIntent intent, ExtractionContext ctx);
  Future<String> narrate(NarrationRequest req);
  Stream<AskEvent> ask(AskRequest req, ToolExecutor tools);
}
```

### 6.3 Tool schema (what the model may call)

```jsonc
[
 {"name":"propose_medication_taken","parameters":{
    "medication_name":"string","time_phrase":"string|null","source_quote":"string"}},
 {"name":"propose_medication_skipped","parameters":{
    "medication_name":"string","reason_text":"string|null","source_quote":"string"}},
 {"name":"propose_measurement","parameters":{
    "type":"blood_pressure|pulse|temperature|weight|blood_glucose",
    "value1":"number","value2":"number|null","unit":"string",
    "time_phrase":"string|null","source_quote":"string"}},
 {"name":"propose_care_note","parameters":{
    "text":"string","time_phrase":"string|null","source_quote":"string"}},
 {"name":"propose_appointment","parameters":{
    "provider":"string|null","purpose":"string|null","datetime_phrase":"string","source_quote":"string"}},
 {"name":"propose_medication_schedule","parameters":{
    "name":"string","strength":"string|null","instruction_text":"string|null",
    "times_hhmm":"string[]|null","source_quote":"string"}}
]
```

### 6.4 Narration + verifier

1. Build `FactSet` from the same repository queries B already uses.
2. Prompt with `[r:ID]` markers.
3. `NarrationVerifier`: entity ⊆ cited facts, advice guard, >40% dropped → fallback.

### 6.5 Ask agent

- Tools (read-only): `get_medication_occurrences`, `get_measurements`, `get_care_notes`, `get_appointments`, `compute_adherence`.
- Max 3 tool rounds, 20 s timeout, same verifier.

### 6.6 Local proof, permissions, offline install

- Traffic proof via Kotlin `MethodChannel` calling Android `TrafficStats`.
- INTERNET permission for release builds (model download); `demo` flavor without INTERNET.

### 6.7 Data model additions

| Table / field | Purpose |
|---|---|
| `ai_captures` (id, care_recipient_id, modality, original_text, engine_id, model_id, latency_ms, created_at) | Immutable record of what was heard/read |
| `ai_proposals` (id, capture_id, kind, payload_json, source_quote, flag, status, created_at) | Staging area for the Review tray |
| `measurement_logs.source_type` += `ai_assisted` | Provenance |
| `medication_occurrences.status_source` | Provenance |
| `app_settings`: `ai_mode`, `model_id`, `keep_audio`, `ui_language` | Settings |

### 6.8 Performance targets

| Action | Target on demo phone |
|---|---|
| 10 s voice → cards visible | ≤ 15 s |
| Photo → proposal | ≤ 15 s |
| Handover narration (~120 words) | ≤ 20 s, streamed |
| Cold model load | ≤ 10 s |
| Basic mode (no AI) | Instant |

---

## 7–13 (see full spec)

Priority order: Voice → Review tray → proof badge → deterministic fallback → SOS (never cut).
