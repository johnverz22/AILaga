import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/database/app_database.dart';
import '../../services/auth/auth_constants.dart';
import 'sync_models.dart';
import 'sync_service.dart';

// ---------------------------------------------------------------------------
// SECURITY REVIEW NOTES for supabase_sync_service.dart
//
// 1. AUTHENTICATED CALLS ONLY:
//    Every Supabase query in this file is preceded by _attachFirebaseToken(),
//    which fetches the current Firebase ID token and injects it as the
//    Authorization: Bearer header. Unauthenticated Supabase calls are
//    rejected by RLS policies — no user data is accessible without a valid
//    Firebase JWT.
//
// 2. NO HEALTH DATA IN FIREBASE:
//    This service reads from the local Drift DB and writes to Supabase only.
//    FirebaseAuth.instance is accessed here solely to obtain the ID token
//    (a signed JWT). No health data fields are passed to any Firebase API.
//
// 3. UID NEVER LOGGED:
//    All debugPrint calls in this file use [redacted] or omit the UID.
//    The firebase_uid column is written to Supabase rows but is never
//    echoed to the console, crash reporters, or analytics.
//    debugPrint is a no-op in release builds (kReleaseMode).
//
// 4. SUPABASE ANON KEY:
//    The anon key in AuthConstants is publishable — see auth_constants.dart
//    for the full security rationale. RLS enforces row-owner isolation.
//
// 5. SYNC FAILURE ISOLATION:
//    Sync errors never crash or block local features. All exceptions are
//    caught, logged at debug level, and surfaced to the user only when
//    they explicitly triggered the sync (not for background syncs).
// ---------------------------------------------------------------------------
const _tCareRecipients = 'care_recipients';
const _tFamilyContacts = 'family_contacts';
const _tMedSchedules = 'medication_schedules';
const _tMedOccurrences = 'medication_occurrences';
const _tMeasurements = 'measurement_logs';
const _tAppointments = 'appointments';
const _tCareNotes = 'care_notes';

/// The ordered list used by [syncAll] and [downloadAll].
///
/// Order matters: care_recipients must be upserted before tables that
/// reference it via FK. medication_schedules before medication_occurrences.
const _syncOrder = [
  _tCareRecipients,
  _tFamilyContacts,
  _tMedSchedules,
  _tMedOccurrences,
  _tMeasurements,
  _tAppointments,
  _tCareNotes,
];

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

