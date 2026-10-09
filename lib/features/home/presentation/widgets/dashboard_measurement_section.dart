import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utilities/date_utils.dart';
import '../../../care_recipient/data/care_recipient_providers.dart';
import '../../../measurements/data/measurement_providers.dart';
import '../../../measurements/domain/measurement_entity.dart';
import '../../../measurements/domain/measurement_type.dart';
import 'dashboard_section.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

final recentMeasurementsProvider = StreamProvider.autoDispose<List<MeasurementEntity>>((ref) {
  final recipient = ref.watch(primaryCareRecipientProvider).value;
  if (recipient == null) return Stream.value([]);
  
  // Watch more recent ones to have a higher chance of getting one of each type
  return ref.watch(measurementRepositoryProvider).watchRecent(recipient.id, limit: 20);
});

class DashboardMeasurementSection extends ConsumerWidget {
  const DashboardMeasurementSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentMeasurementsAsync = ref.watch(recentMeasurementsProvider);

    return DashboardSection(
      icon: Symbols.monitor_heart_rounded,
      iconColor: const Color(0xFF1B7F3B),
      title: 'Recent Vitals',
      action: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton.icon(
            icon: const Icon(Symbols.add_rounded, size: 20),
            label: const Text('Add'),
            onPressed: () => context.push('/measurements/add'),
          ),
          TextButton(
            onPressed: () => context.push('/measurements'),
            child: const Text('All'),
          ),
        ],
      ),
      children: [
        recentMeasurementsAsync.when(
          data: (measurements) {
            if (measurements.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No measurements recorded'),
              );
            }

            // Get most recent of each type
            final Map<MeasurementType, MeasurementEntity> latestByType = {};
            for (final measurement in measurements) {
              final prev = latestByType[measurement.measurementType];
              if (prev == null ||
                  measurement.measuredAt.isAfter(prev.measuredAt)) {
                latestByType[measurement.measurementType] = measurement;
              }
            }

            final latestList = latestByType.values.toList()
              ..sort((a, b) => b.measuredAt.compareTo(a.measuredAt));

            return Column(
              children: [
                for (var i = 0; i < latestList.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    minVerticalPadding: 12,
                    leading: Icon(
                        _iconFor(latestList[i].measurementType),
                        color: const Color(0xFF0B6B6B),
                        size: 28),
                    title: Text(
                      '${latestList[i].value1} ${latestList[i].unit}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                        '${latestList[i].measurementType.displayLabel} • ${AppDateUtils.formatDateTime(latestList[i].measuredAt)}'),
                    trailing: const Icon(Symbols.chevron_right_rounded,
                        color: Colors.grey),
                    onTap: () => context.push('/measurements'),
                  ),
                ],
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => Center(child: Text('Something went wrong.')),
        ),
      ],
    );
  }

  static IconData _iconFor(MeasurementType type) {
    switch (type) {
      case MeasurementType.bloodPressure:
        return Symbols.blood_pressure_rounded;
      case MeasurementType.bloodGlucose:
        return Symbols.glucose_rounded;
      case MeasurementType.temperature:
        return Symbols.thermostat_rounded;
      case MeasurementType.pulse:
        return Symbols.monitor_heart_rounded;
      case MeasurementType.weight:
        return Symbols.monitor_weight_rounded;
    }
  }
}
