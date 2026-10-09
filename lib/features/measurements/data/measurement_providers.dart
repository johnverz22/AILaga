import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../domain/measurement_repository.dart';
import 'measurement_repository_impl.dart';

final measurementRepositoryProvider = Provider<MeasurementRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return MeasurementRepositoryImpl(db);
});
