import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../services/ai/local/capture/voice_capture_service.dart';
import '../../../services/ai/local/local_ai_engine.dart';
import '../../../services/ai/local/ai_providers.dart';
import '../../../services/ai/local/proposals/proposal_models.dart';
import '../../../services/ai/local/proposals/proposal_validator.dart';
import '../../../services/ai/local/proposals/basic_text_extractor.dart';
import '../../../features/medications/data/medication_providers.dart';
import '../../../features/care_recipient/data/care_recipient_providers.dart';
import '../data/capture_providers.dart';
import 'review_tray_screen.dart';

/// Voice Capture screen: hold-to-talk with 30s limit.
/// Falls back to typed text if mic denied or no model.
class VoiceCaptureScreen extends ConsumerStatefulWidget {
  const VoiceCaptureScreen({super.key});

  @override
  ConsumerState<VoiceCaptureScreen> createState() => _VoiceCaptureScreenState();
}

class _VoiceCaptureScreenState extends ConsumerState<VoiceCaptureScreen> {
  static const _recordLimit = Duration(seconds: 30);

  final _textController = TextEditingController();
  final _voiceService = VoiceCaptureService();
  Timer? _recordTimer;
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _transcript;
  List<ProposedRecord> _proposals = [];

  @override
  void dispose() {
    _recordTimer?.cancel();
    _voiceService.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aiTier = ref.watch(aiTierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mag-capture'),
        actions: [
          // SOS button in every app bar per spec
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              onPressed: () => context.push('/emergency'),
              icon: const Icon(Icons.sos, size: 18),
              label: const Text('SOS'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // AI status banner
            aiTier.when(
              data: (tier) {
                if (tier == AiTier.basic) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Basic mode — type your notes below. Download the AI model in Settings for voice capture.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Transcript / recording area
            Expanded(
              child: _isProcessing
                  ? _buildProcessingState(theme)
                  : _proposals.isNotEmpty
                      ? _buildResultsPreview(theme)
                      : _buildCaptureInput(theme),
            ),

            const SizedBox(height: 16),

            // Action buttons
            if (!_isProcessing && _proposals.isEmpty)
              _buildActionButtons(theme),

            // Snap (photo capture) entry — icon + label, never icon-only
            if (!_isProcessing && _proposals.isEmpty)
              TextButton.icon(
                onPressed: () => context.push('/capture/snap'),
                icon: const Icon(Icons.photo_camera),
                label: const Text('Kunan ng litrato (reseta, label, monitor)'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureInput(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _isRecording ? Icons.mic : Icons.mic_none,
          size: 80,
          color: _isRecording ? theme.colorScheme.error : theme.colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          _isRecording ? 'Nakikinig...' : 'Mag-record o mag-type',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 32),
        // Text input field (always available as fallback)
        TextField(
          controller: _textController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Halimbawa: "Uminom si Lola ng Metformin, BP 130/80"',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 24),
          Text(
            'Pinoproseso...',
            style: theme.textTheme.titleMedium,
          ),
          if (_transcript != null) ...[
            const SizedBox(height: 12),
            Text(
              _transcript!,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsPreview(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_proposals.length} records detected',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: _proposals.length,
            itemBuilder: (context, index) {
              final p = _proposals[index];
              return ListTile(
                leading: Icon(
                  p.flag == ProposalFlag.sure ? Icons.check_circle : Icons.warning,
                  color: p.flag == ProposalFlag.sure ? Colors.green : Colors.orange,
                ),
                title: Text(_describeProposal(p)),
                subtitle: Text('"${p.sourceQuote}"', style: const TextStyle(fontStyle: FontStyle.italic)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        // Record button — disabled in Basic mode (text is the input there)
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: _isBasicTier ? null : _toggleRecording,
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              label: Text(_isRecording ? 'Itigil' : 'I-record'),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Process text button
        Expanded(
          child: SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: _textController.text.trim().isEmpty && !_isRecording
                  ? null
                  : _processInput,
              icon: const Icon(Icons.send),
              label: const Text('Iproseso'),
            ),
          ),
        ),
      ],
    );
  }

  bool get _isBasicTier =>
      ref.read(aiTierProvider).valueOrNull == AiTier.basic;

  Future<void> _toggleRecording() async {
    if (!_isRecording) {
      try {
        await _voiceService.start();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Mic unavailable: $e')),
          );
        }
        return;
      }
      setState(() => _isRecording = true);
      // Hard stop at 30 s — auto-submits, per spec.
      _recordTimer = Timer(_recordLimit, _stopRecordingAndProcess);
    } else {
      await _stopRecordingAndProcess();
    }
  }

  Future<void> _stopRecordingAndProcess() async {
    if (!_isRecording) return;
    _recordTimer?.cancel();
    final clip = await _voiceService.stop();
    setState(() => _isRecording = false);
    if (clip == null) return;
    await _processAudio(clip);
  }

  /// Audio path: WAV → engine (ASR + extraction) → review.
  /// Temp audio file is deleted right after processing.
  Future<void> _processAudio(AudioClip clip) async {
    setState(() => _isProcessing = true);
    try {
      final recipient = ref.read(primaryCareRecipientProvider).valueOrNull;
      if (recipient == null) return;

      final engine = ref.read(localAiEngineProvider);
      final medRepo = ref.read(medicationRepositoryProvider);
      final schedules = await medRepo.getActiveSchedules(recipient.id);
      final ctx = ExtractionContext(
        activeMeds: schedules.map((s) => s.medicationName).toList(),
        now: DateTime.now(),
        timezone: DateTime.now().timeZoneName,
      );

      final transcriptBuf = StringBuffer();
      final proposals = <ProposedRecord>[];
      String? failure;
      final sw = Stopwatch()..start();
      await for (final event in engine.extractFromAudio(clip, ctx)) {
        switch (event) {
          case TranscriptUpdated(:final text):
            transcriptBuf.write(text);
          case ProposalEmitted(:final record):
            proposals.add(record);
          case ExtractionFailed(:final reason):
            failure = reason;
          case ExtractionComplete():
            break;
        }
      }
      sw.stop();

      // Audio is discarded after extraction unless the user chose to keep it.
      if (clip is WavAudioClip) {
        try {
          await File(clip.path).delete();
        } catch (_) {}
      }

      final transcript = transcriptBuf.toString().trim();
      if (transcript.isEmpty && proposals.isEmpty) {
        throw StateError(failure ?? 'Walang narinig — subukan ulit o mag-type.');
      }

      await _finishExtraction(
        recipientId: recipient.id,
        modality: 'voice',
        transcript: transcript,
        proposals: proposals,
        latencyMs: sw.elapsedMilliseconds,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _processInput() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _transcript = text;
    });

    try {
      final recipientAsync = ref.read(primaryCareRecipientProvider);
      final recipient = recipientAsync.valueOrNull;
      if (recipient == null) return;

      final engine = ref.read(localAiEngineProvider);
      final tier = await engine.tier();

      // Get active medication names for context
      final medRepo = ref.read(medicationRepositoryProvider);
      final schedules = await medRepo.getActiveSchedules(recipient.id);
      final activeMedNames = schedules.map((s) => s.medicationName).toList();

      List<ProposedRecord> proposals;
      final sw = Stopwatch()..start();

      if (tier == AiTier.basic) {
        // Basic mode: deterministic regex extraction
        final extractor = BasicTextExtractor(activeMeds: activeMedNames);
        proposals = extractor.extract(text);
      } else {
        // AI mode: use the engine
        final ctx = ExtractionContext(
          activeMeds: activeMedNames,
          now: DateTime.now(),
          timezone: DateTime.now().timeZoneName,
        );
        // Consume the engine's text extraction stream into proposals.
        proposals = [];
        await for (final event in engine.extractFromText(text, ctx)) {
          if (event is ProposalEmitted) {
            proposals.add(event.record);
          }
        }
        // If the engine produced nothing usable, fall back to deterministic.
        if (proposals.isEmpty) {
          proposals = BasicTextExtractor(activeMeds: activeMedNames).extract(text);
        }
      }

      sw.stop();

      await _finishExtraction(
        recipientId: recipient.id,
        modality: 'text',
        transcript: text,
        proposals: proposals,
        latencyMs: sw.elapsedMilliseconds,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  /// Shared tail of both capture paths: validate → store → review tray.
  Future<void> _finishExtraction({
    required String recipientId,
    required String modality,
    required String transcript,
    required List<ProposedRecord> proposals,
    required int latencyMs,
  }) async {
    final medRepo = ref.read(medicationRepositoryProvider);
    final schedules = await medRepo.getActiveSchedules(recipientId);
    final activeMedNames = schedules.map((s) => s.medicationName).toList();

    final validator = ProposalValidator(
      activeMeds: activeMedNames,
      now: DateTime.now(),
      transcript: transcript,
    );
    final validated = proposals
        .map((p) => validator.validate(p))
        .whereType<ProposedRecord>()
        .toList();

    // Store capture + proposals
    final engine = ref.read(localAiEngineProvider);
    final captureRepo = ref.read(aiCaptureRepositoryProvider);
    final captureId = await captureRepo.createCapture(
      careRecipientId: recipientId,
      modality: modality,
      originalText: transcript,
      engineId: engine.engineId,
      modelId: engine.engineId,
      latencyMs: latencyMs,
    );

    for (final proposal in validated) {
      await captureRepo.createProposal(
        captureId: captureId,
        record: proposal,
      );
    }

    setState(() {
      _proposals = validated;
      _transcript = transcript;
      _isProcessing = false;
    });

    // Navigate to Review Tray
    if (mounted && validated.isNotEmpty) {
      final result = await Navigator.of(context).push<int>(
        MaterialPageRoute(
          builder: (_) => ReviewTrayScreen(
            captureId: captureId,
            careRecipientId: recipientId,
            heardText: transcript,
            proposals: validated,
          ),
        ),
      );

      if (result != null && result > 0 && mounted) {
        _textController.clear();
        setState(() {
          _proposals = [];
          _transcript = null;
        });
      }
    }
  }

  String _describeProposal(ProposedRecord p) {
    if (p is ProposedMedicationTaken) return 'Ininom: ${p.medicationName}';
    if (p is ProposedMedicationSkipped) return 'Na-skip: ${p.medicationName}';
    if (p is ProposedMeasurement) return '${p.type}: ${p.value1}${p.value2 != null ? "/${p.value2}" : ""} ${p.unit}';
    if (p is ProposedCareNote) return 'Tala: ${p.text}';
    if (p is ProposedAppointment) return 'Appointment: ${p.datetimePhrase}';
    if (p is ProposedMedicationSchedule) return 'Gamot: ${p.name}';
    return 'Record';
  }
}
