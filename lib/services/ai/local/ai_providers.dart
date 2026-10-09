import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local_ai_engine.dart';
import 'engines/null_engine.dart';

/// Current AI engine — defaults to NullEngine (Basic mode).
/// Replaced at runtime by GemmaLiteRtEngine when model is loaded.
final localAiEngineProvider = StateProvider<LocalAiEngine>((ref) {
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
