import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Red SOS pill for the right side of every main app bar (UI spec:
/// "right = round red SOS button"). Icon + word, never icon alone.
class SosAppBarButton extends StatelessWidget {
  const SosAppBarButton({super.key});

  static const _sosRed = Color(0xFFC62828);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Center(
        child: Material(
          color: _sosRed,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => context.push('/emergency'),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Symbols.sos_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
