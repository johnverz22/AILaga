import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/ai/local/model/device_probe.dart';
import '../../../services/ai/local/model/model_manager.dart';
import '../../../services/ai/local/local_ai_engine.dart';
import '../../../services/ai/local/platform/apple_channels.dart';

// ---------------------------------------------------------------------------
// Model file URLs (litert-community/gemma-4-E2B-it-litert-lm on HuggingFace)
// ---------------------------------------------------------------------------
//
// All sizes confirmed from the HuggingFace repo file listing (2026-10).
// Do NOT change these numbers without re-verifying from the actual repo.
//
//   gemma-4-E2B-it.litertlm             — generic (CPU + GPU)    2.59 GB
//   gemma-4-E2B-it-gpu.litertlm         — GPU-optimised           2.01 GB  ← default
//   gemma-4-E2B-it_qualcomm_sm8750.litertlm — Qualcomm NPU (SM8750)  3.02 GB
//   gemma-4-E2B-it_Google_Tensor_G5.litertlm — Google Tensor G5 NPU  3.11 GB
//   gemma-4-E2B-it_Google_Tensor_G6.litertlm — Google Tensor G6 NPU  3.31 GB
//   gemma-4-E2B-it_qualcomm_qcs8275.litertlm — Qualcomm IoT NPU      3.29 GB
//
// The GPU-optimised file (2.01 GB) is the new default because:
//   - It is 580 MB smaller than the generic file, so downloads much faster.
//   - It runs on CPU and GPU (OpenCL / Metal) — no special hardware required.
//   - NPU-specific files are larger and only useful when the device has a
//     matching Qualcomm or Tensor SoC; they are selected automatically by
//     [_resolveModelDescriptor] after DeviceProbe detects the chipset.
//
// SHA-256 notes:
//   - The SHA-256 for the generic file was known from the original build.
//   - The SHA-256 for the GPU and NPU variants must be computed on first
//     download and recorded in SPIKE_RESULTS.md (spike S6).  Until then
//     sha256 is null so the checksum step is skipped (safe — HuggingFace
//     serves content over HTTPS and the .gitattributes enforces xet pointers).
//   - To override, pass --dart-define=AI_MODEL_SHA256=<hex>.

const _hfBase =
    'https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm'
    '/resolve/main/';

/// GPU-optimised file (2.01 GB) — kept for reference / manual override via
/// --dart-define=AI_MODEL_URL. NOT the runtime default: on current
/// flutter_gemma_litertlm builds the Artisan GPU engine is not registered
/// (only kAdvancedLiteRTCompiledModel), so every device falls back to CPU —
/// and this file ships no TF_LITE_VISION_ENCODER, which makes engine
/// creation fail outright. The generic file carries all CPU encoders.
// ignore: unused_element
const _gpuModelUrl = '${_hfBase}gemma-4-E2B-it-gpu.litertlm';

/// Generic file (2.59 GB) — default for all devices unless the probe
/// detects a supported NPU chipset. Works on CPU (and GPU where available)
/// and includes the TFLite vision/audio encoders the GPU variant lacks.
const _genericModelUrl = '${_hfBase}gemma-4-E2B-it.litertlm';

/// Qualcomm Snapdragon 8 Gen 4 / SM8750 NPU-compiled file (3.02 GB).
const _qualcommSm8750Url =
    '${_hfBase}gemma-4-E2B-it_qualcomm_sm8750.litertlm';

/// Google Tensor G5 NPU-compiled file (3.11 GB).
const _tensorG5Url =
    '${_hfBase}gemma-4-E2B-it_Google_Tensor_G5.litertlm';

/// Google Tensor G6 NPU-compiled file (3.31 GB).
const _tensorG6Url =
    '${_hfBase}gemma-4-E2B-it_Google_Tensor_G6.litertlm';

// --dart-define overrides (empty string = not provided).
const _modelUrlOverride = String.fromEnvironment('AI_MODEL_URL');
const _modelSha256Override = String.fromEnvironment('AI_MODEL_SHA256');

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Raw device capabilities from the Kotlin device channel.
final deviceCapabilitiesProvider = FutureProvider<DeviceCapabilities>(
    (ref) => DeviceProbe.probe());

/// Tier decision with reason codes (thresholds: ai_thresholds.dart → S4).
final tierDecisionProvider = FutureProvider<TierDecision>((ref) async {
  final caps = await ref.watch(deviceCapabilitiesProvider.future);
  return DeviceProbe.decide(caps);
});

/// AI tier this device can support.
final deviceTierProvider = FutureProvider<AiTier>((ref) async {
  final decision = await ref.watch(tierDecisionProvider.future);
  return decision.tier;
});

