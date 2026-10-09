# AILaga — AI-Powered Family Caregiving Companion

> **Record care once. Understand what needs attention. Hand over care clearly.**

AILaga is a private, offline-first, AI-assisted caregiving companion that helps Filipino families organize daily care, remember scheduled tasks, respond to emergencies, and communicate accurately with other caregivers and healthcare professionals.

## Quick Start

```bash
# Get dependencies
flutter pub get

# Generate Drift database code
dart run build_runner build --delete-conflicting-outputs

# Run on a connected Android device
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze
```

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Framework | Flutter 3.47.5 / Dart 3.13.4 |
| State Management | Riverpod |
| Navigation | GoRouter |
| Database | SQLite via Drift |
| Notifications | flutter_local_notifications |
| PDF | pdf + printing |
| Platform Code | Kotlin (Android) |

## Architecture

Feature-oriented layered architecture. See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for details.

```
lib/
  app/          → App shell, routing, theme
  core/         → Database, notifications, utilities
  features/     → Feature modules (domain + data + presentation)
  services/     → AI, PDF, Health Connect
```

## Development

This project is designed for **parallel development by two developers**:

- **Developer A** (Foundation & Safety): Data layer, CRUD features, emergency SOS, notifications
  - [Task Spec →](docs/DEVELOPER_A_TASKS.md)
  
- **Developer B** (Experience & Intelligence): Dashboard, summaries, reports, onboarding, AI
  - [Task Spec →](docs/DEVELOPER_B_TASKS.md)

See [docs/INTEGRATION_GUIDE.md](docs/INTEGRATION_GUIDE.md) for the parallel development workflow.

## Features (MVP P0)

- ✅ Offline-first care records
- ✅ Medication schedules and reminders
- ✅ Measurement logging (BP, pulse, temp, weight, glucose)
- ✅ Appointments and care notes
- ✅ Emergency SOS with family contacts
- ✅ Daily Care Brief
- ✅ Caregiver handover
- ✅ Doctor-ready PDF reports
- ✅ Local notifications
- ✅ No account or internet required

## Safety

AILaga is **not** a diagnostic tool, medical device, or replacement for healthcare professionals. It does not:
- Diagnose conditions
- Recommend medication changes
- Detect medical emergencies from sensors
- Guarantee notification delivery
- Claim message/call delivery without verification

## License

Private — All rights reserved.
