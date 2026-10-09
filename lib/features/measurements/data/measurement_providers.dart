import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../domain/measurement_entity.dart';
import '../domain/measurement_repository.dart';
import '../domain/measurement_type.dart';
import 'measurement_repository_impl.dart';

final measurementRepositoryProvider = Provider<MeasurementRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return MeasurementRepositoryImpl(db);
});

/// Watches the most recent [limit] measurements for the given care recipient.
final recentMeasurementsProvider =
    StreamProvider.family<List<MeasurementEntity>, String>(
  (ref, recipientId) {
    final repo = ref.watch(measurementRepositoryProvider);
    return repo.watchRecent(recipientId, limit: 20);
  },
);

/// Provider family: (recipientId, type) → latest single measurement of that type.
final latestMeasurementProvider =
    FutureProvider.family<MeasurementEntity?, (String, MeasurementType)>(
  (ref, args) {
    final repo = ref.watch(measurementRepositoryProvider);
    return repo.getLatest(args.$1, args.$2);
  },
);
