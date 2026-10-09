import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_bar_actions.dart';
import '../../../services/ai/local/capture/voice_capture_service.dart';
import '../../../services/ai/local/local_ai_engine.dart';
import '../../../services/ai/local/ai_providers.dart';
import '../../../services/ai/local/proposals/proposal_models.dart';
import '../../../services/ai/local/proposals/proposal_repository.dart';
import '../../../services/ai/local/proposals/proposal_validator.dart';
import '../../../services/ai/local/proposals/basic_text_extractor.dart';
import '../../../features/medications/data/medication_providers.dart';
import '../../../features/care_recipient/data/care_recipient_providers.dart';
import '../data/capture_providers.dart';
import 'widgets/on_device_badge.dart';
import 'review_tray_screen.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

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
        leading: const OnDeviceBadge(),
        leadingWidth: 160,
        title: const Text('Record'),
        actions: const [SosAppBarButton()],
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
                        Icon(Symbols.info_rounded,
                            color: Color(0xFF9A5B00), size: 24),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Type your note below. Turn on Phone helper in Settings to use voice.',
                            style: TextStyle(fontSize: 17),
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

            // Transcript / recording area. Scrollable so an open keyboard
            // (or a small screen) shrinks it instead of overflowing.
            Expanded(
              child: _isProcessing
                  ? _scrollableCenter(_buildProcessingState(theme))
                  : _proposals.isNotEmpty
                      ? _buildResultsPreview(theme)
                      : _scrollableCenter(_buildCaptureInput(theme)),
            ),

            const SizedBox(height: 16),

            // Action buttons
            if (!_isProcessing && _proposals.isEmpty)
              _buildActionButtons(theme),

            // Snap (photo capture) entry — icon + label, never icon-only
            if (!_isProcessing && _proposals.isEmpty)
              TextButton.icon(
                onPressed: () => context.push('/capture/snap'),
                icon: const Icon(Symbols.photo_camera_rounded),
                label: const Text('Take a photo (prescription, label, monitor)'),
              ),
          ],
        ),
      ),
    );
  }

  /// Centers [child] when it fits; scrolls instead of overflowing when the
  /// keyboard or a short screen squeezes the available height.
  Widget _scrollableCenter(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(child: child),
        ),
      ),
    );
  }

  Widget _buildCaptureInput(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _isRecording ? Symbols.mic_rounded : Symbols.mic_none_rounded,
          size: 80,
          color: _isRecording ? theme.colorScheme.error : theme.colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          _isRecording ? 'Listening…' : 'Record or type',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 32),
        // Text input field (always available as fallback)
        TextField(
          controller: _textController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Example: "Lola took Metformin, BP 130/80"',
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
            'Processing…',
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
          '${_proposals.length} ${_proposals.length == 1 ? 'record' : 'records'} heard',
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
                  p.flag == ProposalFlag.sure ? Symbols.check_circle_rounded : Symbols.warning_rounded,
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
              icon: Icon(_isRecording ? Symbols.stop_rounded : Symbols.mic_rounded),
              label: Text(_isRecording ? 'Stop' : 'Record'),
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
              icon: const Icon(Symbols.send_rounded),
              label: const Text('Process'),
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
            const SnackBar(
                content: Text('Microphone not available. Try typing instead.')),
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
    // Guard BEFORE entering the processing state so the spinner can never
    // get stuck on an early return.
    final recipient = ref.read(primaryCareRecipientProvider).valueOrNull;
    if (recipient == null) return;

    setState(() => _isProcessing = true);
    try {
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
      // Hard ceiling so the "thinking" state can never spin forever if the
      // engine stalls; TimeoutException lands in the catch below.
      await for (final event in engine
          .extractFromAudio(clip, ctx)
          .timeout(const Duration(seconds: 60))) {
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
        throw StateError(failure ?? 'Could not hear anything. Try again or type.');
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
          const SnackBar(content: Text('Something went wrong. Try again.')),
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
          const SnackBar(content: Text('Something went wrong. Try again.')),
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

    final staged = <StagedProposal>[];
    for (final proposal in validated) {
      final id = await captureRepo.createProposal(
        captureId: captureId,
        record: proposal,
      );
      staged.add(StagedProposal(proposalId: id, record: proposal));
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
            proposals: staged,
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
    if (p is ProposedMedicationTaken) return 'Took: ${p.medicationName}';
    if (p is ProposedMedicationSkipped) return 'Skipped: ${p.medicationName}';
    if (p is ProposedMeasurement) return '${p.type}: ${p.value1}${p.value2 != null ? "/${p.value2}" : ""} ${p.unit}';
    if (p is ProposedCareNote) return 'Note: ${p.text}';
    if (p is ProposedAppointment) return 'Appointment: ${p.datetimePhrase}';
    if (p is ProposedMedicationSchedule) return 'Medicine: ${p.name}';
    return 'Record';
  }
}
