import 'package:flutter/material.dart';

import '../../../../services/ai/local/proposals/proposal_models.dart';

/// A card that shows one AI-proposed record for review.
class ProposalCard extends StatelessWidget {
  final ProposedRecord record;
  final VoidCallback? onConfirm;
  final VoidCallback? onDiscard;
  final VoidCallback? onEdit;

  const ProposalCard({
    super.key,
    required this.record,
    this.onConfirm,
    this.onDiscard,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSure = record.flag == ProposalFlag.sure;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSure
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.error.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: icon + type + flag badge
            Row(
              children: [
                Icon(_iconForRecord(record), size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _titleForRecord(record),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSure
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isSure ? 'Sure' : 'Check',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSure ? Colors.green.shade700 : Colors.orange.shade700,
                    ),
                    semanticsLabel: isSure ? 'High confidence' : 'Needs review',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Details
            Text(
              _detailsForRecord(record),
              style: theme.textTheme.bodyMedium,
            ),
            // Source quote
            if (record.sourceQuote.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '"${record.sourceQuote}"',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onDiscard != null)
                  IconButton(
                    onPressed: onDiscard,
                    icon: const Icon(Icons.close),
                    tooltip: 'Discard',
                    iconSize: 20,
                    style: IconButton.styleFrom(
                      minimumSize: const Size(48, 48),
                    ),
                  ),
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit',
                    iconSize: 20,
                    style: IconButton.styleFrom(
                      minimumSize: const Size(48, 48),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForRecord(ProposedRecord record) {
    if (record is ProposedMedicationTaken) return Icons.medication;
    if (record is ProposedMedicationSkipped) return Icons.medication_outlined;
    if (record is ProposedMeasurement) return Icons.monitor_heart;
    if (record is ProposedCareNote) return Icons.note_alt;
    if (record is ProposedAppointment) return Icons.calendar_today;
    if (record is ProposedMedicationSchedule) return Icons.schedule;
    return Icons.description;
  }

  String _titleForRecord(ProposedRecord record) {
    if (record is ProposedMedicationTaken) return 'Ininom: ${record.medicationName}';
    if (record is ProposedMedicationSkipped) return 'Na-skip: ${record.medicationName}';
    if (record is ProposedMeasurement) return _measurementTitle(record);
    if (record is ProposedCareNote) return 'Tala';
    if (record is ProposedAppointment) return 'Appointment';
    if (record is ProposedMedicationSchedule) return 'Bagong Gamot: ${record.name}';
    return 'Record';
  }

  String _measurementTitle(ProposedMeasurement m) {
    switch (m.type) {
      case 'blood_pressure': return 'BP: ${m.value1.toInt()}/${m.value2?.toInt() ?? "?"} ${m.unit}';
      case 'temperature': return 'Temp: ${m.value1}°${m.unit.toUpperCase()}';
      case 'blood_glucose': return 'Glucose: ${m.value1} ${m.unit}';
      case 'pulse': return 'Pulse: ${m.value1.toInt()} ${m.unit}';
      case 'weight': return 'Weight: ${m.value1} ${m.unit}';
      default: return '${m.type}: ${m.value1} ${m.unit}';
    }
  }

  String _detailsForRecord(ProposedRecord record) {
    if (record is ProposedMedicationTaken) {
      return record.timePhrase != null ? 'Time: ${record.timePhrase}' : 'Just now';
    }
    if (record is ProposedMedicationSkipped) {
      return record.reasonText ?? 'No reason given';
    }
    if (record is ProposedMeasurement) {
      return record.timePhrase != null ? 'Taken: ${record.timePhrase}' : 'Just now';
    }
    if (record is ProposedCareNote) return record.text;
    if (record is ProposedAppointment) {
      return '${record.provider ?? "Doctor"} — ${record.datetimePhrase}';
    }
    if (record is ProposedMedicationSchedule) {
      return '${record.strength ?? ""} ${record.instructionText ?? ""}';
    }
    return '';
  }
}
