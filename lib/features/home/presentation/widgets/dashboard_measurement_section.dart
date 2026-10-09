import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utilities/date_utils.dart';
import '../../../care_recipient/data/care_recipient_providers.dart';
import '../../../measurements/data/measurement_providers.dart';
import '../../../measurements/domain/measurement_entity.dart';
import '../../../measurements/domain/measurement_type.dart';

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
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Vitals', style: theme.textTheme.titleMedium),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => context.push('/measurements/add'),
                      tooltip: 'Add Measurement',
                    ),
                    TextButton(
                      onPressed: () => context.push('/measurements'),
                      child: const Text('All'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            recentMeasurementsAsync.when(
              data: (measurements) {
                if (measurements.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No measurements recorded'),
                    ),
                  );
                }
                
                // Get most recent of each type
                final Map<MeasurementType, MeasurementEntity> latestByType = {};
                for (final measurement in measurements) {
                  if (!latestByType.containsKey(measurement.measurementType)) {
                    latestByType[measurement.measurementType] = measurement;
                  } else {
                    if (measurement.measuredAt.isAfter(latestByType[measurement.measurementType]!.measuredAt)) {
                      latestByType[measurement.measurementType] = measurement;
                    }
                  }
                }
                
                final latestList = latestByType.values.toList()
                  ..sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
                  
                return Column(
                  children: latestList.map((measurement) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.monitor_weight_outlined, color: Colors.purple),
                    title: Text('${measurement.value1} ${measurement.unit}'),
                    subtitle: Text('${measurement.measurementType.name.toUpperCase()} • ${AppDateUtils.formatDateTime(measurement.measuredAt)}'),
                    onTap: () => context.push('/measurements'),
                  )).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ],
        ),
      ),
    );
  }
}
