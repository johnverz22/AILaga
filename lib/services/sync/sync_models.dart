/// Sync operation models shared between the interface and implementation.
/// Direction of a sync operation.
enum SyncDirection { upload, download, bidirectional }

/// Current state of the sync service, suitable for driving UI indicators.
enum SyncStatus {
  /// No sync in progress and none has run yet (or sync is disabled).
  idle,

  /// A sync operation is actively running.
  syncing,

  /// The most recent sync completed successfully.
  success,

  /// The most recent sync failed.
  error,

  /// Sync is disabled because the user is not signed in.
  disabled,
}

/// Result of a completed sync operation.
class SyncResult {
  /// The final status of this sync run.
  final SyncStatus status;

  /// Number of local records successfully uploaded to Supabase.
  final int recordsUploaded;

  /// Number of remote records downloaded and applied to the local DB.
  final int recordsDownloaded;

  /// Human-readable error message when [status] is [SyncStatus.error].
  final String? errorMessage;

  /// UTC timestamp when this sync run finished.
  final DateTime syncedAt;

  const SyncResult({
    required this.status,
    required this.recordsUploaded,
    required this.recordsDownloaded,
    this.errorMessage,
    required this.syncedAt,
  });

  /// Convenience factory for a clean success result.
  factory SyncResult.success({
    required int uploaded,
    required int downloaded,
  }) =>
      SyncResult(
        status: SyncStatus.success,
        recordsUploaded: uploaded,
        recordsDownloaded: downloaded,
        syncedAt: DateTime.now().toUtc(),
      );

  /// Convenience factory for a failed result.
  factory SyncResult.failure(String message) => SyncResult(
        status: SyncStatus.error,
        recordsUploaded: 0,
        recordsDownloaded: 0,
        errorMessage: message,
        syncedAt: DateTime.now().toUtc(),
      );

  /// Convenience factory when sync is skipped (user not signed in).
  factory SyncResult.disabled() => SyncResult(
        status: SyncStatus.disabled,
        recordsUploaded: 0,
        recordsDownloaded: 0,
        syncedAt: DateTime.now().toUtc(),
      );

  @override
  String toString() =>
      'SyncResult(${status.name}, ↑$recordsUploaded ↓$recordsDownloaded'
      '${errorMessage != null ? ', error=$errorMessage' : ''})';
}
