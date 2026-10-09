import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local_ai_engine.dart';
import 'engines/null_engine.dart';
import 'engines/gemma_litert_engine.dart';
import '../../../features/ai_setup/data/ai_setup_providers.dart';

/// Current AI engine — defaults to NullEngine (Basic mode).
/// Replaced at runtime by [resolvedEngineProvider] when a model is installed.
final localAiEngineProvider = StateProvider<LocalAiEngine>((ref) {
  return NullEngine();
});

/// Resolves which engine the app should use at startup:
/// Gemma LiteRT when a model file is installed AND the device probe says the
/// hardware can run it; otherwise NullEngine — Basic mode, always works.
final resolvedEngineProvider = FutureProvider<LocalAiEngine>((ref) async {
  final manager = ref.watch(modelManagerProvider);
  if (await manager.isInstalled) {
    final tier = await ref.watch(deviceTierProvider.future);
    if (tier != AiTier.basic) {
      return GemmaLiteRtEngine(
        modelPath: await manager.modelFilePath,
        deviceTier: tier,
      );
    }
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
