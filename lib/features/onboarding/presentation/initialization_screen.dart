import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../services/ai/local/local_ai_engine.dart';
import '../../../services/ai/local/model/device_probe.dart';
import '../../../services/ai/local/model/model_manager.dart';
import '../../ai_setup/data/ai_setup_providers.dart';

/// Full-screen initialization gate shown after onboarding (or on every cold
/// start until the model is installed).
///
/// States handled:
///   • checking  — probing device / reading install state (spinner)
///   • ios       — Apple Intelligence check (no download needed)
///   • unsupported — device tier = basic (explained, then through to Home)
///   • notInstalled / paused — offer "Download" / "Resume" with file size
///   • downloading / verifying — progress bar + percentage + Pause
///   • installed — "Ready ✓" → auto-navigate after 1.2 s
///   • error     — plain-words message + Retry / Try later
///
/// "Try later" is always available so a user on cellular or low battery can
/// skip. HomeScreen shows a persistent banner until the model is installed.
class InitializationScreen extends ConsumerStatefulWidget {
  const InitializationScreen({super.key});

  @override
  ConsumerState<InitializationScreen> createState() =>
      _InitializationScreenState();
}

class _InitializationScreenState extends ConsumerState<InitializationScreen> {
  static const _teal = Color(0xFF0B6B6B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    // iOS: no model to download — check Apple Intelligence availability.
    if (Platform.isIOS) return _IosView(onDone: _proceed);

    // Android: tier check first.
    final tierAsync = ref.watch(tierDecisionProvider);
    return tierAsync.when(
      loading: _checkingView,
      error: (_, __) => _UnsupportedView(onContinue: _proceed),
      data: (decision) {
        if (decision.tier == AiTier.basic) {
          return _UnsupportedView(
            reason: _basicReasonText(decision),
            onContinue: _proceed,
          );
        }
        // Device is capable — check model status.
        final statusAsync = ref.watch(modelStatusProvider);
        return statusAsync.when(
          loading: _checkingView,
          error: (_, __) => _ErrorView(
            errorCode: 'status_unavailable',
            onRetry: () => ref.invalidate(modelStatusProvider),
            onLater: _proceed,
          ),
          data: (status) => _modelStateView(status, decision),
        );
      },
    );
  }

  Widget _modelStateView(ModelStatus status, TierDecision decision) {
    switch (status.state) {
      case ModelInstallState.installed:
        return _InstalledView(onDone: _proceed);

      case ModelInstallState.downloading:
      case ModelInstallState.verifying:
        return _ProgressView(
          status: status,
          onPause: () async {
            final mgr = await ref.read(modelManagerProvider.future);
            mgr.pause();
          },
        );

      case ModelInstallState.error:
        return _ErrorView(
          errorCode: status.error,
          onRetry: () async {
            final mgr = await ref.read(modelManagerProvider.future);
            await mgr.install();
          },
          onLater: _proceed,
        );

      case ModelInstallState.notInstalled:
      case ModelInstallState.paused:
        return _DownloadView(
          status: status,
          onDownload: () async {
            final mgr = await ref.read(modelManagerProvider.future);
            await mgr.install();
          },
          onLater: _proceed,
        );
    }
  }

  void _proceed() => context.go('/');

  Widget _checkingView() => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _teal),
            SizedBox(height: 20),
            Text(
              'Getting ready…',
              style: TextStyle(fontSize: 20, color: Color(0xFF1A1A1A)),
            ),
          ],
        ),
      );

  static String _basicReasonText(TierDecision d) {
    if (d.reasons.contains(TierReason.lowStorage)) {
      return 'Not enough free space. Free some space, then try again. '
          'Typing still works.';
    }
    if (d.reasons.contains(TierReason.sdkTooOld) ||
        d.reasons.contains(TierReason.unsupportedCpu) ||
        d.reasons.contains(TierReason.lowRam)) {
      return 'This phone is too small for the Phone helper. '
          'Typing still works.';
    }
    return 'We could not check this phone. Typing still works.';
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets — each is a self-contained view rendered inside the scaffold.
// ---------------------------------------------------------------------------

class _IosView extends ConsumerWidget {
  final VoidCallback onDone;
  const _IosView({required this.onDone});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availAsync = ref.watch(appleAiAvailabilityProvider);
    return availAsync.when(
      loading: () => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF0B6B6B)),
            SizedBox(height: 20),
            Text('Getting ready…',
                style: TextStyle(fontSize: 20, color: Color(0xFF1A1A1A))),
          ],
        ),
      ),
      error: (_, __) => _UnsupportedView(
        reason: 'Could not check the Phone helper. Typing still works.',
        onContinue: onDone,
      ),
      data: (a) {
        final available = a['available'] == true;
        if (available) return _InstalledView(onDone: onDone);
        final reason = '${a['reason']}';
        String text;
        if (reason.contains('appleIntelligenceNotEnabled')) {
          text = 'Turn on Apple Intelligence in iPhone Settings. '
              'Typing still works.';
        } else if (reason.contains('deviceNotEligible')) {
          text =
              'This iPhone does not support the Phone helper. Typing still works.';
        } else if (reason.contains('requires_ios_26') ||
            reason.contains('notReady')) {
          text = 'Update this iPhone to use the Phone helper. '
              'Typing still works.';
        } else {
          text = 'Phone helper is not available. Typing still works.';
        }
        return _UnsupportedView(reason: text, onContinue: onDone);
      },
    );
  }
}

class _InstalledView extends StatefulWidget {
  final VoidCallback onDone;
  const _InstalledView({required this.onDone});

  @override
  State<_InstalledView> createState() => _InstalledViewState();
}

