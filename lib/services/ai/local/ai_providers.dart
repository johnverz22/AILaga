import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local_ai_engine.dart';
import 'engines/null_engine.dart';
import 'engines/gemma_litert_engine.dart';
import 'model/model_manager.dart';
import '../../../features/ai_setup/data/ai_setup_providers.dart';

/// Current AI engine — defaults to NullEngine (Basic mode).
/// Replaced at runtime by [resolvedEngineProvider] when a model is installed.
final localAiEngineProvider = StateProvider<LocalAiEngine>((ref) {
  return NullEngine();
});

/// Resolves which engine the app should use:
/// Gemma LiteRT when a model file is installed AND the device probe says the
/// hardware can run it; otherwise NullEngine — Basic mode, always works.
///
/// Watches [modelStatusProvider] so install/delete re-resolves the engine
/// live (no stale "model installed" state). Any failure → Basic.
final resolvedEngineProvider = FutureProvider<LocalAiEngine>((ref) async {
  try {
    final manager = ref.watch(modelManagerProvider);
    // Re-run on every install-status change (download done, deleted, …).
    final status = await ref.watch(modelStatusProvider.future);
    if (status.state == ModelInstallState.installed ||
        await manager.isInstalled) {
      final tier = await ref.watch(deviceTierProvider.future);
      if (tier != AiTier.basic) {
        return GemmaLiteRtEngine(
          modelPath: await manager.modelFilePath,
          deviceTier: tier,
        );
      }
    }
  } catch (_) {
    // Probe/manager failure (off-platform, storage error) → Basic mode.
  }
  return NullEngine();
});

/// Current AI tier derived from the engine.
final aiTierProvider = FutureProvider<AiTier>((ref) async {
  final engine = ref.watch(localAiEngineProvider);
  return engine.tier();
});

/// Whether AI is available (not basic mode).
final isAiAvailableProvider = FutureProvider<bool>((ref) async {
  final tier = await ref.watch(aiTierProvider.future);
  return tier != AiTier.basic;
});
