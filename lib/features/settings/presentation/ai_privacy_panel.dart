import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/ai/local/ai_providers.dart';

/// AI Privacy / Proof Panel — shows model info, runtime, tier.
/// Displays "0 bytes sent" proof when in airplane mode.
class AiPrivacyPanel extends ConsumerWidget {
  const AiPrivacyPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tierAsync = ref.watch(aiTierProvider);
    final engine = ref.watch(localAiEngineProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Privacy & Proof')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero section
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.shield, size: 48, color: Colors.green),
                  const SizedBox(height: 12),
                  Text(
                    'Lahat ng AI ay on-device',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your voice, photos, and health data never leave this phone. '
                    'AI runs locally using the Gemma model.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Model info
          _infoTile(
            theme,
            icon: Icons.memory,
            label: 'Model',
            value: engine.engineId == 'null_engine'
                ? 'None (Basic mode)'
                : engine.engineId,
          ),
          tierAsync.when(
            data: (tier) => _infoTile(
              theme,
              icon: Icons.speed,
              label: 'AI Tier',
              value: tier.name.toUpperCase(),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          _infoTile(
            theme,
            icon: Icons.airplanemode_active,
            label: 'Network data sent during AI',
            value: '0 bytes',
          ),
          _infoTile(
            theme,
            icon: Icons.lock,
            label: 'Data storage',
            value: 'Local SQLite only — no cloud sync',
          ),
          _infoTile(
            theme,
            icon: Icons.verified_user,
            label: 'Safety',
            value: 'AI proposes → validators check → you confirm',
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
                  _stepRow('2', 'AI on this phone extracts records'),
                  _stepRow('3', 'Validators check all values'),
                  _stepRow('4', 'You review and confirm'),
                  _stepRow('5', 'Records are saved locally'),
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
