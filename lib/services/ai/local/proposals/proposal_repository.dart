import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import 'proposal_models.dart';

/// Entities for the AI capture/proposal staging area.
class AiCaptureEntity {
  final String id;
  final String careRecipientId;
  final String modality; // voice, snap, text
  final String originalText;
  final String engineId;
  final String modelId;
  final int latencyMs;
  final DateTime createdAt;

  const AiCaptureEntity({
    required this.id,
    required this.careRecipientId,
    required this.modality,
    required this.originalText,
    required this.engineId,
    required this.modelId,
    required this.latencyMs,
    required this.createdAt,
  });
}

class AiProposalEntity {
  final String id;
  final String captureId;
  final String kind;
  final String payloadJson;
  final String? sourceQuote;
  final String? flag; // sure, check
  final String status; // pending, confirmed, discarded
  final DateTime createdAt;

  const AiProposalEntity({
    required this.id,
    required this.captureId,
    required this.kind,
    required this.payloadJson,
    this.sourceQuote,
    this.flag,
    required this.status,
    required this.createdAt,
  });
}

/// Repository for AI captures and proposals (staging area).
class AiCaptureRepository {
  final AppDatabase _db;
  const AiCaptureRepository(this._db);

  Future<String> createCapture({
    required String careRecipientId,
    required String modality,
    required String originalText,
    required String engineId,
    required String modelId,
    required int latencyMs,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    await _db.into(_db.aiCaptures).insert(AiCapturesCompanion.insert(
      id: id,
      careRecipientId: careRecipientId,
      modality: modality,
      originalText: originalText,
      engineId: engineId,
      modelId: modelId,
      latencyMs: latencyMs,
      createdAt: now,
    ));
    return id;
  }

  Future<String> createProposal({
    required String captureId,
    required ProposedRecord record,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    await _db.into(_db.aiProposals).insert(AiProposalsCompanion.insert(
      id: id,
      captureId: captureId,
      kind: _kindFromRecord(record),
      payloadJson: jsonEncode(_payloadFromRecord(record)),
      sourceQuote: Value(record.sourceQuote),
      flag: Value(record.flag.name),
      status: 'pending',
      createdAt: now,
    ));
    return id;
  }

  Future<List<AiProposalEntity>> getPendingProposals(String captureId) async {
    final query = _db.select(_db.aiProposals)
      ..where((t) => t.captureId.equals(captureId) & t.status.equals('pending'));
    final rows = await query.get();
    return rows.map(_rowToProposalEntity).toList();
  }

  Future<List<AiProposalEntity>> getAllProposalsForCapture(String captureId) async {
    final query = _db.select(_db.aiProposals)
      ..where((t) => t.captureId.equals(captureId));
    final rows = await query.get();
    return rows.map(_rowToProposalEntity).toList();
  }

  Future<void> updateProposalStatus(String proposalId, String status) async {
    await (_db.update(_db.aiProposals)
          ..where((t) => t.id.equals(proposalId)))
        .write(AiProposalsCompanion(status: Value(status)));
  }

  Future<void> confirmProposal(String proposalId) =>
      updateProposalStatus(proposalId, 'confirmed');

  Future<void> discardProposal(String proposalId) =>
      updateProposalStatus(proposalId, 'discarded');

  // Helpers
  String _kindFromRecord(ProposedRecord record) {
    if (record is ProposedMedicationTaken) return 'medication_taken';
    if (record is ProposedMedicationSkipped) return 'medication_skipped';
    if (record is ProposedMeasurement) return 'measurement';
    if (record is ProposedCareNote) return 'care_note';
    if (record is ProposedAppointment) return 'appointment';
    if (record is ProposedMedicationSchedule) return 'medication_schedule';
    return 'unknown';
  }

  Map<String, dynamic> _payloadFromRecord(ProposedRecord record) {
    if (record is ProposedMedicationTaken) {
      return {
        'medicationName': record.medicationName,
        'timePhrase': record.timePhrase,
      };
    }
    if (record is ProposedMedicationSkipped) {
      return {
        'medicationName': record.medicationName,
        'reasonText': record.reasonText,
      };
    }
    if (record is ProposedMeasurement) {
      return {
        'type': record.type,
        'value1': record.value1,
        'value2': record.value2,
        'unit': record.unit,
        'timePhrase': record.timePhrase,
      };
    }
    if (record is ProposedCareNote) {
      return {
        'text': record.text,
        'timePhrase': record.timePhrase,
      };
    }
    if (record is ProposedAppointment) {
      return {
        'provider': record.provider,
        'purpose': record.purpose,
        'datetimePhrase': record.datetimePhrase,
      };
    }
    if (record is ProposedMedicationSchedule) {
      return {
        'name': record.name,
        'strength': record.strength,
        'instructionText': record.instructionText,
        'timesHhmm': record.timesHhmm,
      };
    }
    return {};
  }

  AiProposalEntity _rowToProposalEntity(AiProposal row) {
    return AiProposalEntity(
      id: row.id,
      captureId: row.captureId,
      kind: row.kind,
      payloadJson: row.payloadJson,
      sourceQuote: row.sourceQuote,
      flag: row.flag,
      status: row.status,
      createdAt: row.createdAt,
    );
  }
}
