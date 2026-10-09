import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/ai/local/local_ai_engine.dart';
import '../../../services/ai/local/model/model_manager.dart';
import '../data/ai_setup_providers.dart';

/// "Phone helper" setup screen (UI spec H12). Helper-mode density.
/// Download → progress → ready. Skip keeps Basic mode fully working.
class AiSetupScreen extends ConsumerWidget {
  const AiSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(modelStatusProvider);
    final tier = ref.watch(deviceTierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Phone helper')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: status.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Something went wrong')),
            data: (s) => _buildBody(context, ref, s, tier),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ModelStatus status,
      AsyncValue<AiTier> tier) {
    switch (status.state) {
      case ModelInstallState.downloading:
      case ModelInstallState.verifying:
        return _progressView(context, ref, status);
      case ModelInstallState.installed:
        return _installedView(context, ref, status);
      case ModelInstallState.error:
        return Column(children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFFB3261E)),
          const SizedBox(height: 16),
          Text('Download failed', style: _title(context)),
          const SizedBox(height: 8),
          Text(status.error ?? '', style: _body(context)),
          const SizedBox(height: 24),
          _primaryButton(context, 'Try again',
              () => ref.read(modelManagerProvider).install()),
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Not now'),
          ),
        ]);
      case ModelInstallState.paused:
      case ModelInstallState.notInstalled:
        return _introView(context, ref, status, tier);
    }
  }

  Widget _introView(BuildContext context, WidgetRef ref, ModelStatus status,
      AsyncValue<AiTier> tier) {
    final unsupported =
        tier.hasValue && tier.value == AiTier.basic;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.phonelink_lock, size: 80, color: Color(0xFF0B6B6B)),
        const SizedBox(height: 16),
        Text('Phone helper', textAlign: TextAlign.center, style: _title(context)),
        const SizedBox(height: 24),
        _infoRow(Icons.lock_outline, 'Stays on this phone'),
        _infoRow(Icons.flight_outlined, 'Works offline'),
        _infoRow(Icons.mic_none, 'Hears Lola'),
        const Spacer(),
        if (status.state == ModelInstallState.paused)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('Paused — ${_sizeLabel(status.sizeBytes)} so far',
                textAlign: TextAlign.center, style: _body(context)),
          ),
        if (unsupported)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('This phone may be too small for the helper. '
                'Typing still works.',
                textAlign: TextAlign.center, style: _body(context)),
          ),
        _primaryButton(
          context,
          status.state == ModelInstallState.paused ? 'Resume' : 'Get it',
          unsupported ? null : () => ref.read(modelManagerProvider).install(),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: const Text('Skip'),
        ),
      ],
    );
  }

  Widget _progressView(
      BuildContext context, WidgetRef ref, ModelStatus status) {
    final pct =
        status.progress == null ? null : (status.progress! * 100).round();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          status.state == ModelInstallState.verifying
              ? 'Checking'
              : 'Downloading',
          textAlign: TextAlign.center,
          style: _title(context),
        ),
        const SizedBox(height: 8),
        Text(pct == null ? '…' : '$pct%',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: status.progress,
          minHeight: 12,
          borderRadius: BorderRadius.circular(6),
        ),
        const SizedBox(height: 8),
        if (status.sizeBytes != null)
          Text(_sizeLabel(status.sizeBytes),
              textAlign: TextAlign.center, style: _body(context)),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          style: _secondaryStyle(),
          onPressed: () => ref.read(modelManagerProvider).pause(),
          icon: const Icon(Icons.pause),
          label: const Text('Pause'),
        ),
      ],
    );
  }

  Widget _installedView(
      BuildContext context, WidgetRef ref, ModelStatus status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.check_circle, size: 80, color: Color(0xFF1B7F3B)),
        const SizedBox(height: 16),
        Text('Ready', textAlign: TextAlign.center, style: _title(context)),
        const SizedBox(height: 24),
        _infoRow(Icons.psychology_outlined, 'Helper: Ready'),
        _infoRow(Icons.storage_outlined,
            'Size: ${_sizeLabel(status.sizeBytes)}'),
        const Spacer(),
        OutlinedButton.icon(
          style: _secondaryStyle().copyWith(
            foregroundColor:
                const WidgetStatePropertyAll(Color(0xFFB3261E)),
          ),
          onPressed: () => ref.read(modelManagerProvider).delete(),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Delete'),
        ),
        const SizedBox(height: 12),
        _primaryButton(
            context, 'Done', () => Navigator.of(context).maybePop()),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Icon(icon, size: 32, color: const Color(0xFF0B6B6B)),
          const SizedBox(width: 16),
          Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 20, height: 1.3))),
        ]),
      );

  Widget _primaryButton(
          BuildContext context, String label, VoidCallback? onTap) =>
      SizedBox(
        height: 64,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0B6B6B),
            textStyle:
                const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
          ),
          onPressed: onTap,
          child: Text(label),
        ),
      );

  ButtonStyle _secondaryStyle() => OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(64),
        textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      );

  TextStyle? _title(BuildContext context) => Theme.of(context)
      .textTheme
      .headlineSmall
      ?.copyWith(fontSize: 28, fontWeight: FontWeight.bold);

  TextStyle? _body(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 20);

  String _sizeLabel(int? bytes) {
    if (bytes == null) return 'unknown size';
    final gb = bytes / (1024 * 1024 * 1024);
    if (gb >= 1) return '${gb.toStringAsFixed(1)} GB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(0)} MB';
  }
}
