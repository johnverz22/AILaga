# AILaga — Integration Guide for Parallel Development

## Overview

Two developers work independently on separate branches and integrate at defined checkpoints.

```
main
  ├── dev-a/foundation    (Developer A: data layer, CRUD, emergency, notifications)
  └── dev-b/experience    (Developer B: dashboard, summaries, reports, onboarding)
```

## Branch Strategy

```bash
# Developer A
git checkout -b dev-a/foundation main

# Developer B
git checkout -b dev-b/experience main

# Integration (at each checkpoint)
git checkout main
git merge dev-a/foundation
git merge dev-b/experience   # resolve conflicts here
```

## Shared Contracts (Do Not Break)

### 1. Database Schema
**Owner:** Developer A
**File:** `lib/core/database/app_database.dart`

Developer B must NOT modify table definitions. If B needs a schema change, B requests it from A. A implements and notifies B.

### 2. Repository Interfaces
**Owner:** Developer A
**Files:** `lib/features/*/domain/*_repository.dart`

B codes against the abstract interface. If A hasn't implemented a repository yet, B creates a mock:

```dart
// In B's code only — temporary mock
class MockMedicationRepository implements MedicationRepository {
  @override
  Future<List<MedicationScheduleEntity>> getActiveSchedules(String recipientId) async {
    return [
      MedicationScheduleEntity(
        id: 'mock-1',
        careRecipientId: recipientId,
        medicationName: 'Metformin 500mg',
        scheduleTimes: '["08:00","20:00"]',
        startDate: DateTime.now(),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
  // ... other methods throw UnimplementedError()
}
```

### 3. Provider Names
Both developers MUST use these exact provider names:

```dart
// Database
final appDatabaseProvider = ...

// Repositories (Developer A creates these)
final careRecipientRepositoryProvider = ...
final medicationRepositoryProvider = ...
final measurementRepositoryProvider = ...
final appointmentRepositoryProvider = ...
final careNoteRepositoryProvider = ...
final familyContactRepositoryProvider = ...
final emergencyRepositoryProvider = ...

// Computed/Streaming (Developer A creates these)
final primaryCareRecipientProvider = ...
final todayMedicationOccurrencesProvider = ...
final recentMeasurementsProvider = ...
final upcomingAppointmentsProvider = ...

// Services (Developer B creates these)
final careBriefServiceProvider = ...
final handoverServiceProvider = ...
final reportServiceProvider = ...
final careSummaryServiceProvider = ...
final notificationServiceProvider = ... // A creates, B uses
```

### 4. Entity Classes
**Owner:** Developer A
**Files:** `lib/features/*/domain/*_entity.dart`

B must use A's entity classes exactly. Do not create parallel data models.

### 5. Navigation Routes
**Shared File:** `lib/app/router.dart`

Routes are pre-defined in the scaffold. Both developers add their screen widgets to the existing route paths. Neither should change route paths without coordination.

## Integration Checkpoints

### Checkpoint 1: Hour 4 (Data Foundation)
**A delivers:** Database working, care_recipient + family_contact repositories, providers
**B delivers:** Theme, navigation shell, onboarding screen (can use mock repos)
**Integration:** B switches from mocks to A's real providers
**Test:** Onboarding creates a real care recipient that persists

### Checkpoint 2: Hour 10 (Core Records)
**A delivers:** All remaining repositories (medications, measurements, appointments, care notes)
**B delivers:** Home dashboard with sections (using A's providers)
**Integration:** Dashboard shows real data from A's repositories
**Test:** Add medication + measurement → visible on dashboard

### Checkpoint 3: Hour 15 (Emergency + Briefs)
**A delivers:** Emergency SOS, notification service
**B delivers:** Care brief, handover screens with deterministic service
**Integration:** SOS button on dashboard links to A's emergency screen. Brief queries A's repos.
**Test:** Full care flow from adding data → viewing brief → triggering SOS

### Checkpoint 4: Hour 20 (Reports + Polish)
**A delivers:** Unit tests, all repos finalized
**B delivers:** PDF reports, settings, accessibility, AI service interface
**Integration:** Full app integration
**Test:** End-to-end demo scenario

### Checkpoint 5: Hour 24 (Final)
**Both:** Bug fixes, demo prep
**Test:** All P0 acceptance criteria

## Conflict Resolution

### Files likely to conflict:
| File | Resolution |
|------|-----------|
| `lib/main.dart` | B owns initialization order; A adds providers |
| `lib/app/router.dart` | Pre-defined routes — both just fill in widgets |
| `pubspec.yaml` | Merge both dependency lists |

### Merge order:
1. A merges to main first (data layer is foundational)
2. B rebases onto updated main
3. B resolves any conflicts (usually just import additions)

## Communication Protocol

When using agentic IDEs (Cursor, Windsurf, Antigravity, etc.):

1. **Give each IDE the full spec** — their respective DEVELOPER_A_TASKS.md or DEVELOPER_B_TASKS.md
2. **Also give both the ARCHITECTURE.md** for shared context
3. **Set working branch** before starting each IDE
4. **At checkpoints:** manually merge and verify, then continue

### Messages to send between devs:
- "Schema change: added index on X" → B needs to re-run build_runner
- "Provider X is ready" → B can swap mock for real
- "I need method Y on Repository Z" → A adds to interface
- "Route X screen is done" → Integration checkpoint

## Quick Start Commands

```bash
# Get dependencies
flutter pub get

# Generate Drift code
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze
```
