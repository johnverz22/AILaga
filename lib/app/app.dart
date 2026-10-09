import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai/local/ai_providers.dart';
import '../services/ai/local/engine_lifecycle.dart';
import 'router.dart';
import 'theme.dart';

class AilagaApp extends ConsumerWidget {
  const AilagaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Swap in the real engine once startup resolution finishes
    // (installed model + capable device → Gemma; otherwise stays Basic).
    // Dedupe by engineId: a same-kind re-resolution (e.g. install state
    // flipping during download) must not churn every AI-watching screen.
    ref.listen(resolvedEngineProvider, (_, next) {
      next.whenData((engine) {
        if (ref.read(localAiEngineProvider).engineId != engine.engineId) {
          ref.read(localAiEngineProvider.notifier).state = engine;
        }
      });
    });
    
    // EngineLifecycleGuard starts the 60 s idle-unload heartbeat and
    // force-unloads the model when the app goes to background.
    return EngineLifecycleGuard(
      child: MaterialApp.router(
        title: 'AILaga',
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        darkTheme: darkAppTheme,
        themeMode: ThemeMode.system,
        routerConfig: router,
      ),
    );
  }
}