/// Supabase-backed implementation of [SyncService].
///
/// Design decisions:
///   • All Supabase calls are fire-and-forget from the app's perspective —
///     they fail gracefully and never block local features.
///   • The Firebase ID token is fetched fresh before each sync so JWTs
///     that have expired (>1 h) are automatically refreshed.
///   • Rows are read directly from AppDatabase (not via repositories) for
///     bulk reads because repositories are recipient-scoped and lack a
///     simple "get all" path.
///   • DateTime → ISO 8601 UTC strings are used for all timestamps; Supabase
///     stores them as TIMESTAMPTZ and returns them as ISO strings on download.
///   • Conflict resolution: last-write-wins by updated_at. For
///     MedicationOccurrences (no updated_at), local status is always kept.
class SupabaseSyncService implements SyncService {
  SupabaseSyncService({
    required AppDatabase db,
    FlutterSecureStorage? secureStorage,
    SupabaseClient? supabaseClient,
  })  : _db = db,
        _storage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            ),
        _client = supabaseClient ?? Supabase.instance.client;

  final AppDatabase _db;
  final FlutterSecureStorage _storage;
  final SupabaseClient _client;

  final _statusController = StreamController<SyncStatus>.broadcast();

  SyncStatus _currentStatus = SyncStatus.disabled; // ignore: unused_field

  // ---------------------------------------------------------------------------
  // Interface: statusStream
  // ---------------------------------------------------------------------------

  @override
  Stream<SyncStatus> get statusStream => _statusController.stream;

  void _setStatus(SyncStatus s) {
    _currentStatus = s;
    _statusController.add(s);
  }

  // ---------------------------------------------------------------------------
  // Interface: syncAll
  // ---------------------------------------------------------------------------

  @override
  Future<SyncResult> syncAll(String firebaseUid) async {
    if (firebaseUid.isEmpty) return SyncResult.disabled();

    _setStatus(SyncStatus.syncing);
    int uploaded = 0;

    try {
      await _attachFirebaseToken();

      for (final table in _syncOrder) {
        final rows = await _localRowsForTable(table, firebaseUid);
        uploaded += rows.length;
        await _upsertToSupabase(table, rows);
      }

      await _saveLastSyncTime(DateTime.now().toUtc());
      _setStatus(SyncStatus.success);
      debugPrint(
          '[D] SyncService: syncAll complete — $uploaded records uploaded');
      return SyncResult.success(uploaded: uploaded, downloaded: 0);
    } catch (e) {
      _setStatus(SyncStatus.error);
      debugPrint('[D] SyncService: syncAll failed — $e');
      return SyncResult.failure('Sync failed. Check your connection.');
    }
  }

  // ---------------------------------------------------------------------------
  // Interface: syncTable (incremental, called after individual writes)
  // ---------------------------------------------------------------------------

  @override
  Future<void> syncTable(String tableName, String firebaseUid) async {
    if (firebaseUid.isEmpty) return;
    if (!_syncOrder.contains(tableName)) {
      debugPrint(
          '[D] SyncService: syncTable called with unknown table: $tableName');
      return;
    }
    try {
      await _attachFirebaseToken();
      final rows = await _localRowsForTable(tableName, firebaseUid);
      await _upsertToSupabase(tableName, rows);
      await _saveLastSyncTime(DateTime.now().toUtc());
    } catch (e) {
      // Incremental sync failures are silent — local feature already succeeded.
      debugPrint('[D] SyncService: syncTable($tableName) failed — $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Interface: downloadAll
  // ---------------------------------------------------------------------------

  @override
  Future<SyncResult> downloadAll(String firebaseUid) async {
    if (firebaseUid.isEmpty) return SyncResult.disabled();

    _setStatus(SyncStatus.syncing);
    int downloaded = 0;

    try {
      await _attachFirebaseToken();

      for (final table in _syncOrder) {
        final remoteRows =
            await _client.from(table).select().eq('firebase_uid', firebaseUid);
        downloaded += remoteRows.length;
        await _applyRemoteRows(table, remoteRows);
      }

      await _saveLastSyncTime(DateTime.now().toUtc());
      _setStatus(SyncStatus.success);
      debugPrint('[D] SyncService: downloadAll complete — $downloaded records');
      return SyncResult.success(uploaded: 0, downloaded: downloaded);
    } catch (e) {
      _setStatus(SyncStatus.error);
      debugPrint('[D] SyncService: downloadAll failed — $e');
      return SyncResult.failure('Download failed. Check your connection.');
    }
  }

  // ---------------------------------------------------------------------------
  // Interface: getLastSyncTime
  // ---------------------------------------------------------------------------

  @override
  Future<DateTime?> getLastSyncTime() async {
    try {
      final raw = await _storage.read(key: AuthConstants.secureKeyLastSyncAt);
      if (raw == null) return null;
      return DateTime.tryParse(raw);
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Interface: deleteCloudData
  // ---------------------------------------------------------------------------

  @override
  Future<void> deleteCloudData(String firebaseUid) async {
    if (firebaseUid.isEmpty) return;
    try {
      await _attachFirebaseToken();
      // Delete in reverse FK order so cascades don't cause FK violations on
      // individual deletes. Supabase cascades handle child rows automatically
      // once the parent is deleted, but deleting children first is safer.
      for (final table in _syncOrder.reversed) {
        await _client.from(table).delete().eq('firebase_uid', firebaseUid);
      }
      // Clear the last sync timestamp since cloud data is gone.
      await _storage.delete(key: AuthConstants.secureKeyLastSyncAt);
      _setStatus(SyncStatus.idle);
      debugPrint(
          '[D] SyncService: deleteCloudData complete for UID [redacted]');
    } catch (e) {
      debugPrint('[D] SyncService: deleteCloudData failed — $e');
      rethrow; // This is user-initiated — surface the failure.
    }
  }

  // ---------------------------------------------------------------------------
  // Firebase JWT attachment
  //
  // Supabase accepts Firebase JWTs as the Authorization: Bearer token when
  // Firebase is configured as a Third Party Auth provider in the Supabase
  // dashboard (Authentication → Third Party Auth, Project ID: ailaga-d77b8).
  //
  // supabase_flutter ≥2.0 exposes Supabase.instance.client.auth.setSession()
  // but since we use Firebase (not Supabase) Auth, we inject the token via
  // the postgrest headers instead — a supported pattern for third-party JWTs.
  // ---------------------------------------------------------------------------

  Future<void> _attachFirebaseToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Cannot sync: no Firebase user signed in.');
    }
    // forceRefresh: false — uses the cached token unless it expires within 5 min.
    final token = await user.getIdToken();
    // Supabase postgrest client allows injecting custom auth headers.
    _client.rest.headers['Authorization'] = 'Bearer $token';
  }

  // ---------------------------------------------------------------------------
  // Supabase upsert helper
  // ---------------------------------------------------------------------------

  Future<void> _upsertToSupabase(
    String tableName,
    List<Map<String, dynamic>> rows,
  ) async {
    if (rows.isEmpty) return;
    await _client.from(tableName).upsert(rows);
  }

  // ---------------------------------------------------------------------------
  // Local → Supabase: row serialisation per table
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> _localRowsForTable(
    String tableName,
    String firebaseUid,
  ) async {
    switch (tableName) {
      case _tCareRecipients:
        return _serializeCareRecipients(firebaseUid);
      case _tFamilyContacts:
        return _serializeFamilyContacts(firebaseUid);
      case _tMedSchedules:
        return _serializeMedSchedules(firebaseUid);
      case _tMedOccurrences:
        return _serializeMedOccurrences(firebaseUid);
      case _tMeasurements:
        return _serializeMeasurements(firebaseUid);
      case _tAppointments:
        return _serializeAppointments(firebaseUid);
      case _tCareNotes:
        return _serializeCareNotes(firebaseUid);
      default:
        return [];
    }
  }

  Future<List<Map<String, dynamic>>> _serializeCareRecipients(
      String uid) async {
    final rows = await _db.select(_db.careRecipients).get();
    return rows
        .map((r) => {
              'id': r.id,
              'firebase_uid': uid,
              'display_name': r.displayName,
              'date_of_birth': r.dateOfBirth?.toUtc().toIso8601String(),
              'allergies': r.allergies,
              'important_notes': r.importantNotes,
              'emergency_info': r.emergencyInfo,
              'created_at': r.createdAt.toUtc().toIso8601String(),
              'updated_at': r.updatedAt.toUtc().toIso8601String(),
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> _serializeFamilyContacts(
      String uid) async {
    final rows = await _db.select(_db.familyContacts).get();
    return rows
        .map((r) => {
              'id': r.id,
              'firebase_uid': uid,
              'care_recipient_id': r.careRecipientId,
              'display_name': r.displayName,
              'relationship': r.relationship,
              'phone_number': r.phoneNumber,
              'is_emergency_contact': r.isEmergencyContact,
              'sort_order': r.sortOrder,
              'created_at': r.createdAt.toUtc().toIso8601String(),
              'updated_at': r.updatedAt.toUtc().toIso8601String(),
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> _serializeMedSchedules(String uid) async {
    final rows = await _db.select(_db.medicationSchedules).get();
    return rows
        .map((r) => {
              'id': r.id,
              'firebase_uid': uid,
              'care_recipient_id': r.careRecipientId,
              'medication_name': r.medicationName,
              'prescribed_instructions': r.prescribedInstructions,
              'schedule_times': r.scheduleTimes,
              'start_date': r.startDate.toUtc().toIso8601String(),
              'end_date': r.endDate?.toUtc().toIso8601String(),
              'notes': r.notes,
              'is_active': r.isActive,
              'created_at': r.createdAt.toUtc().toIso8601String(),
              'updated_at': r.updatedAt.toUtc().toIso8601String(),
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> _serializeMedOccurrences(
      String uid) async {
    final rows = await _db.select(_db.medicationOccurrences).get();
    return rows
        .map((r) => {
              'id': r.id,
              'firebase_uid': uid,
              'medication_schedule_id': r.medicationScheduleId,
              'scheduled_at': r.scheduledAt.toUtc().toIso8601String(),
              'status': r.status,
              'status_updated_at': r.statusUpdatedAt?.toUtc().toIso8601String(),
              // statusSource was added in schema v2; map it through if present.
              'status_source': r.statusSource,
              'status_note': r.statusNote,
              'recorded_by_label': r.recordedByLabel,
              'created_at': r.createdAt.toUtc().toIso8601String(),
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> _serializeMeasurements(String uid) async {
    final rows = await _db.select(_db.measurementLogs).get();
    return rows
        .map((r) => {
              'id': r.id,
              'firebase_uid': uid,
              'care_recipient_id': r.careRecipientId,
              'measurement_type': r.measurementType,
              'value1': r.value1,
              'value2': r.value2,
              'unit': r.unit,
              'measured_at': r.measuredAt.toUtc().toIso8601String(),
              'recorded_at': r.recordedAt.toUtc().toIso8601String(),
              'source_type': r.sourceType,
              'source_label': r.sourceLabel,
              'notes': r.notes,
              'created_at': r.createdAt.toUtc().toIso8601String(),
              'updated_at': r.updatedAt.toUtc().toIso8601String(),
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> _serializeAppointments(String uid) async {
    final rows = await _db.select(_db.appointments).get();
    return rows
        .map((r) => {
              'id': r.id,
              'firebase_uid': uid,
              'care_recipient_id': r.careRecipientId,
              'provider_or_facility': r.providerOrFacility,
              'purpose': r.purpose,
              'scheduled_at': r.scheduledAt.toUtc().toIso8601String(),
              'notes': r.notes,
              'status': r.status,
              'created_at': r.createdAt.toUtc().toIso8601String(),
              'updated_at': r.updatedAt.toUtc().toIso8601String(),
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> _serializeCareNotes(String uid) async {
    final rows = await _db.select(_db.careNotes).get();
    return rows
        .map((r) => {
              'id': r.id,
              'firebase_uid': uid,
              'care_recipient_id': r.careRecipientId,
              'observed_at': r.observedAt.toUtc().toIso8601String(),
              'recorded_at': r.recordedAt.toUtc().toIso8601String(),
              'original_text': r.originalText,
              'structured_summary': r.structuredSummary,
              'source_type': r.sourceType,
              'review_status': r.reviewStatus,
              'created_at': r.createdAt.toUtc().toIso8601String(),
              'updated_at': r.updatedAt.toUtc().toIso8601String(),
            })
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Supabase → Local: apply downloaded rows (conflict resolution)
  // ---------------------------------------------------------------------------

  Future<void> _applyRemoteRows(
    String tableName,
    List<Map<String, dynamic>> rows,
  ) async {
    if (rows.isEmpty) return;
    switch (tableName) {
      case _tCareRecipients:
        await _applyCareRecipients(rows);
      case _tFamilyContacts:
        await _applyFamilyContacts(rows);
      case _tMedSchedules:
        await _applyMedSchedules(rows);
      case _tMedOccurrences:
        await _applyMedOccurrences(rows);
      case _tMeasurements:
        await _applyMeasurements(rows);
      case _tAppointments:
        await _applyAppointments(rows);
      case _tCareNotes:
        await _applyCareNotes(rows);
    }
  }

  // ------------------------------------------------------------------
  // Helpers: parse ISO string → DateTime UTC, safe nullable version
  // ------------------------------------------------------------------

  static DateTime _dt(String iso) => DateTime.parse(iso).toUtc();
  static DateTime? _dtN(String? iso) =>
      iso == null ? null : DateTime.parse(iso).toUtc();

  // ------------------------------------------------------------------
  // Apply helpers: last-write-wins by updated_at
  //
  // Pattern: read local row, compare updated_at. If remote is newer (or
  // local doesn't exist), upsert remote into local Drift DB.
  // ------------------------------------------------------------------

  Future<void> _applyCareRecipients(List<Map<String, dynamic>> rows) async {
    for (final r in rows) {
      final remoteUpdated = _dt(r['updated_at'] as String);
      final local = await (_db.select(_db.careRecipients)
            ..where((t) => t.id.equals(r['id'] as String)))
          .getSingleOrNull();

      if (local == null || local.updatedAt.isBefore(remoteUpdated)) {
        await _db.into(_db.careRecipients).insertOnConflictUpdate(
              CareRecipientsCompanion.insert(
                id: r['id'] as String,
                displayName: r['display_name'] as String,
                dateOfBirth: drift.Value(_dtN(r['date_of_birth'] as String?)),
                allergies: drift.Value(r['allergies'] as String?),
                importantNotes: drift.Value(r['important_notes'] as String?),
                emergencyInfo: drift.Value(r['emergency_info'] as String?),
                createdAt: _dt(r['created_at'] as String),
                updatedAt: remoteUpdated,
              ),
            );
      }
    }
  }

  Future<void> _applyFamilyContacts(List<Map<String, dynamic>> rows) async {
    for (final r in rows) {
      final remoteUpdated = _dt(r['updated_at'] as String);
      final local = await (_db.select(_db.familyContacts)
            ..where((t) => t.id.equals(r['id'] as String)))
          .getSingleOrNull();

      if (local == null || local.updatedAt.isBefore(remoteUpdated)) {
        await _db.into(_db.familyContacts).insertOnConflictUpdate(
              FamilyContactsCompanion.insert(
                id: r['id'] as String,
                careRecipientId: r['care_recipient_id'] as String,
                displayName: r['display_name'] as String,
                relationship: drift.Value(r['relationship'] as String?),
                phoneNumber: r['phone_number'] as String,
                isEmergencyContact:
                    drift.Value(r['is_emergency_contact'] as bool? ?? false),
                sortOrder: drift.Value(r['sort_order'] as int? ?? 0),
                createdAt: _dt(r['created_at'] as String),
                updatedAt: remoteUpdated,
              ),
            );
      }
    }
  }

  Future<void> _applyMedSchedules(List<Map<String, dynamic>> rows) async {
    for (final r in rows) {
      final remoteUpdated = _dt(r['updated_at'] as String);
      final local = await (_db.select(_db.medicationSchedules)
            ..where((t) => t.id.equals(r['id'] as String)))
          .getSingleOrNull();

      if (local == null || local.updatedAt.isBefore(remoteUpdated)) {
        await _db.into(_db.medicationSchedules).insertOnConflictUpdate(
              MedicationSchedulesCompanion.insert(
                id: r['id'] as String,
                careRecipientId: r['care_recipient_id'] as String,
                medicationName: r['medication_name'] as String,
                prescribedInstructions:
                    drift.Value(r['prescribed_instructions'] as String?),
                scheduleTimes: r['schedule_times'] as String,
                startDate: _dt(r['start_date'] as String),
                endDate: drift.Value(_dtN(r['end_date'] as String?)),
                notes: drift.Value(r['notes'] as String?),
                isActive: drift.Value(r['is_active'] as bool? ?? true),
                createdAt: _dt(r['created_at'] as String),
                updatedAt: remoteUpdated,
              ),
            );
      }
    }
  }

  Future<void> _applyMedOccurrences(List<Map<String, dynamic>> rows) async {
    // CONFLICT RULE: Local occurrence status is ALWAYS authoritative.
    // If the local row exists, keep it — never overwrite caregiver confirmations.
    // Only insert if the row is genuinely new locally.
    for (final r in rows) {
      final local = await (_db.select(_db.medicationOccurrences)
            ..where((t) => t.id.equals(r['id'] as String)))
          .getSingleOrNull();

      if (local != null) continue; // Local data wins — never overwrite.

      await _db.into(_db.medicationOccurrences).insertOnConflictUpdate(
            MedicationOccurrencesCompanion.insert(
              id: r['id'] as String,
              medicationScheduleId: r['medication_schedule_id'] as String,
              scheduledAt: _dt(r['scheduled_at'] as String),
              status: drift.Value(r['status'] as String? ?? 'pending'),
              statusUpdatedAt:
                  drift.Value(_dtN(r['status_updated_at'] as String?)),
              statusSource:
                  drift.Value(r['status_source'] as String? ?? 'manual'),
              statusNote: drift.Value(r['status_note'] as String?),
              recordedByLabel: drift.Value(r['recorded_by_label'] as String?),
              createdAt: _dt(r['created_at'] as String),
            ),
          );
    }
  }

  Future<void> _applyMeasurements(List<Map<String, dynamic>> rows) async {
    for (final r in rows) {
      final remoteUpdated = _dt(r['updated_at'] as String);
      final local = await (_db.select(_db.measurementLogs)
            ..where((t) => t.id.equals(r['id'] as String)))
          .getSingleOrNull();

      if (local == null || local.updatedAt.isBefore(remoteUpdated)) {
        await _db.into(_db.measurementLogs).insertOnConflictUpdate(
              MeasurementLogsCompanion.insert(
                id: r['id'] as String,
                careRecipientId: r['care_recipient_id'] as String,
                measurementType: r['measurement_type'] as String,
                value1: (r['value1'] as num).toDouble(),
                value2: drift.Value((r['value2'] as num?)?.toDouble()),
                unit: r['unit'] as String,
                measuredAt: _dt(r['measured_at'] as String),
                recordedAt: _dt(r['recorded_at'] as String),
                sourceType:
                    drift.Value(r['source_type'] as String? ?? 'manual'),
                sourceLabel: drift.Value(r['source_label'] as String?),
                notes: drift.Value(r['notes'] as String?),
                createdAt: _dt(r['created_at'] as String),
                updatedAt: remoteUpdated,
              ),
            );
      }
    }
  }

  Future<void> _applyAppointments(List<Map<String, dynamic>> rows) async {
    for (final r in rows) {
      final remoteUpdated = _dt(r['updated_at'] as String);
      final local = await (_db.select(_db.appointments)
            ..where((t) => t.id.equals(r['id'] as String)))
          .getSingleOrNull();

      if (local == null || local.updatedAt.isBefore(remoteUpdated)) {
        await _db.into(_db.appointments).insertOnConflictUpdate(
              AppointmentsCompanion.insert(
                id: r['id'] as String,
                careRecipientId: r['care_recipient_id'] as String,
                providerOrFacility:
                    drift.Value(r['provider_or_facility'] as String?),
                purpose: drift.Value(r['purpose'] as String?),
                scheduledAt: _dt(r['scheduled_at'] as String),
                notes: drift.Value(r['notes'] as String?),
                status: drift.Value(r['status'] as String? ?? 'scheduled'),
                createdAt: _dt(r['created_at'] as String),
                updatedAt: remoteUpdated,
              ),
            );
      }
    }
  }

  Future<void> _applyCareNotes(List<Map<String, dynamic>> rows) async {
    for (final r in rows) {
      final remoteUpdated = _dt(r['updated_at'] as String);
      final local = await (_db.select(_db.careNotes)
            ..where((t) => t.id.equals(r['id'] as String)))
          .getSingleOrNull();

      if (local == null || local.updatedAt.isBefore(remoteUpdated)) {
        await _db.into(_db.careNotes).insertOnConflictUpdate(
              CareNotesCompanion.insert(
                id: r['id'] as String,
                careRecipientId: r['care_recipient_id'] as String,
                observedAt: _dt(r['observed_at'] as String),
                recordedAt: _dt(r['recorded_at'] as String),
                originalText: r['original_text'] as String,
                structuredSummary:
                    drift.Value(r['structured_summary'] as String?),
                sourceType:
                    drift.Value(r['source_type'] as String? ?? 'manual'),
                reviewStatus:
                    drift.Value(r['review_status'] as String? ?? 'unreviewed'),
                createdAt: _dt(r['created_at'] as String),
                updatedAt: remoteUpdated,
              ),
            );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Secure storage for last sync timestamp
  // ---------------------------------------------------------------------------

  Future<void> _saveLastSyncTime(DateTime utc) async {
    try {
      await _storage.write(
        key: AuthConstants.secureKeyLastSyncAt,
        value: utc.toIso8601String(),
      );
    } catch (e) {
      debugPrint('[D] SyncService: could not persist last sync time: $e');
    }
  }
}
