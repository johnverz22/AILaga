import 'sync_models.dart';

/// Abstract interface for cloud sync between the local Drift DB and Supabase.
///
/// Contract:
///   - Sync is always optional and additive. Local features work without it.
///   - Sync only runs when the user is signed in (firebase_uid is non-null).
///   - The local Drift database is the source of truth. Supabase mirrors it.
///   - Sync failures are logged but never propagate to local UI as a crash.
///   - Conflict resolution: last-write-wins by updated_at, EXCEPT for
///     MedicationOccurrence status, where local is always authoritative.
abstract class SyncService {
  /// Broadcast stream of [SyncStatus] — drives UI indicators in real time.
  ///
  /// Always starts with the most recent status so new listeners get
  /// an immediate value.
  Stream<SyncStatus> get statusStream;

  /// Upload all local records to Supabase (all 7 tables, sequentially).
  ///
  /// [firebaseUid] is the row-owner key stamped on every upserted row.
  /// Returns a [SyncResult] describing what was uploaded/error.
  Future<SyncResult> syncAll(String firebaseUid);

  /// Incremental upload for a single table after a local write.
  ///
  /// [tableName] must be one of the 7 sync-able table names.
  /// Silently no-ops when [firebaseUid] is empty.
  Future<void> syncTable(String tableName, String firebaseUid);

  /// Download all remote rows for [firebaseUid] and apply them to the local
  /// Drift DB (upsert — insert or replace on PK conflict).
  ///
  /// Used to restore data on a new device after sign-in.
  Future<SyncResult> downloadAll(String firebaseUid);

  /// The UTC timestamp of the last successful sync, or `null` if none.
  Future<DateTime?> getLastSyncTime();

  /// Delete all remote rows belonging to [firebaseUid] across all 7 tables.
  ///
  /// Does NOT touch the local Drift database.
  /// Used by the "Delete Cloud Data" feature in Settings.
  Future<void> deleteCloudData(String firebaseUid);
}
