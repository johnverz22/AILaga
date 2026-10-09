import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/ai/local/ai_providers.dart';
import '../../../../services/ai/local/local_ai_engine.dart';

/// On-device badge shown in the app bar.
/// Shows ✈ On-device when AI is running locally.
class OnDeviceBadge extends ConsumerWidget {
  const OnDeviceBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tierAsync = ref.watch(aiTierProvider);

    return tierAsync.when(
      data: (tier) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: tier == AiTier.basic
                ? Colors.grey.withValues(alpha: 0.2)
                : Colors.green.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: tier == AiTier.basic
                  ? Colors.grey.shade400
                  : Colors.green.shade400,
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                tier == AiTier.basic ? Icons.cloud_off : Icons.airplanemode_active,
                size: 14,
                color: tier == AiTier.basic ? Colors.grey : Colors.green.shade700,
              ),
              const SizedBox(width: 4),
              Text(
                tier == AiTier.basic ? 'Basic' : 'On-device',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: tier == AiTier.basic ? Colors.grey.shade600 : Colors.green.shade700,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
