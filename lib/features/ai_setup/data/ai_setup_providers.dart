import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/ai/local/model/device_probe.dart';
import '../../../services/ai/local/model/model_manager.dart';
import '../../../services/ai/local/local_ai_engine.dart';
import '../../../services/ai/local/platform/apple_channels.dart';

/// The model this build downloads. Default: litert-community's public
/// Gemma 4 E2B `.litertlm` — no HuggingFace auth required (the google/
/// repos are gated). Per-device variants (gpu, Tensor G5/G6, Qualcomm)
/// live in the same repo; override the URL with --dart-define to ship one:
///   --dart-define=AI_MODEL_URL=... --dart-define=AI_MODEL_SHA256=...
/// Size is always read from the server/file, never hardcoded in the UI.
final kAiModel = ModelDescriptor(
  id: 'gemma4-e2b-litertlm',
  url: _modelUrlOverride.isEmpty ? _defaultModelUrl : _modelUrlOverride,
  // The default checksum only applies to the default file; an overridden
  // URL needs its own AI_MODEL_SHA256, else the check is skipped.
  sha256: _modelSha256Override.isNotEmpty
      ? _modelSha256Override
      : (_modelUrlOverride.isEmpty ? _defaultModelSha256 : null),
  displayName: 'Phone helper',
);

const _defaultModelUrl =
    'https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm'
    '/resolve/main/gemma-4-E2B-it.litertlm';

/// SHA-256 of gemma-4-E2B-it.litertlm at litert-community/main.
const _defaultModelSha256 =
    '181938105e0eefd105961417e8da75903eacda102c4fce9ce90f50b97139a63c';

const _modelUrlOverride = String.fromEnvironment('AI_MODEL_URL');
const _modelSha256Override = String.fromEnvironment('AI_MODEL_SHA256');

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

/// The single ModelManager instance for the configured model.
final modelManagerProvider = Provider<ModelManager>((ref) {
  final manager = ModelManager(
    kAiModel,
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
  final manager = ref.watch(modelManagerProvider);
  yield await manager.currentStatus();
  yield* manager.statusStream;
});
