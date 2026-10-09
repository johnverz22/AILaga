import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/ai/local/local_ai_engine.dart';
import '../../../services/ai/local/model/device_probe.dart';
import '../../../services/ai/local/model/model_manager.dart';
import '../../../services/hardware/app_settings_service.dart';
import '../../care_recipient/data/care_recipient_providers.dart';
import '../data/ai_setup_providers.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// "Phone helper" setup screen (UI spec H12). Helper-mode density.
/// Download → progress → ready. Skip keeps Basic mode fully working.
class AiSetupScreen extends ConsumerWidget {
  const AiSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // iOS has nothing to download — the helper is Apple Intelligence,
    // built into the OS. Show its real availability instead.
    if (Platform.isIOS) return _iosScaffold(context, ref);

    final status = ref.watch(modelStatusProvider);
    final tier = ref.watch(tierDecisionProvider);
    final name = ref
            .watch(primaryCareRecipientProvider)
            .valueOrNull
            ?.displayName ??
        'your loved one';

    return Scaffold(
      appBar: AppBar(title: const Text('Phone helper')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: status.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) =>
                      const Center(child: Text('Something went wrong')),
                  data: (s) => _buildBody(context, ref, s, tier, name),
                ),
              ),
              _keepRecordingsTile(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  /// "Keep recordings" toggle (spec C8). Off by default — clips are
  /// deleted right after extraction. Shown on this screen because the
  /// setting only matters when the helper can listen.
  Widget _keepRecordingsTile(BuildContext context, WidgetRef ref) {
    final keep = ref.watch(keepRecordingsProvider).valueOrNull ?? false;
    return Card(
      margin: EdgeInsets.zero,
      child: SwitchListTile(
        secondary: const Icon(Symbols.mic_rounded, size: 28),
        title: const Text('Keep recordings', style: TextStyle(fontSize: 18)),
        subtitle: const Text(
          'Voice clips stay on this phone. Off = deleted after use.',
        ),
        value: keep,
        onChanged: (v) async {
          await ref
              .read(appSettingsServiceProvider)
              .setBool(AppSettingsService.keyKeepRecordings, v);
          ref.invalidate(keepRecordingsProvider);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ModelStatus status,
      AsyncValue<TierDecision> tier, String name) {
    switch (status.state) {
      case ModelInstallState.downloading:
      case ModelInstallState.verifying:
        return _progressView(context, ref, status);
      case ModelInstallState.installed:
        return _installedView(context, ref, status);
      case ModelInstallState.error:
        return Column(children: [
          const Icon(Symbols.error_rounded, size: 64, color: Color(0xFFB3261E)),
          const SizedBox(height: 16),
          Text('Download failed', style: _title(context)),
          const SizedBox(height: 8),
          Text(_errorText(status.error), style: _body(context)),
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
        return _introView(context, ref, status, tier, name);
    }
  }

  /// Plain-words version of the error codes ModelManager emits — never show
  /// raw exception strings here.
  static String _errorText(String? code) {
    if (code == 'not_enough_space') {
      return 'Not enough free space on this phone.';
    }
    if (code == 'checksum_mismatch' || code == 'no_download_url') {
      return 'The download is not ready yet. Try again later.';
    }
    if (code != null && code.startsWith('http_')) {
      return 'Could not reach the server. Try again.';
    }
    return 'Check the internet and try again.';
  }

  /// Plain-words explanation of why the helper can't run here — no jargon.
  static String _basicReasonText(TierDecision d) {
    if (d.reasons.contains(TierReason.lowStorage)) {
      return 'Not enough free space on this phone. '
          'Free some space, then try again. Typing still works.';
    }
    if (d.reasons.contains(TierReason.sdkTooOld) ||
        d.reasons.contains(TierReason.unsupportedCpu) ||
        d.reasons.contains(TierReason.lowRam)) {
      return 'This phone is too small for the helper. Typing still works.';
    }
    return 'We could not check this phone. Typing still works.';
  }

  Widget _introView(BuildContext context, WidgetRef ref, ModelStatus status,
      AsyncValue<TierDecision> tier, String name) {
    final decision = tier.valueOrNull;
    final unsupported = decision != null && decision.tier == AiTier.basic;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Symbols.phonelink_lock_rounded, size: 80, color: Color(0xFF0B6B6B)),
        const SizedBox(height: 16),
        Text('Phone helper', textAlign: TextAlign.center, style: _title(context)),
        const SizedBox(height: 24),
        _infoRow(Symbols.lock_rounded, 'Stays on this phone'),
        _infoRow(Symbols.flight_rounded, 'Works offline'),
        _infoRow(Symbols.mic_none_rounded, 'Hears $name'),
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
            child: Text(_basicReasonText(decision),
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
          icon: const Icon(Symbols.pause_rounded),
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
        const Icon(Symbols.check_circle_rounded, size: 80, color: Color(0xFF1B7F3B)),
        const SizedBox(height: 16),
        Text('Ready', textAlign: TextAlign.center, style: _title(context)),
        const SizedBox(height: 24),
        _infoRow(Symbols.psychology_rounded, 'Helper: Ready'),
        _infoRow(Symbols.storage_rounded,
            'Size: ${_sizeLabel(status.sizeBytes)}'),
        const Spacer(),
        OutlinedButton.icon(
          style: _secondaryStyle().copyWith(
            foregroundColor:
                const WidgetStatePropertyAll(Color(0xFFB3261E)),
          ),
          onPressed: () => ref.read(modelManagerProvider).delete(),
          icon: const Icon(Symbols.delete_rounded),
          label: const Text('Delete'),
        ),
        const SizedBox(height: 12),
        _primaryButton(
            context, 'Done', () => Navigator.of(context).maybePop()),
      ],
    );
  }

  /// iOS status card: helper availability comes from the OS, not a
  /// download. Honest wording — says what to do, never blames.
  Widget _iosScaffold(BuildContext context, WidgetRef ref) {
    final avail = ref.watch(appleAiAvailabilityProvider);
    final name = ref
            .watch(primaryCareRecipientProvider)
            .valueOrNull
            ?.displayName ??
        'your loved one';
    return Scaffold(
      appBar: AppBar(title: const Text('Phone helper')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: avail.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) =>
                      _iosBody(context, false, 'channel_error', name),
                  data: (a) => _iosBody(context,
                      a['available'] == true, '${a['reason']}', name),
                ),
              ),
              _keepRecordingsTile(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iosBody(
      BuildContext context, bool available, String reason, String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          available ? Symbols.check_circle_rounded : Symbols.phonelink_lock_rounded,
          size: 80,
          color: available
              ? const Color(0xFF1B7F3B)
              : const Color(0xFF0B6B6B),
        ),
        const SizedBox(height: 16),
        Text(available ? 'Ready' : 'Phone helper',
            textAlign: TextAlign.center, style: _title(context)),
        const SizedBox(height: 24),
        if (available) ...[
          _infoRow(Symbols.lock_rounded, 'Stays on this phone'),
          _infoRow(Symbols.flight_rounded, 'Works offline'),
          _infoRow(Symbols.mic_none_rounded, 'Hears $name'),
        ] else ...[
          _infoRow(Symbols.settings_rounded, _iosReasonText(reason)),
          _infoRow(Symbols.keyboard_alt_rounded,
              'Typing still works either way'),
        ],
        const Spacer(),
        _primaryButton(
            context, 'Done', () => Navigator.of(context).maybePop()),
      ],
    );
  }

  static String _iosReasonText(String reason) {
    if (reason.contains('appleIntelligenceNotEnabled')) {
      return 'Turn on Apple Intelligence in iPhone Settings';
    }
    if (reason.contains('deviceNotEligible')) {
      return 'This iPhone does not have Apple Intelligence';
    }
    if (reason.contains('requires_ios_26') ||
        reason.contains('notReady')) {
      return 'Update this iPhone to turn on the helper';
    }
    return 'The helper is not available on this iPhone';
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