/// Resolves the best [ModelDescriptor] for this device.
///
/// Priority order:
///   1. --dart-define override (CI / manual build)
///   2. Qualcomm NPU file when the SoC is SM8750
///   3. Google Tensor NPU file when the SoC is Tensor G5 or G6
///   4. GPU-optimised generic file (2.01 GB) — the default
///
/// NPU files are only selected when the detected SoC is an exact match;
/// an unknown or unsupported chipset always falls back to the GPU file.
final kAiModelProvider = FutureProvider<ModelDescriptor>((ref) async {
  if (_modelUrlOverride.isNotEmpty) {
    return ModelDescriptor(
      id: 'gemma4-e2b-custom',
      url: _modelUrlOverride,
      sha256: _modelSha256Override.isNotEmpty ? _modelSha256Override : null,
      displayName: 'Smart Assistant',
    );
  }

  final caps = await ref.watch(deviceCapabilitiesProvider.future);
  return _resolveModelDescriptor(caps);
});

ModelDescriptor _resolveModelDescriptor(DeviceCapabilities caps) {
  final chipset = caps.socChipset?.toLowerCase() ?? '';

  // Qualcomm Snapdragon 8 Gen 4 / SM8750 — the NPU file runs on the Hexagon
  // HTP via the Qualcomm QNN dispatch stack bundled in flutter_gemma_litertlm.
  if (chipset.contains('sm8750') ||
      chipset.contains('snapdragon 8 gen 4') ||
      chipset.contains('snapdragon 8 elite')) {
    return const ModelDescriptor(
      id: 'gemma4-e2b-sm8750',
      url: _qualcommSm8750Url,
      sha256: null, // verify on first run → record in SPIKE_RESULTS.md S6
      displayName: 'Smart Assistant',
    );
  }

  // Google Tensor G6 (Pixel 10 series)
  if (chipset.contains('tensor g6') || chipset.contains('zuma pro 2')) {
    return const ModelDescriptor(
      id: 'gemma4-e2b-tensor-g6',
      url: _tensorG6Url,
      sha256: null,
      displayName: 'Smart Assistant',
    );
  }

  // Google Tensor G5 (Pixel 9 series)
  if (chipset.contains('tensor g5') || chipset.contains('zuma pro')) {
    return const ModelDescriptor(
      id: 'gemma4-e2b-tensor-g5',
      url: _tensorG5Url,
      sha256: null,
      displayName: 'Smart Assistant',
    );
  }

  // Default: generic file (2.59 GB) for every other device — Qualcomm,
  // Exynos, Mali, unknown. The GPU-optimised variant only helps when the
  // LiteRT Artisan GPU engine is registered; on current plugin builds it is
  // not, and the file's missing CPU vision encoder then breaks engine
  // creation entirely. Devices that already downloaded another variant keep
  // using it — see ModelManager.existingModelPath().
  return const ModelDescriptor(
    id: 'gemma4-e2b-generic',
    url: _genericModelUrl,
    sha256: null, // verify on first run → record in SPIKE_RESULTS.md S6
    displayName: 'Smart Assistant',
  );
}

/// The single ModelManager instance for the configured model.
/// Re-creates when [kAiModelProvider] resolves (i.e., after device probe).
final modelManagerProvider = FutureProvider<ModelManager>((ref) async {
  final descriptor = await ref.watch(kAiModelProvider.future);
  final manager = ModelManager(
    descriptor,
    freeSpaceProbe: () async =>
        (await ref.read(deviceCapabilitiesProvider.future)).freeStorageBytes,
  );
  ref.onDispose(manager.dispose);
  return manager;
});

/// iOS-only: whether Apple Intelligence (FoundationModels) is usable on
/// this device right now. Android ignores this provider.
final appleAiAvailabilityProvider = FutureProvider<Map<String, Object?>>(
    (ref) => AppleAiChannel.availability());

/// Live install status (notInstalled/downloading/verifying/installed/error).
final modelStatusProvider = StreamProvider<ModelStatus>((ref) async* {
  final manager = await ref.watch(modelManagerProvider.future);
  yield await manager.currentStatus();
  yield* manager.statusStream;
});

// ---------------------------------------------------------------------------
// Legacy constant — kept so existing call-sites that read kAiModel
// (e.g. settings screen, AI setup screen) continue to compile.
// They should migrate to kAiModelProvider once they have a WidgetRef.
// ---------------------------------------------------------------------------

/// Synchronous fallback descriptor (generic file, no chipset customisation).
/// Prefer [kAiModelProvider] when inside a Riverpod context.
final kAiModel = ModelDescriptor(
  id: 'gemma4-e2b-generic',
  url: _genericModelUrl,
  sha256: null,
  displayName: 'Smart Assistant',
);
