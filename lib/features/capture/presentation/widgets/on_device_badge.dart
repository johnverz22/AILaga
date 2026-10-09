import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// "On phone" shield badge for the left side of main app bars
/// (UI spec). Everything in this app is stored locally — this is
/// always true, so the badge never depends on helper/engine state.
class OnDeviceBadge extends StatelessWidget {
  const OnDeviceBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EFE6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD9D2C3), width: 1.5),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.shield_rounded,
                size: 16, color: Color(0xFF0B6B6B)),
            SizedBox(width: 4),
            Text(
              'On phone',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
