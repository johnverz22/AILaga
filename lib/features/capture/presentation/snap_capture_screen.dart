import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../app/app_bar_actions.dart';
import '../../../services/ai/local/ai_providers.dart';
import '../../../services/ai/local/capture/snap_service.dart';
import '../../../services/ai/local/local_ai_engine.dart';
import '../../../services/ai/local/proposals/proposal_models.dart';
import '../../../services/ai/local/proposals/proposal_repository.dart';
import '../../../services/ai/local/proposals/proposal_validator.dart';
import '../../care_recipient/data/care_recipient_providers.dart';
import '../../medications/data/medication_providers.dart';
import '../data/capture_providers.dart';
import 'review_tray_screen.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Snap capture (C11): photo → Reseta / Label / Monitor proposals → review.
/// Photo stays on the phone; discarded after use unless attached.
class SnapCaptureScreen extends ConsumerStatefulWidget {
  const SnapCaptureScreen({super.key});

  @override
  ConsumerState<SnapCaptureScreen> createState() => _SnapCaptureScreenState();
}

class _SnapCaptureScreenState extends ConsumerState<SnapCaptureScreen> {
  final _snapService = SnapService();
  ImageIntent _intent = ImageIntent.monitor;
  FileImageInput? _photo;
  bool _processing = false;
  bool _attachPhoto = false;

  static const _intents = [
    (ImageIntent.monitor, Symbols.monitor_heart_rounded, 'Monitor'),
    (ImageIntent.reseta, Symbols.receipt_long_rounded, 'Prescription'),
    (ImageIntent.label, Symbols.medication_rounded, 'Label'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tierAsync = ref.watch(aiTierProvider);
    final isBasic = tierAsync.valueOrNull == AiTier.basic;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a photo'),
        actions: const [SosAppBarButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isBasic)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: const Text(
                'Phone helper is off. Photos need the helper — turn it on in Settings.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          Text('What is the photo?', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: _intents.map((entry) {
              final (intent, icon, label) = entry;
              final selected = _intent == intent;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SizedBox(
                    height: 80,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        // Compact padding — the theme's 14dp vertical
                        // padding starves the icon+label column.
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: selected
                            ? theme.colorScheme.primaryContainer
                            : null,
                        side: BorderSide(
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      onPressed: () => setState(() => _intent = intent),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon),
                          const SizedBox(height: 4),
                          Text(label, style: const TextStyle(fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          if (_photo != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_photo!.path),
                height: 280,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Attach photo to record'),
              subtitle: const Text('Off — photo is deleted after use'),
              value: _attachPhoto,
              onChanged: (v) => setState(() => _attachPhoto = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 64,
                  child: FilledButton.icon(
                    onPressed: isBasic || _processing
                        ? null
                        : () => _pick(camera: true),
                    icon: const Icon(Symbols.photo_camera_rounded),
                    label: const Text('Camera'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 64,
                  child: OutlinedButton.icon(
                    onPressed: isBasic || _processing
                        ? null
                        : () => _pick(camera: false),
                    icon: const Icon(Symbols.photo_library_rounded),
                    label: const Text('Gallery'),
                  ),
                ),
              ),
            ],
          ),
          if (_photo != null) ...[
            const SizedBox(height: 16),
            if (isBasic)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: const Text(
                  'Phone helper is off. To analyze photos, install it in Settings → Phone helper.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            SizedBox(
              height: 64,
              child: FilledButton.icon(
                onPressed: isBasic || _processing ? null : _processPhoto,
                icon: _processing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Symbols.check_rounded),
                label: Text(_processing ? 'Reading…' : 'Use this photo'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pick({required bool camera}) async {
    if (camera) {
      final status = await Permission.camera.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Camera access denied. Allow it in phone Settings to take photos.'),
            ),
          );
        }
        return;
      }
    }
    final input = camera
        ? await _snapService.snapPhoto()
        : await _snapService.pickFromGallery();
    if (input != null && mounted) {
      setState(() => _photo = input);
    } else if (input == null && mounted && camera) {
      // Covers remaining null cases: user cancelled or camera failed.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open camera. Try again.')),
      );
    }
  }

  Future<void> _processPhoto() async {
    final photo = _photo;
    if (photo == null) return;
    // Guard BEFORE entering the processing state so the spinner can never
    // get stuck on an early return.
    final recipient = ref.read(primaryCareRecipientProvider).valueOrNull;
    if (recipient == null) return;

    setState(() => _processing = true);
    try {
      final engine = ref.read(localAiEngineProvider);
      final medRepo = ref.read(medicationRepositoryProvider);
      final schedules = await medRepo.getActiveSchedules(recipient.id);
      final activeMedNames = schedules.map((s) => s.medicationName).toList();
      final ctx = ExtractionContext(
        activeMeds: activeMedNames,
        now: DateTime.now(),
        timezone: DateTime.now().timeZoneName,
      );

      final transcriptBuf = StringBuffer();
      final proposals = <ProposedRecord>[];
      final sw = Stopwatch()..start();
      // Hard ceiling so "Reading…" can never spin forever on a stall.
      await for (final event in engine
          .extractFromImage(photo, _intent, ctx)
          .timeout(const Duration(seconds: 60))) {
        switch (event) {
          case TranscriptUpdated(:final text):
            transcriptBuf.write(text);
          case ProposalEmitted(:final record):
            proposals.add(record);
          case ExtractionFailed(:final reason):
            throw StateError(reason);
          case ExtractionComplete():
            break;
        }
      }
      sw.stop();

      final transcript = transcriptBuf.toString().trim();
      final validator = ProposalValidator(
        activeMeds: activeMedNames,
        now: DateTime.now(),
        transcript: transcript,
      );
      final validated = proposals
          .map((p) => validator.validate(p))
          .whereType<ProposedRecord>()
          .toList();

      if (validated.isEmpty && transcript.isEmpty) {
        throw StateError('Could not read the photo — try again.');
      }

      final captureRepo = ref.read(aiCaptureRepositoryProvider);
      final captureId = await captureRepo.createCapture(
        careRecipientId: recipient.id,
        modality: 'snap',
        originalText: transcript.isEmpty ? '[photo]' : transcript,
        engineId: engine.engineId,
        modelId: engine.engineId,
        latencyMs: sw.elapsedMilliseconds,
      );
      final staged = <StagedProposal>[];
      for (final p in validated) {
        final id =
            await captureRepo.createProposal(captureId: captureId, record: p);
        staged.add(StagedProposal(proposalId: id, record: p));
      }

      // Photo is discarded after use unless the user attached it.
      if (!_attachPhoto) {
        await _snapService.discard(photo);
      }

      if (mounted) {
        setState(() => _processing = false);
        await Navigator.of(context).push<int>(
          MaterialPageRoute(
            builder: (_) => ReviewTrayScreen(
              captureId: captureId,
              careRecipientId: recipient.id,
              heardText: transcript.isEmpty ? null : transcript,
              proposals: staged,
            ),
          ),
        );
        if (mounted) setState(() => _photo = null);
      }
    } catch (e) {
      if (mounted) {
        final message = e is AiUnavailable
            ? 'Phone helper is off. Install it in Settings → Phone helper to analyze photos.'
            : 'Error: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
        setState(() => _processing = false);
      }
    }
  }
}