class _InstalledViewState extends State<_InstalledView> {
  @override
  void initState() {
    super.initState();
    // Brief "Ready" moment before auto-navigating — long enough to read,
    // short enough to feel instant.
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Symbols.check_circle_rounded,
              size: 96, color: Color(0xFF1B7F3B)),
          const SizedBox(height: 20),
          Text(
            'Ready',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: const Color(0xFF1A1A1A),
                ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Phone helper is on.',
            style: TextStyle(fontSize: 20, color: Color(0xFF5E5748)),
          ),
        ],
      ),
    );
  }
}

class _UnsupportedView extends StatelessWidget {
  final String? reason;
  final VoidCallback onContinue;

  const _UnsupportedView({this.reason, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        const Icon(Symbols.phonelink_off_rounded,
            size: 80, color: Color(0xFF9A5B00)),
        const SizedBox(height: 20),
        Text(
          'Phone helper not available',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          reason ?? 'Typing still works.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, color: Color(0xFF5E5748)),
        ),
        const Spacer(),
        _PrimaryButton(label: 'Continue', onTap: onContinue),
      ],
    );
  }
}

class _DownloadView extends StatelessWidget {
  final ModelStatus status;
  final VoidCallback onDownload;
  final VoidCallback onLater;

  const _DownloadView({
    required this.status,
    required this.onDownload,
    required this.onLater,
  });

  @override
  Widget build(BuildContext context) {
    final isPaused = status.state == ModelInstallState.paused;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        const Icon(Symbols.phonelink_lock_rounded,
            size: 80, color: Color(0xFF0B6B6B)),
        const SizedBox(height: 20),
        Text(
          'Phone helper',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
        ),
        const SizedBox(height: 24),
        _InfoRow(icon: Symbols.lock_rounded, text: 'Stays on this phone'),
        _InfoRow(icon: Symbols.flight_rounded, text: 'Works offline'),
        _InfoRow(
            icon: Symbols.mic_none_rounded, text: 'Listens and writes it down'),
        const SizedBox(height: 16),
        if (status.sizeBytes != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              isPaused
                  ? 'Paused · ${_sizeLabel(status.sizeBytes)} so far'
                  : 'About ${_sizeLabel(status.sizeBytes)} · Wi-Fi recommended',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Color(0xFF5E5748)),
            ),
          ),
        const Spacer(),
        _PrimaryButton(
          label: isPaused ? 'Resume' : 'Download',
          onTap: onDownload,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          child: TextButton(
            onPressed: onLater,
            child: const Text('Try later',
                style: TextStyle(fontSize: 18, color: Color(0xFF5E5748))),
          ),
        ),
      ],
    );
  }
}

class _ProgressView extends StatelessWidget {
  final ModelStatus status;
  final VoidCallback onPause;

  const _ProgressView({required this.status, required this.onPause});

  @override
  Widget build(BuildContext context) {
    final isVerifying = status.state == ModelInstallState.verifying;
    final pct =
        status.progress == null ? null : (status.progress! * 100).round();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isVerifying ? 'Checking' : 'Downloading',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          pct == null ? '…' : '$pct%',
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B6B6B)),
        ),
        const SizedBox(height: 20),
        LinearProgressIndicator(
          value: status.progress,
          minHeight: 14,
          borderRadius: BorderRadius.circular(7),
          color: const Color(0xFF0B6B6B),
          backgroundColor: const Color(0xFFD9D2C3),
        ),
        const SizedBox(height: 10),
        if (status.sizeBytes != null)
          Text(
            _sizeLabel(status.sizeBytes),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Color(0xFF5E5748)),
          ),
        const SizedBox(height: 32),
        if (!isVerifying)
          SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                side: const BorderSide(color: Color(0xFF0B6B6B), width: 2),
                foregroundColor: const Color(0xFF0B6B6B),
              ),
              onPressed: onPause,
              icon: const Icon(Symbols.pause_rounded),
              label: const Text('Pause'),
            ),
          ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String? errorCode;
  final VoidCallback onRetry;
  final VoidCallback onLater;

  const _ErrorView({
    this.errorCode,
    required this.onRetry,
    required this.onLater,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        const Icon(Symbols.error_rounded, size: 80, color: Color(0xFFB3261E)),
        const SizedBox(height: 20),
        Text(
          'Download stopped',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          _errorText(errorCode),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, color: Color(0xFF5E5748)),
        ),
        const Spacer(),
        _PrimaryButton(label: 'Try again', onTap: onRetry),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          child: TextButton(
            onPressed: onLater,
            child: const Text('Try later',
                style: TextStyle(fontSize: 18, color: Color(0xFF5E5748))),
          ),
        ),
      ],
    );
  }

  static String _errorText(String? code) {
    if (code == 'not_enough_space') {
      return 'Not enough free space on this phone.';
    }
    if (code == 'checksum_mismatch' || code == 'no_download_url') {
      return 'The download is not ready. Try again later.';
    }
    if (code != null && code.startsWith('http_')) {
      return 'Could not reach the server. Try again.';
    }
    return 'Check the internet and try again.';
  }
}

// ---------------------------------------------------------------------------
// Shared small widgets
// ---------------------------------------------------------------------------

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 32, color: const Color(0xFF0B6B6B)),
            const SizedBox(width: 16),
            Expanded(
                child: Text(text,
                    style: const TextStyle(fontSize: 20, height: 1.3))),
          ],
        ),
      );
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
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
}

String _sizeLabel(int? bytes) {
  if (bytes == null) return '';
  final gb = bytes / (1024 * 1024 * 1024);
  if (gb >= 1) return '${gb.toStringAsFixed(1)} GB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(0)} MB';
}
