import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../../app/app_ready_provider.dart';

/// A tappable amber banner shown when the Phone helper has not yet been set up
/// on a supported device. It disappears automatically once the model is
/// installed (driven reactively by [appReadyProvider]).
///
/// Rules:
/// - Not shown on unsupported devices (they're permanently in Basic mode).
/// - Not shown when the model is already installed.
/// - Taps navigate to /initialization to start or resume the download.
class PhoneHelperSetupBanner extends ConsumerWidget {
  const PhoneHelperSetupBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyAsync = ref.watch(appReadyProvider);

    return readyAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (state) {
        if (state != AppReadyState.needsModelSetup) {
          return const SizedBox.shrink();
        }
        return _Banner(
          onTap: () => context.push('/initialization'),
        );
      },
    );
  }
}

class _Banner extends StatelessWidget {
  final VoidCallback onTap;
  const _Banner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFFFFF3E0), // amber-50 tone
            border: Border(
              bottom: BorderSide(color: Color(0xFFFFB300), width: 1.5),
            ),
          ),
          child: Row(
            children: [
              const Icon(Symbols.phonelink_lock_rounded,
                  size: 24, color: Color(0xFF9A5B00)),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Phone helper not ready',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9A5B00),
                  ),
                ),
              ),
              const Text(
                'Set up',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B6B6B),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Symbols.chevron_right_rounded,
                  size: 20, color: Color(0xFF0B6B6B)),
            ],
          ),
        ),
      ),
    );
  }
}
