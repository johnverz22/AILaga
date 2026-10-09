# AILaga — Agent Rules

Flutter app (Flutter 3.47 / Dart 3.13), Riverpod + GoRouter + Drift (SQLite). Offline-first, no accounts.

## Read first
- `docs/ARCHITECTURE.md` — stack, structure, design decisions
- `docs/AI_AGENT_INSTRUCTIONS.md` — per-track rules and conventions
- Task list for your track: `docs/DEVELOPER_A_TASKS.md` / `DEVELOPER_B_TASKS.md` / `DEVELOPER_C_AI_TASKS.md`
- `docs/LOCAL_AI_UX_SPEC.md` — AI layer spec (§6 = technical design)
- `docs/UI_PROMPT.md` — UI design system (colors, sizes, Elder/Helper modes, microcopy)

## Commands
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after changing Drift tables
flutter analyze                                            # must be clean (0 issues)
flutter test                                               # must pass
```
Generated files (`*.g.dart`) are produced by build_runner — never edit by hand.

## Ownership (don't edit outside your lane)
- **A**: `lib/core/`, `lib/features/{care_recipient,medications,measurements,appointments,care_notes,family_contacts,emergency}/` domain+data, repositories, android/ Kotlin review
- **B**: nav shell, `home/`, `onboarding/`, `care_brief/`, `handover/`, `reports/`, `settings/` (non-AI), theme, seed data
- **C**: `lib/services/ai/**`, `lib/features/{capture,ask,ai_setup}/`
- **Shared**: `lib/app/router.dart` (add routes only), `pubspec.yaml`

## Core safety rules (never break)
- AI proposes → deterministic code validates → caregiver confirms → provenance stored. **AI never writes to repositories.**
- SOS must work with no AI, no network, no model. Never route SOS through AI.
- If the model is missing/fails, the app behaves like the deterministic build (Basic mode).
- Validation rejects bad values — never silently "fix" them. Out-of-range → flag `check`.
- `source_quote` must be a substring of the transcript, else drop the proposal.
- Never claim a number (latency, accuracy, model size) that isn't in `docs/SPIKE_RESULTS.md`.
- Never claim calls/SMS were delivered — only that the dialer was opened.

## UI rules (from docs/UI_PROMPT.md)
- Palette: bg `#FFFDF8`, card `#F3EFE6`, border `#D9D2C3`, text `#1A1A1A`, teal `#0B6B6B`, helper indigo `#2F4B8A`, SOS `#C62828`, sure `#1B7F3B`, check `#9A5B00`, error `#B3261E`.
- Elder mode: body 24sp, titles 32sp bold, buttons 88dp; max 3 items on screen; tap-to-talk.
- Helper mode: body 20sp, buttons 64dp; indigo "Helper mode" band with "Done".
- ≥48dp touch targets, icon + word (never icon or color alone), 24dp radius, 2dp card borders, no soft shadows.
- No jargon: never show "AI", "model", "proposal", "tier", "sync" — say "Phone helper".
- Buttons 1–2 words, no sentence over 5 words.

## Conventions
- Providers: `{feature}RepositoryProvider`, `{feature}ListProvider` (StreamProvider), `{feature}DetailProvider` (FutureProvider.family).
- Files: `{feature}_entity.dart`, `{feature}_repository.dart`, `{feature}_repository_impl.dart`, `{feature}_providers.dart`, `{feature}_screen.dart`.
- Relative imports within a feature; package imports cross-feature. From `lib/a/b/c/d.dart`, `lib/` root is `../../../../`.
- Repositories throw `AppException` subclasses; UI shows friendly messages.
- UTC in DB, local time in UI; `intl` for formatting.
