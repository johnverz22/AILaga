import 'package:flutter/material.dart';
import '../../domain/measurement_entity.dart';
import '../../domain/measurement_type.dart';
import '../../../../core/utilities/date_utils.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Displays a single measurement reading in a themed card.
class MeasurementCard extends StatelessWidget {
  final MeasurementEntity measurement;
  final VoidCallback? onDelete;

  const MeasurementCard({
    super.key,
    required this.measurement,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final (icon, color) = _typeStyle(measurement.measurementType);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Type icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),

            // Value + label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _valueDisplay(measurement),
                        style: theme.textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        measurement.unit,
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        measurement.measurementType.displayLabel,
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _SourceBadge(sourceType: measurement.sourceType),
                    ],
                  ),
                  Text(
                    AppDateUtils.formatDateTime(measurement.measuredAt),
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                  ),
                  if (measurement.notes?.isNotEmpty == true)
                    Text(
                      measurement.notes!,
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.5),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Delete action — icon + word, never icon alone.
            if (onDelete != null)
              TextButton.icon(
                icon: Icon(Symbols.delete_rounded,
                    size: 20, color: cs.error.withValues(alpha: 0.7)),
                label: Text('Delete',
                    style:
                        TextStyle(color: cs.error.withValues(alpha: 0.8))),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }

  String _valueDisplay(MeasurementEntity m) {
    if (m.measurementType == MeasurementType.bloodPressure && m.value2 != null) {
      return '${m.value1.toStringAsFixed(0)}/${m.value2!.toStringAsFixed(0)}';
    }
    // Show 1 decimal for temp/weight/glucose, 0 for pulse/BP
    final needsDecimal = m.measurementType == MeasurementType.temperature ||
        m.measurementType == MeasurementType.weight ||
        m.measurementType == MeasurementType.bloodGlucose;
    return needsDecimal
        ? m.value1.toStringAsFixed(1)
        : m.value1.toStringAsFixed(0);
  }

  (IconData, Color) _typeStyle(MeasurementType type) {
    switch (type) {
      case MeasurementType.bloodPressure:
        return (Symbols.blood_pressure_rounded, const Color(0xFFDC2626));
      case MeasurementType.pulse:
        return (Symbols.monitor_heart_rounded, const Color(0xFFDB2777));
      case MeasurementType.temperature:
        return (Symbols.thermostat_rounded, const Color(0xFFD97706));
      case MeasurementType.weight:
        return (Symbols.monitor_weight_rounded, const Color(0xFF0891B2));
      case MeasurementType.bloodGlucose:
        return (Symbols.glucose_rounded, const Color(0xFF7C3AED));
    }
  }
}

class _SourceBadge extends StatelessWidget {
  final String sourceType;
  const _SourceBadge({required this.sourceType});

  @override
  Widget build(BuildContext context) {
    if (sourceType == 'manual') return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final label = sourceType == 'health_connect'
        ? 'Health Connect'
        : sourceType;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: cs.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: cs.secondary, fontSize: 10, fontWeight: FontWeight.w500),
      ),
    );
  }
}
