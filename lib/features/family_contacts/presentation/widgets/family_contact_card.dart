import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/family_contact_entity.dart';

/// A list tile card for a single family contact.
///
/// Shows name, relationship, phone number, emergency badge,
/// and quick-action buttons to call or SMS.
class FamilyContactCard extends StatelessWidget {
  final FamilyContactEntity contact;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FamilyContactCard({
    super.key,
    required this.contact,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: contact.isEmergencyContact
                  ? colorScheme.error.withValues(alpha: 0.12)
                  : colorScheme.primary.withValues(alpha: 0.10),
              child: Text(
                _initials(contact.displayName),
                style: theme.textTheme.titleMedium!.copyWith(
                  color: contact.isEmergencyContact
                      ? colorScheme.error
                      : colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          contact.displayName,
                          style: theme.textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (contact.isEmergencyContact) ...[
                        const SizedBox(width: 6),
                        _emergencyBadge(context),
                      ],
                    ],
                  ),
                  if (contact.relationship?.isNotEmpty == true)
                    Text(
                      contact.relationship!,
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    contact.phoneNumber,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Action buttons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _iconBtn(
                      context,
                      icon: Icons.call_outlined,
                      color: colorScheme.primary,
                      tooltip: 'Call',
                      onPressed: () => _call(contact.phoneNumber),
                    ),
                    _iconBtn(
                      context,
                      icon: Icons.sms_outlined,
                      color: colorScheme.secondary,
                      tooltip: 'SMS',
                      onPressed: () => _sms(contact.phoneNumber),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onEdit != null)
                      _iconBtn(
                        context,
                        icon: Icons.edit_outlined,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        tooltip: 'Edit',
                        onPressed: onEdit!,
                      ),
                    if (onDelete != null)
                      _iconBtn(
                        context,
                        icon: Icons.delete_outline,
                        color: colorScheme.error.withValues(alpha: 0.7),
                        tooltip: 'Delete',
                        onPressed: onDelete!,
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _emergencyBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Emergency',
        style: TextStyle(
          color: colorScheme.error,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _iconBtn(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, size: 20),
      color: color,
      tooltip: tooltip,
      onPressed: onPressed,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sms(String phone) async {
    final uri = Uri(scheme: 'sms', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
