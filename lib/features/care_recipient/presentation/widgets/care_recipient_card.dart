import 'package:flutter/material.dart';
import '../../domain/care_recipient_entity.dart';
import '../../../../core/utilities/date_utils.dart';

/// Displays a care recipient summary in a themed card.
class CareRecipientCard extends StatelessWidget {
  final CareRecipientEntity recipient;
  final VoidCallback? onEdit;

  const CareRecipientCard({
    super.key,
    required this.recipient,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colorScheme.primary.withOpacity(0.12),
                  child: Text(
                    _initials(recipient.displayName),
                    style: theme.textTheme.titleLarge!.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipient.displayName,
                        style: theme.textTheme.titleLarge,
                      ),
                      if (recipient.dateOfBirth != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Born ${AppDateUtils.formatDate(recipient.dateOfBirth!)} · '
                          'Age ${_age(recipient.dateOfBirth!)}',
                          style: theme.textTheme.bodySmall!.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit profile',
                  ),
              ],
            ),
            if (_hasDetails(recipient)) ...[
              const Divider(height: 28),
              if (recipient.allergies?.isNotEmpty == true) ...[
                _detailRow(
                  context,
                  icon: Icons.warning_amber_rounded,
                  iconColor: const Color(0xFFD97706),
                  label: 'Allergies',
                  value: recipient.allergies!,
                ),
                const SizedBox(height: 12),
              ],
              if (recipient.importantNotes?.isNotEmpty == true) ...[
                _detailRow(
                  context,
                  icon: Icons.notes_rounded,
                  iconColor: colorScheme.primary,
                  label: 'Important Notes',
                  value: recipient.importantNotes!,
                ),
                const SizedBox(height: 12),
              ],
              if (recipient.emergencyInfo?.isNotEmpty == true)
                _detailRow(
                  context,
                  icon: Icons.local_hospital_outlined,
                  iconColor: colorScheme.error,
                  label: 'Emergency Info',
                  value: recipient.emergencyInfo!,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelLarge!.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  bool _hasDetails(CareRecipientEntity r) =>
      r.allergies?.isNotEmpty == true ||
      r.importantNotes?.isNotEmpty == true ||
      r.emergencyInfo?.isNotEmpty == true;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  int _age(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }
}
