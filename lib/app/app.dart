import 'package:flutter/material.dart';
import 'router.dart';
import 'theme.dart';

class AilagaApp extends StatelessWidget {
  const AilagaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AILaga',
      theme: appTheme,
      routerConfig: appRouter,
    );
  }
}
