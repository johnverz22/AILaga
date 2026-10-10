import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'local_ai_engine.dart';
import 'engines/null_engine.dart';
import 'engines/gemma_litert_engine.dart';
import 'engines/apple_ai_engine.dart';
import 'platform/apple_channels.dart';
import 'model/model_manager.dart';
import 'model/device_probe.dart';
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
///
/// Backend selection:
/// - Qualcomm NPU-compiled files (sm8750) → [AiPreferredBackend.npu]
/// - All other files (gpu, G5, G6, generic) → [AiPreferredBackend.gpu]
///   (GPU / OpenCL on Android; Metal on iOS — ~7× faster prefill than CPU)
///
/// The LiteRT runtime falls back to CPU transparently if the requested
/// backend is unavailable, so this is always safe.
final resolvedEngineProvider = FutureProvider<LocalAiEngine>((ref) async {
  try {
    // iOS path: Apple Intelligence is built into the OS — no model file.
    // Gate = FoundationModels availability + hardware probe; otherwise Basic.
    if (Platform.isIOS) {
      if (!await AppleAiChannel.isAvailable()) return NullEngine();
      final tier = await ref.watch(deviceTierProvider.future);
      if (tier == AiTier.basic) return NullEngine();
      return AppleAiEngine(deviceTier: tier);
    }

    // Android path: wait for the async model manager.
    final manager = await ref.watch(modelManagerProvider.future);

    // Re-run only when the install STATE changes — watching the raw status
    // stream would re-resolve the engine on every progress tick during a
    // download and churn every screen that touches the AI providers.
    final installState = await ref.watch(
        modelStatusProvider.selectAsync((s) => s.state));
    if (installState == ModelInstallState.installed ||
        await manager.isInstalled) {
      final tier = await ref.watch(deviceTierProvider.future);
      if (tier != AiTier.basic) {
        // Use the file that is actually on disk — it may be a different
        // variant than the resolved descriptor (e.g. the GPU file installed
        // before the default changed to generic). The engine sheds any
        // modality the file doesn't support, so it is still usable.
        final path = await manager.existingModelPath();
        if (path != null) {
          final caps = await ref.watch(deviceCapabilitiesProvider.future);
          final fileId = p.basenameWithoutExtension(path);
          return GemmaLiteRtEngine(
            modelPath: path,
            modelId: fileId,
            deviceTier: tier,
            preferredBackend: _backendFor(fileId, caps),
          );
        }
      }
    }
  } catch (_) {
    // Probe/manager failure (off-platform, storage error) → Basic mode.
  }
  return NullEngine();
});

/// Picks the right inference backend based on the model variant that was
/// downloaded.  NPU-compiled variants require [AiPreferredBackend.npu]; all
/// others use [AiPreferredBackend.gpu] (OpenCL / Metal).
AiPreferredBackend _backendFor(String modelId, DeviceCapabilities caps) {
  // Qualcomm NPU model files are explicitly compiled for the Hexagon HTP and
  // MUST run with PreferredBackend.npu — running them on GPU gives errors.
  final socChipset = caps.socChipset ?? '';
  if (modelId.contains('sm8750') || modelId.contains('qcs8275')) {
    // Only use NPU when we know the hardware matches; fall back to GPU if the
    // SoC string doesn't confirm it (e.g. unexpected socModel format).
    if (socChipset.contains('sm8750') ||
        socChipset.contains('qcs8275') ||
        socChipset.contains('snapdragon 8')) {
      return AiPreferredBackend.npu;
    }
    // SoC mismatch (unexpected) → GPU fallback, safer than CPU.
    return AiPreferredBackend.gpu;
  }
  // GPU-optimised and Tensor G5/G6 variants: use GPU (OpenCL / Metal).
  return AiPreferredBackend.gpu;
}

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
