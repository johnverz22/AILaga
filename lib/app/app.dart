import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai/local/ai_providers.dart';
import 'router.dart';
import 'theme.dart';

class AilagaApp extends ConsumerWidget {
  const AilagaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Swap in the real engine once startup resolution finishes
    // (installed model + capable device → Gemma; otherwise stays Basic).
    ref.listen(resolvedEngineProvider, (_, next) {
      next.whenData((engine) {
        ref.read(localAiEngineProvider.notifier).state = engine;
      });
    });
    
    return MaterialApp.router(
      title: 'AILaga',
      theme: appTheme,
      darkTheme: darkAppTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
