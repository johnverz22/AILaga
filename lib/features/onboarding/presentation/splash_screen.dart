import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../app/app_ready_provider.dart';

/// Branded launch splash — warm white, app mark in a teal ring,
/// tagline, then hands off to the correct destination once providers resolve.
///
/// Navigation is driven by [appReadyProvider]:
///   • needsOnboarding   → /onboarding
///   • needsModelSetup   → /initialization
///   • unsupportedDevice → / (Basic mode, skip init screen)
///   • modelReady        → /
///
/// The animation plays for at least [_minDisplayMs] so the brand mark is
/// readable, but navigation waits for the providers to be ready — fixing the
/// race condition where the old fixed 1600 ms timer could fire before the
/// Drift database finished its first migration.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _teal = Color(0xFF0B6B6B);
  static const _indigo = Color(0xFF2F4B8A);
  static const _minDisplayMs = 1400;

  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  bool _animDone = false;
  bool _readyResolved = false;
  AppReadyState? _readyState;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();

    // Minimum display time so the animation can complete gracefully.
    Timer(const Duration(milliseconds: _minDisplayMs), () {
      _animDone = true;
      _maybeNavigate();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Called both when the animation minimum time passes AND when the
  /// provider resolves — whichever is last triggers navigation.
  void _maybeNavigate() {
    if (!_animDone || !_readyResolved || !mounted) return;
    switch (_readyState!) {
      case AppReadyState.needsOnboarding:
        context.go('/onboarding');
      case AppReadyState.needsModelSetup:
        context.go('/initialization');
      case AppReadyState.unsupportedDevice:
      case AppReadyState.modelReady:
        context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the combined readiness provider. When it resolves, attempt
    // navigation (guarded by the minimum display time above).
    ref.listen<AsyncValue<AppReadyState>>(appReadyProvider, (_, next) {
      next.whenData((state) {
        _readyState = state;
        _readyResolved = true;
        _maybeNavigate();
      });
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF8),
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _teal, width: 3),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/branding/app_mark.png',
                        width: 160,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Symbols.health_and_safety_rounded,
                          size: 96,
                          color: _teal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'AILaga',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Symbols.favorite_rounded, size: 18, color: _indigo),
                      SizedBox(width: 6),
                      Text(
                        'Care for Lola',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: _teal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
