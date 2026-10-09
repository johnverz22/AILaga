import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/ai/local/model/device_probe.dart';
import '../../../services/ai/local/model/model_manager.dart';
import '../../../services/ai/local/local_ai_engine.dart';

/// The model this build downloads. URL is a placeholder until the team picks
/// a host; sha256 comes from the release process (S6 spike notes).
const kAiModel = ModelDescriptor(
  id: 'gemma4-e2b-litertlm',
  // TODO: replace with the real model URL before shipping; size is always
  // read from the server/file, never hardcoded in the UI.
  url: _placeholderModelUrl,
  displayName: 'Phone helper',
);

const _placeholderModelUrl =
    String.fromEnvironment('AI_MODEL_URL', defaultValue: '');

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

/// Live install status (notInstalled/downloading/verifying/installed/error).
final modelStatusProvider = StreamProvider<ModelStatus>((ref) async* {
  final manager = ref.watch(modelManagerProvider);
  yield await manager.currentStatus();
  yield* manager.statusStream;
});
