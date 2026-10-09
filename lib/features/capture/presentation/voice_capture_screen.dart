import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final _textController = TextEditingController();
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _transcript;
  List<ProposedRecord> _proposals = [];

  @override
  void dispose() {
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
              onPressed: () => Navigator.of(context).pushNamed('/emergency'),
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
                      color: Colors.amber.withOpacity(0.15),
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
        // Record button (placeholder — actual recording needs platform channel)
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: _toggleRecording,
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

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
    // TODO: Implement actual audio recording via platform channel
    // For now, users can type text as the fallback path
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
        // For now, use text extraction; audio will come from C7
        final events = engine.extractFromText(text, ctx);
        // TODO: Convert ExtractionEvents to ProposedRecords
        // For MVP, fall back to basic extractor
        final extractor = BasicTextExtractor(activeMeds: activeMedNames);
        proposals = extractor.extract(text);
      }

      sw.stop();

      // Validate all proposals
      final validator = ProposalValidator(
        activeMeds: activeMedNames,
        now: DateTime.now(),
        transcript: text,
      );
      proposals = proposals
          .map((p) => validator.validate(p))
          .whereType<ProposedRecord>()
          .toList();

      // Store capture + proposals
      final captureRepo = ref.read(aiCaptureRepositoryProvider);
      final captureId = await captureRepo.createCapture(
        careRecipientId: recipient.id,
        modality: 'text',
        originalText: text,
        engineId: engine.engineId,
        modelId: 'basic',
        latencyMs: sw.elapsedMilliseconds,
      );

      for (final proposal in proposals) {
        await captureRepo.createProposal(
          captureId: captureId,
          record: proposal,
        );
      }

      setState(() {
        _proposals = proposals;
        _isProcessing = false;
      });

      // Navigate to Review Tray
      if (mounted && proposals.isNotEmpty) {
        final result = await Navigator.of(context).push<int>(
          MaterialPageRoute(
            builder: (_) => ReviewTrayScreen(
              captureId: captureId,
              careRecipientId: recipient.id,
              heardText: text,
              proposals: proposals,
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
