# AILaga — Architecture Overview

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.47.5 / Dart 3.13.4 |
| State Management | Riverpod (flutter_riverpod) |
| Navigation | GoRouter |
| Database | SQLite via Drift |
| Local Notifications | flutter_local_notifications |
| Secure Storage | flutter_secure_storage (Android Keystore) |
| PDF | pdf + printing |
| Sharing | share_plus |
| Communication | url_launcher |
| Sensors | sensors_plus |
| Permissions | permission_handler |
| Platform Code | Kotlin (selective — platform channels only) |

## Architecture Pattern

Feature-oriented layered architecture:

```
┌─────────────────────────────────────────────────┐
│                  Presentation                    │
│  Screens • Widgets • Form Validation • UI State  │
├─────────────────────────────────────────────────┤
│                  Application                     │
│  Use Cases • Workflow Orchestration • Providers   │
├─────────────────────────────────────────────────┤
│                    Domain                        │
│  Entities • Enums • Validation • Repo Contracts  │
├─────────────────────────────────────────────────┤
│                     Data                         │
│  Drift DB • Repo Implementations • Adapters      │
├─────────────────────────────────────────────────┤
│                   Services                       │
│  AI • Health Connect • PDF • Notifications        │
└─────────────────────────────────────────────────┘
```

## Project Structure

```
lib/
  main.dart
  app/
    app.dart                    # MaterialApp.router
    router.dart                 # GoRouter configuration
    theme.dart                  # App theme

  core/
    database/
      app_database.dart         # Drift database + all tables
      app_database.g.dart       # Generated
      migrations.dart           # Schema migrations
      database_provider.dart    # Riverpod provider
    errors/
      app_exception.dart
      error_handler.dart
    security/
      secure_storage_service.dart
    notifications/
      notification_service.dart
      notification_provider.dart
    utilities/
      date_utils.dart
      validators.dart
      uuid_generator.dart

  features/
    home/                       # Dashboard
    onboarding/                 # First launch
    care_recipient/             # Profile management
    medications/                # Schedules + occurrences
    measurements/               # Manual + imported readings
    appointments/               # Appointments
    care_notes/                 # Observations
    family_contacts/            # Contact management
    emergency/                  # SOS workflow
    care_brief/                 # Daily summary
    handover/                   # Caregiver handover
    reports/                    # PDF generation
    settings/                   # App settings

  services/
    ai/                         # AI summarization interface
    health_connect/             # Android Health Connect (P1)
    pdf/                        # PDF document builder
```

Each feature follows:
```
feature_name/
  domain/
    *_entity.dart               # Data model
    *_repository.dart           # Abstract repository interface
  data/
    *_repository_impl.dart      # Drift-backed implementation
    *_providers.dart            # Riverpod providers
  presentation/
    *_screen.dart               # Screen widget
    widgets/                    # Feature-specific widgets
```

## Database

- SQLite with Drift ORM
- Foreign keys enforced via PRAGMA
- UTC timestamps stored, local timezone for display
- Versioned schema migrations
- All records reference care_recipient_id

## Key Design Decisions

1. **Offline-first**: No network dependency for any P0 feature
2. **No accounts**: Local data only, no auth in MVP
3. **Local AI handles capture, narration and query**: Deterministic code is the source of truth, the validator and the fallback
4. **Emergency independence**: SOS works without AI, network, or wearable
5. **Idempotent occurrences**: Medication occurrence generation is safe to re-run
6. **Source tracking**: Every record tracks its origin (manual, AI, imported)
