import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ai_providers.dart';
import 'local_ai_engine.dart';

/// Periodic idle-unload driver for the live [LocalAiEngine] (spec §6.2:
/// "lazy load, 60 s idle unload"). The engine itself decides whether it is
/// actually idle; this class only provides the heartbeat.
///
/// Created per engine by [engineLifecycleProvider] — when the engine is
/// swapped (install/delete/degrade) the old unloader is disposed.
class EngineIdleUnloader {
  EngineIdleUnloader(
    this._engine, {
    this.idle = const Duration(seconds: 60),
    this.tick = const Duration(seconds: 15),
  });

  final LocalAiEngine _engine;

  /// How long the engine may sit unused before it is asked to unload.
  final Duration idle;

  /// Heartbeat interval.
  final Duration tick;

  Timer? _timer;

  void start() {
    _timer ??= Timer.periodic(tick, (_) {
      // Errors are swallowed inside the engine's contract — unload must
      // never take the app down.
      _engine.unloadIfIdle(idle).catchError((_) {});
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Immediate unload — used when the app goes to background so the model
  /// frees RAM while the user is elsewhere.
  Future<void> unloadNow() =>
      _engine.unloadIfIdle(Duration.zero).catchError((_) {});
}

/// Keeps an [EngineIdleUnloader] alive for the current engine and disposes
/// it when the engine changes or the provider is dropped.
final engineLifecycleProvider = Provider<EngineIdleUnloader>((ref) {
  final unloader = EngineIdleUnloader(ref.watch(localAiEngineProvider));
  unloader.start();
  ref.onDispose(unloader.stop);
  return unloader;
});

/// Wraps the app: watches the engine lifecycle provider (so the heartbeat
/// runs while the app lives) and force-unloads the model on pause/detach.
class EngineLifecycleGuard extends ConsumerStatefulWidget {
  const EngineLifecycleGuard({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<EngineLifecycleGuard> createState() =>
      _EngineLifecycleGuardState();
}

class _EngineLifecycleGuardState extends ConsumerState<EngineLifecycleGuard>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Touch the provider so the heartbeat starts with the app.
    ref.read(engineLifecycleProvider);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      ref.read(engineLifecycleProvider).unloadNow();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
