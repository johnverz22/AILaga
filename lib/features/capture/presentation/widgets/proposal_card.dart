import 'package:flutter/material.dart';

import '../../../../services/ai/local/proposals/proposal_models.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

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
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isSure
              ? theme.colorScheme.primary.withValues(alpha: 0.4)
              : theme.colorScheme.error.withValues(alpha: 0.6),
          width: 2,
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
                  // Icon + word: never color alone (a11y spec).
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSure ? Symbols.check_circle_rounded : Symbols.warning_amber_rounded,
                        size: 12,
                        color: isSure
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isSure ? 'Sure' : 'Check',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSure
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                        semanticsLabel:
                            isSure ? 'High confidence' : 'Needs review',
                      ),
                    ],
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
            // Action buttons — icon + word, never icon alone.
            // Wrap keeps them usable when large text overflows one line.
            Wrap(
              alignment: WrapAlignment.end,
              children: [
                if (onDiscard != null)
                  TextButton.icon(
                    onPressed: onDiscard,
                    icon: const Icon(Symbols.close_rounded, size: 22),
                    label: const Text('Discard'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      minimumSize: const Size(48, 48),
                    ),
                  ),
                if (onEdit != null)
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Symbols.edit_rounded, size: 22),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
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
    if (record is ProposedMedicationTaken) return Symbols.medication_rounded;
    if (record is ProposedMedicationSkipped) return Symbols.medication_rounded;
    if (record is ProposedMeasurement) return Symbols.monitor_heart_rounded;
    if (record is ProposedCareNote) return Symbols.note_alt_rounded;
    if (record is ProposedAppointment) return Symbols.calendar_today_rounded;
    if (record is ProposedMedicationSchedule) return Symbols.schedule_rounded;
    return Symbols.description_rounded;
  }

  String _titleForRecord(ProposedRecord record) {
    if (record is ProposedMedicationTaken) return 'Took: ${record.medicationName}';
    if (record is ProposedMedicationSkipped) return 'Skipped: ${record.medicationName}';
    if (record is ProposedMeasurement) return _measurementTitle(record);
    if (record is ProposedCareNote) return 'Note';
    if (record is ProposedAppointment) return 'Appointment';
    if (record is ProposedMedicationSchedule) return 'New medicine: ${record.name}';
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
