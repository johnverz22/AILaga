import 'package:flutter/material.dart';

/// Shared shell for Ngayon (Today) dashboard cards: icon chip + title +
/// optional trailing action, with children separated by hairline dividers.
class DashboardSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget? action;
  final List<Widget> children;

  const DashboardSection({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.action,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
                if (action != null) action!,
              ],
            ),
          ),
          ..._withDividers(children),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  List<Widget> _withDividers(List<Widget> items) {
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) {
        out.add(const Divider(height: 1, indent: 16, endIndent: 16));
      }
      out.add(items[i]);
    }
    return out;
  }
}

/// Small status pill: colored text on a tinted background.
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatusChip(this.label, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
