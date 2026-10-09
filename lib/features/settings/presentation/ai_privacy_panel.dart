import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_bar_actions.dart';
import '../../../services/ai/local/ai_providers.dart';
import '../../../services/ai/local/local_ai_engine.dart';
import '../../../services/ai/local/proof/traffic_proof_channel.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Real per-app traffic counters from Android TrafficStats (spike S5).
/// Null → channel unavailable on this platform.
final _trafficCountersProvider =
    FutureProvider<TrafficSnapshot?>((ref) async {
  final rx = await TrafficProofChannel.getUidRxBytes();
  final tx = await TrafficProofChannel.getUidTxBytes();
  if (rx == null || tx == null) return null;
  return TrafficSnapshot(rxBytes: rx, txBytes: tx);
});

/// "On my phone" — privacy proof panel (UI spec H13).
/// States only what is true right now: local storage, real byte
/// counters from the OS, helper status.
class AiPrivacyPanel extends ConsumerWidget {
  const AiPrivacyPanel({super.key});

  static const _sure = Color(0xFF1B7F3B);
  static const _muted = Color(0xFF5E5748);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tierAsync = ref.watch(aiTierProvider);
    final engine = ref.watch(localAiEngineProvider);

    final helperOn = engine.engineId != 'null_engine';

    return Scaffold(
      appBar: AppBar(
        title: const Text('On my phone'),
        actions: const [SosAppBarButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero section — states only what is true right now.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Symbols.shield_rounded,
                      size: 56, color: _sure),
                  const SizedBox(height: 12),
                  Text(
                    'Stays on this phone',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: _sure,
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
            icon: Symbols.memory_rounded,
            label: 'Phone helper',
            value: helperOn
                ? 'On — works without internet'
                : 'Off — typing still works',
          ),
          tierAsync.when(
            data: (tier) => helperOn
                ? _infoTile(
                    theme,
                    icon: Symbols.speed_rounded,
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
                  icon: Symbols.upload_rounded,
                  label: 'Network data sent by this app',
                  value: snap == null
                      ? 'Not measurable on this device'
                      : _bytesLabel(snap.txBytes),
                ),
                if (snap != null)
                  _infoTile(
                    theme,
                    icon: Symbols.download_done_rounded,
                    label: 'Network data received by this app',
                    value: _bytesLabel(snap.rxBytes),
                  ),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => _infoTile(
              theme,
              icon: Symbols.upload_rounded,
              label: 'Network data sent by this app',
              value: 'Not measurable on this device',
            ),
          ),
          _infoTile(
            theme,
            icon: Symbols.lock_rounded,
            label: 'Where records live',
            value: 'Only on this phone — no account, no cloud',
          ),
          _infoTile(
            theme,
            icon: Symbols.verified_user_rounded,
            label: 'Who decides',
            value: 'The phone suggests. You always confirm before saving.',
          ),

          const SizedBox(height: 24),
          // Explanation
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How it works', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _stepRow(theme, '1', 'You speak or type a care update'),
                  _stepRow(theme, '2', 'The phone turns it into cards'),
                  _stepRow(theme, '3', 'Every number is checked'),
                  _stepRow(theme, '4', 'You review and confirm'),
                  _stepRow(theme, '5', 'It is saved on this phone'),
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
      leading: Icon(icon, size: 28),
      title: Text(label,
          style: theme.textTheme.bodyLarge
              ?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(value,
          style: theme.textTheme.bodyMedium?.copyWith(color: _muted)),
    );
  }

  String _bytesLabel(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget _stepRow(ThemeData theme, String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFF0B6B6B),
            child: Text(number,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
              child:
                  Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
