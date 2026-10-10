import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/care_recipient/data/care_recipient_providers.dart';
import '../features/ai_setup/data/ai_setup_providers.dart';
import '../services/ai/local/local_ai_engine.dart';
import '../services/ai/local/model/model_manager.dart';
import '../services/ai/local/platform/apple_channels.dart';

/// The boot-time readiness state of the app.
///
/// The router redirect and [SplashScreen] use this to decide the first
/// destination. Order of evaluation:
///   1. needsOnboarding — no care recipient yet
///   2. unsupportedDevice — device probe says tier = basic (Android)
///   3. modelReady — model is installed (Android) or Apple AI is active (iOS)
///   4. needsModelSetup — supported device, model not yet installed
enum AppReadyState {
  /// Care recipient has not been created yet — show Onboarding.
  needsOnboarding,

  /// Device hardware cannot run the model — proceed directly to Home in
  /// Basic mode. No download offered, no initialization screen looped.
  unsupportedDevice,

  /// Model is installed (Android) or Apple Intelligence is active (iOS).
  /// Everything is ready — proceed to HomeScreen.
  modelReady,

  /// Supported device but the model file is not yet installed.
  /// Show the InitializationScreen so the user can download it.
  needsModelSetup,
}

/// Combined readiness check run once per cold start (and reactively when
/// [modelStatusProvider] changes after a download completes or deletion).
///
/// This is the single authoritative signal for the router redirect and the
/// [SplashScreen] transition — nothing else should gate navigation.
final appReadyProvider = FutureProvider<AppReadyState>((ref) async {
  // --- 1. Care recipient check (fast — Drift in-memory cache) ---
  final recipientAsync = ref.watch(primaryCareRecipientProvider);
  if (recipientAsync.hasValue && recipientAsync.value == null) {
    return AppReadyState.needsOnboarding;
  }
  // Still loading: keep waiting (caller handles loading state).
  if (!recipientAsync.hasValue) {
    await recipientAsync.when(
      data: (_) async {},
      loading: () async {
        // Wait for it to settle — FutureProvider will rebuild when it does.
        await ref.watch(primaryCareRecipientProvider.future);
      },
      error: (_, __) async {},
    );
    final resolved = ref.read(primaryCareRecipientProvider);
    if (resolved.hasValue && resolved.value == null) {
      return AppReadyState.needsOnboarding;
    }
  }

  // --- 2. iOS: Apple Intelligence instead of a file download ---
  if (Platform.isIOS) {
    final available = await AppleAiChannel.isAvailable();
    // Whether or not Apple AI is ready the app is usable — no download loop.
    return available ? AppReadyState.modelReady : AppReadyState.unsupportedDevice;
  }

  // --- 3. Android: device probe ---
  try {
    final tier = await ref.watch(deviceTierProvider.future);
    if (tier == AiTier.basic) {
      return AppReadyState.unsupportedDevice;
    }
  } catch (_) {
    // Probe failure → treat as unsupported so we don't loop the init screen.
    return AppReadyState.unsupportedDevice;
  }

  // --- 4. Android: model file ---
  try {
    final status = await ref.watch(modelStatusProvider.future);
    if (status.state == ModelInstallState.installed) {
      return AppReadyState.modelReady;
    }
  } catch (_) {
    // Status stream error → assume not installed.
  }

  return AppReadyState.needsModelSetup;
});
