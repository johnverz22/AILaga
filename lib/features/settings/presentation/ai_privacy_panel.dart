import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/ai/local/ai_providers.dart';
import '../../../services/ai/local/local_ai_engine.dart';
import '../../../services/ai/local/proof/traffic_proof_channel.dart';

/// Real per-app traffic counters from Android TrafficStats (spike S5).
/// Null → channel unavailable on this platform.
final _trafficCountersProvider =
    FutureProvider<TrafficSnapshot?>((ref) async {
  final rx = await TrafficProofChannel.getUidRxBytes();
  final tx = await TrafficProofChannel.getUidTxBytes();
  if (rx == null || tx == null) return null;
  return TrafficSnapshot(rxBytes: rx, txBytes: tx);
});

/// AI Privacy / Proof Panel — shows model info, runtime, tier.
/// Displays "0 bytes sent" proof when in airplane mode.
class AiPrivacyPanel extends ConsumerWidget {
  const AiPrivacyPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tierAsync = ref.watch(aiTierProvider);
    final engine = ref.watch(localAiEngineProvider);

    final helperOn = engine.engineId != 'null_engine';

    return Scaffold(
      appBar: AppBar(title: const Text('On my phone')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero section — states only what is true right now.
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.shield, size: 48, color: Colors.green),
                  const SizedBox(height: 12),
                  Text(
                    'Nananatili sa teleponong ito',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your voice, photos, and health records are saved only '
                    'on this phone. Nothing is uploaded.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Helper status — plain words, true facts only.
          _infoTile(
            theme,
            icon: Icons.memory,
            label: 'Phone helper',
            value: helperOn
                ? 'On — works without internet'
                : 'Off — typing still works',
          ),
          tierAsync.when(
            data: (tier) => helperOn
                ? _infoTile(
                    theme,
                    icon: Icons.speed,
                    label: 'Helper speed on this phone',
                    value: switch (tier) {
                      AiTier.full => 'Normal',
                      AiTier.lite => 'Slower (smaller phone)',
                      AiTier.basic => 'Not running',
                    },
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          ref.watch(_trafficCountersProvider).when(
            data: (snap) => Column(
              children: [
                _infoTile(
                  theme,
                  icon: Icons.airplanemode_active,
                  label: 'Network data sent by this app',
                  value: snap == null
                      ? 'Not measurable on this device'
                      : _bytesLabel(snap.txBytes),
                ),
                if (snap != null)
                  _infoTile(
                    theme,
                    icon: Icons.download_done,
                    label: 'Network data received by this app',
                    value: _bytesLabel(snap.rxBytes),
                  ),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => _infoTile(
              theme,
              icon: Icons.airplanemode_active,
              label: 'Network data sent by this app',
              value: 'Not measurable on this device',
            ),
          ),
          _infoTile(
            theme,
            icon: Icons.lock,
            label: 'Where records live',
            value: 'Only on this phone — no account, no cloud',
          ),
          _infoTile(
            theme,
            icon: Icons.verified_user,
            label: 'Who decides',
            value: 'The phone suggests. You always confirm before saving.',
          ),

          const SizedBox(height: 24),
          // Explanation
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How it works', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _stepRow('1', 'You speak or type a care update'),
                  _stepRow('2', 'The phone turns it into cards'),
                  _stepRow('3', 'Every number is checked'),
                  _stepRow('4', 'You review and confirm'),
                  _stepRow('5', 'It is saved on this phone'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(ThemeData theme,
      {required IconData icon, required String label, required String value}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }

  String _bytesLabel(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget _stepRow(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 12, child: Text(number, style: const TextStyle(fontSize: 12))),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
