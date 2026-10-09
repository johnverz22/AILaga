# AILaga — AI Coding Agent Instructions

## For Developer A's Agent (Foundation & Safety)

When starting work, read these files first:
1. `docs/ARCHITECTURE.md` — understand the tech stack and patterns
2. `docs/DEVELOPER_A_TASKS.md` — your task list and ownership boundaries

### Key rules for your agent:
- **Start with database**: Run `dart run build_runner build --delete-conflicting-outputs` first
- **Test persistence**: After implementing any repository, verify data survives app restart
- **Idempotent occurrences**: The medication occurrence generator MUST be idempotent
- **Emergency safety**: Never claim calls/SMS were delivered — only that the system dialer/SMS was opened
- **No silent corrections**: Measurement validation rejects bad values, doesn't auto-fix them
- **Stay in your lane**: Don't modify files in Developer B's ownership (home/, onboarding/, care_brief/, handover/, reports/, settings/, services/ai/, services/pdf/)

### Your implementation order:
1. Database + code gen
2. Core utilities
3. Care recipient CRUD
4. Family contacts CRUD
5. Medications (schedules + occurrences)
6. Measurements
7. Appointments + Care notes
8. Emergency SOS
9. Notification service
10. Unit tests

### Run after each feature:
```bash
flutter analyze
flutter test
```

---

## For Developer B's Agent (Experience & Intelligence)

When starting work, read these files first:
1. `docs/ARCHITECTURE.md` — understand the tech stack and patterns
2. `docs/DEVELOPER_B_TASKS.md` — your task list and ownership boundaries

### Key rules for your agent:
- **Use A's providers**: Don't create duplicate database queries. Use the Riverpod providers from `*_providers.dart` files
- **If A's providers aren't ready**: Create mock providers with sample data in your own files, then swap later
- **Template-based summaries**: Brief/Handover facts are deterministic. Prose may be AI-narrated only through `NarrationVerifier`; template is the fallback
- **Source traceability**: Every statement in a brief/handover must reference a source record
- **No fabrication**: If data is missing, say "No data" — never generate fake values
- **PDF accuracy**: Every value in the PDF must match the source database record
- **Stay in your lane**: Don't modify files in Developer A's ownership (core/, care_recipient/data+domain, medications/, measurements/, appointments/, care_notes/, family_contacts/, emergency/)

### Your implementation order:
1. Theme polish
2. Router + navigation shell
3. Main entry point
4. Onboarding flow
5. Home dashboard + sections
6. Care Brief
7. Handover
8. PDF reports
9. AI service interface
10. Settings
11. Empty states + accessibility
12. Demo data

### Run after each feature:
```bash
flutter analyze
flutter test
```

---

## For Developer C's Agent (Local AI & Capture)

When starting work, read these files first:
1. `docs/LOCAL_AI_UX_SPEC.md` — design and safety rules (§6 = technical design)
2. `docs/DEVELOPER_C_AI_TASKS.md` — your task list and spike protocol
3. `docs/UI_PROMPT.md` — Elder/Helper mode design system and microcopy

### Key rules for your agent:
- **AI never writes to repositories**: AI emits `ProposedRecord`s → `ProposalValidator` → human confirm via `ConfirmProposalsUseCase` → provenance (`source=ai_assisted`).
- **Basic mode is a feature**: `NullEngine` + `BasicTextExtractor` must keep the whole app working when no model is installed or the engine fails.
- **No silent corrections**: out-of-range values get flag `check`, not a fix. `source_quote` not in transcript → drop.
- **SOS is untouchable**: never route emergency flows through AI.
- **Only real numbers**: latency/size/traffic figures in UI must come from measurements recorded in `docs/SPIKE_RESULTS.md`; never fabricate.
- **Stay in your lane**: C owns `lib/services/ai/**`, `lib/features/{capture,ask,ai_setup}/`. Shared: `router.dart` (add routes only), `pubspec.yaml`.

### Run after each feature:
```bash
flutter analyze
flutter test
```

---

## Shared Conventions

### Riverpod provider naming:
```dart
final {featureName}RepositoryProvider = Provider<{FeatureName}Repository>((ref) => ...);
final {featureName}ListProvider = StreamProvider<List<{Entity}>>((ref) => ...);
final {featureName}DetailProvider = FutureProvider.family<{Entity}?, String>((ref, id) => ...);
```

### File naming:
- Entities: `{feature}_entity.dart`
- Repositories: `{feature}_repository.dart` (interface), `{feature}_repository_impl.dart` (implementation)
- Providers: `{feature}_providers.dart`
- Screens: `{feature}_screen.dart`, `add_{feature}_screen.dart`, `edit_{feature}_screen.dart`

### Import conventions:
- Relative imports within a feature
- Package imports for cross-feature references

### Error handling:
- Repository methods throw `AppException` subclasses
- UI catches and displays user-friendly messages
- Never expose raw SQL errors to users

### Date handling:
- Store UTC in database
- Display local time to user
- Use `intl` package for formatting
