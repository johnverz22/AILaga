import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/care_recipient/data/care_recipient_providers.dart';
import '../features/emergency/data/emergency_providers.dart';
import '../services/hardware/app_settings_service.dart';
import '../services/hardware/sos_sensor_service.dart';

/// Wraps the app shell and listens for hardware SOS events.
///
/// Fully deterministic — no AI. Foreground only (the accelerometer
/// stream runs while the app is open). Two behaviors:
///  - **Shake** → opens the emergency screen directly and logs a
///    `shake` trigger event.
///  - **Possible fall** → "Are you okay?" countdown dialog. Timeout or
///    "Get help" opens the emergency screen; "I'm okay" cancels.
class SosSensorGuard extends ConsumerStatefulWidget {
  final Widget child;
  const SosSensorGuard({super.key, required this.child});

  @override
  ConsumerState<SosSensorGuard> createState() => _SosSensorGuardState();
}

class _SosSensorGuardState extends ConsumerState<SosSensorGuard> {
  StreamSubscription<SosSensorEvent>? _sub;
  bool _handling = false;

  @override
  void initState() {
    super.initState();
    _sub = ref.read(sosSensorServiceProvider).events.listen(_onEvent);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _logTrigger(String triggerType) async {
    final recipientId =
        ref.read(primaryCareRecipientProvider).valueOrNull?.id;
    if (recipientId == null) return;
    try {
      await ref
          .read(emergencyServiceProvider)
          .triggerEmergency(recipientId, triggerType);
    } catch (_) {
      // Logging failure must never block the SOS flow.
    }
  }

  void _onEvent(SosSensorEvent event) {
    if (_handling || !mounted) return;
    _handling = true;
    HapticFeedback.heavyImpact();
    if (event.kind == SosSensorEventKind.shake) {
      _logTrigger('shake');
      context.push('/emergency').then((_) => _handling = false);
    } else {
      _showFallCheck()
          .then((helpNeeded) {
            if (helpNeeded) {
              _logTrigger('possible_fall');
              if (mounted) return context.push('/emergency');
            }
          })
          .whenComplete(() => _handling = false);
    }
  }

  /// "Are you okay?" countdown — returns true if help is needed
  /// (timeout or explicit button).
  Future<bool> _showFallCheck() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _FallCheckDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // Watch the toggles and keep the service configured/running.
    final shake = ref.watch(shakeSosEnabledProvider).valueOrNull ?? true;
    final fall = ref.watch(fallDetectionEnabledProvider).valueOrNull ?? false;
    final service = ref.watch(sosSensorServiceProvider);
    service.configure(shake: shake, fall: fall);
    if (shake || fall) {
      service.start();
    } else {
      service.stop();
    }
    return widget.child;
  }
}

class _FallCheckDialog extends StatefulWidget {
  const _FallCheckDialog();

  @override
  State<_FallCheckDialog> createState() => _FallCheckDialogState();
}

class _FallCheckDialogState extends State<_FallCheckDialog> {
  static const _seconds = 20;
  int _left = _seconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_left <= 1) {
        t.cancel();
        Navigator.of(context).pop(true);
      } else {
        setState(() => _left--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Are you okay?'),
      content: Text(
        'A possible fall was noticed.\n\n'
        'Getting help in $_left seconds unless you tap "I\'m okay".',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("I'm okay", style: TextStyle(fontSize: 18)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC62828)),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Get help', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }
}
