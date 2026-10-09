import 'package:drift/drift.dart';

import 'app_database.dart';

/// Migration strategy for [AppDatabase].
///
/// Kept in its own file so upgrade logic stays reviewable as the schema
/// version grows. Bump `schemaVersion` in app_database.dart and add a
/// matching `from < N` step here — never edit shipped schema silently.
///
/// History:
///  - v1 → v2: `medication_occurrences.status_source` column;
///    `ai_captures` + `ai_proposals` tables (AI staging, Developer C).
MigrationStrategy appMigrationStrategy(AppDatabase db) {
  return MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      // Indexes for common lookups (performance).
      await db.customStatement(
        'CREATE INDEX IF NOT EXISTS idx_med_occ_scheduled_at '
        'ON medication_occurrences (scheduled_at)',
      );
      await db.customStatement(
        'CREATE INDEX IF NOT EXISTS idx_med_occ_schedule_id '
        'ON medication_occurrences (medication_schedule_id)',
      );
      await db.customStatement(
        'CREATE INDEX IF NOT EXISTS idx_measurement_measured_at '
        'ON measurement_logs (measured_at)',
      );
      await db.customStatement(
        'CREATE INDEX IF NOT EXISTS idx_appointments_scheduled_at '
        'ON appointments (scheduled_at)',
      );
      await db.customStatement(
        'CREATE INDEX IF NOT EXISTS idx_care_notes_observed_at '
        'ON care_notes (observed_at)',
      );
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(
            db.medicationOccurrences, db.medicationOccurrences.statusSource);
        await m.createTable(db.aiCaptures);
        await m.createTable(db.aiProposals);
      }
    },
    beforeOpen: (details) async {
      // Enforce foreign key constraints.
      await db.customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
