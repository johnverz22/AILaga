import 'package:flutter/material.dart';

/// Collapsible Ulat section: icon chip + title + count badge header, rows
/// separated by hairline dividers. Expanded by default.
class BriefSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final int? count;
  final List<Widget> children;
  final bool initiallyExpanded;

  const BriefSectionCard({
    super.key,
    required this.title,
    required this.icon,
    this.accent = const Color(0xFF0B6B6B),
    this.count,
    required this.children,
    this.initiallyExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        // Remove ExpansionTile's default top/bottom divider lines.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          title: Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: count == null ? null : Text('$count item(s)'),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          children: _withDividers(children),
        ),
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
