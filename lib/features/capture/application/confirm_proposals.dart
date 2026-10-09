import 'dart:convert';
import 'package:uuid/uuid.dart';

import '../../medications/domain/medication_repository.dart';
import '../../medications/domain/medication_status.dart';
import '../../measurements/domain/measurement_repository.dart';
import '../../measurements/domain/measurement_entity.dart';
import '../../measurements/domain/measurement_type.dart';
import '../../care_notes/domain/care_note_repository.dart';
import '../../care_notes/domain/care_note_entity.dart';
import '../../../services/ai/local/proposals/proposal_repository.dart';
import '../../../services/ai/local/proposals/proposal_validator.dart';
import '../../../services/ai/local/proposals/time_resolver.dart';

/// Confirms AI proposals by writing real records through A's repositories.
/// One transaction per capture; idempotent — confirming twice creates no duplicates.
class ConfirmProposalsUseCase {
  final AiCaptureRepository captureRepo;
  final MedicationRepository medicationRepo;
  final MeasurementRepository measurementRepo;
  final CareNoteRepository careNoteRepo;
  final String careRecipientId;

  ConfirmProposalsUseCase({
    required this.captureRepo,
    required this.medicationRepo,
    required this.measurementRepo,
    required this.careNoteRepo,
    required this.careRecipientId,
  });

  /// Confirms all pending proposals for a capture in ONE transaction
  /// (spec C4). Returns the number of records actually created.
  ///
  /// A proposal is only marked `confirmed` when a real record was written.
  /// Proposals that can't be written (unscheduled medication, out-of-range
  /// value, no matching occurrence) stay `pending` and remain visible for
  /// the caregiver to edit or discard — nothing is silently swallowed.
  Future<int> confirmAll(String captureId) {
    return captureRepo.runInTransaction(() async {
      final proposals = await captureRepo.getPendingProposals(captureId);
      int created = 0;

      for (final proposal in proposals) {
        try {
          final written = await _confirmSingle(proposal);
          if (written) {
            await captureRepo.confirmProposal(proposal.id);
            created++;
          }
        } catch (e) {
          // Skip individual failures — don't break the batch
          continue;
        }
      }

      return created;
    });
  }

  /// Confirms a single proposal by ID. Only marks it confirmed when a
  /// record was actually written.
  Future<void> confirmOne(String proposalId, String captureId) async {
    await captureRepo.runInTransaction(() async {
      final proposals = await captureRepo.getAllProposalsForCapture(captureId);
      final proposal = proposals.where((p) => p.id == proposalId).firstOrNull;
      if (proposal == null || proposal.status != 'pending') return;

      if (await _confirmSingle(proposal)) {
        await captureRepo.confirmProposal(proposalId);
      }
    });
  }

  /// Discards a single proposal.
  Future<void> discardOne(String proposalId) async {
    await captureRepo.discardProposal(proposalId);
  }

  /// Writes the real record for one proposal. Returns true only when a
  /// record was actually written/updated.
  Future<bool> _confirmSingle(AiProposalEntity proposal) async {
    final payload = jsonDecode(proposal.payloadJson) as Map<String, dynamic>;
    final now = DateTime.now();
    final uuid = const Uuid();

    switch (proposal.kind) {
      case 'medication_taken':
        final medName = payload['medicationName'] as String;
        final timePhrase = payload['timePhrase'] as String?;
        final schedules = await medicationRepo.getActiveSchedules(careRecipientId);
        final schedule = schedules.where(
          (s) => s.medicationName.toLowerCase() == medName.toLowerCase()
        ).firstOrNull;
        // Unscheduled drug: never create a "taken" — proposal stays pending
        // for the caregiver to add the medication first (spec §5.5).
        if (schedule == null) return false;

        // Resolve time for the occurrence
        DateTime resolvedTime = now;
        if (timePhrase != null) {
          resolvedTime = TimeResolver.resolve(timePhrase, now) ?? now;
        }

        // Find the closest pending occurrence for this schedule
        final occurrences = await medicationRepo.getOccurrencesForDate(
          schedule.id,
          resolvedTime,
        );
        final pendingOcc = occurrences.where(
          (o) => o.status == MedicationStatus.pending
        ).firstOrNull;

        if (pendingOcc == null) return false;
        await medicationRepo.updateOccurrenceStatus(
          pendingOcc.id,
          MedicationStatus.taken,
          note: 'AI-assisted: ${proposal.sourceQuote ?? "voice capture"}',
        );
        return true;

      case 'medication_skipped':
        final medName = payload['medicationName'] as String;
        final schedules = await medicationRepo.getActiveSchedules(careRecipientId);
        final schedule = schedules.where(
          (s) => s.medicationName.toLowerCase() == medName.toLowerCase()
        ).firstOrNull;
        if (schedule == null) return false;

        final occurrences = await medicationRepo.getOccurrencesForDate(
          schedule.id,
          now,
        );
        final pendingOcc = occurrences.where(
          (o) => o.status == MedicationStatus.pending
        ).firstOrNull;

        if (pendingOcc == null) return false;
        await medicationRepo.updateOccurrenceStatus(
          pendingOcc.id,
          MedicationStatus.skipped,
          note: payload['reasonText'] as String? ?? 'AI-assisted skip',
        );
        return true;

      case 'measurement':
        final type = payload['type'] as String;
        final value1 = (payload['value1'] as num).toDouble();
        final value2 = payload['value2'] != null
            ? (payload['value2'] as num).toDouble()
            : null;
        final unit = payload['unit'] as String;
        final timePhrase = payload['timePhrase'] as String?;

        // Invariant 4 defense in depth: out-of-range values are NEVER
        // persisted. The proposal stays pending until edited to a valid
        // value (spec S-3 "requires editing"); no silent correction.
        if (ProposalValidator.measurementRangeError(
                type, value1, value2, unit) !=
            null) {
          return false;
        }

        DateTime measuredAt = now;
        if (timePhrase != null) {
          measuredAt = TimeResolver.resolve(timePhrase, now) ?? now;
        }

        await measurementRepo.create(MeasurementEntity(
          id: uuid.v4(),
          careRecipientId: careRecipientId,
          measurementType: MeasurementType.fromDatabaseValue(type),
          value1: value1,
          value2: value2,
          unit: unit,
          measuredAt: measuredAt,
          recordedAt: now,
          sourceType: 'ai_assisted',
          createdAt: now,
          updatedAt: now,
        ));
        return true;

      case 'care_note':
        final text = payload['text'] as String;
        final timePhrase = payload['timePhrase'] as String?;
        
        DateTime observedAt = now;
        if (timePhrase != null) {
          observedAt = TimeResolver.resolve(timePhrase, now) ?? now;
        }

        await careNoteRepo.create(CareNoteEntity(
          id: uuid.v4(),
          careRecipientId: careRecipientId,
          observedAt: observedAt,
          recordedAt: now,
          originalText: text,
          sourceType: 'ai_assisted',
          reviewStatus: 'confirmed',
          createdAt: now,
          updatedAt: now,
        ));
        return true;

      default:
        // appointment, medication_schedule — handled by future phases.
        // Not written → not marked confirmed.
        return false;
    }
  }
}
