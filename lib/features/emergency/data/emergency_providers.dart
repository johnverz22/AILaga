import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../domain/emergency_repository.dart';
import '../domain/emergency_service.dart';
import 'emergency_repository_impl.dart';
import 'emergency_service_impl.dart';

final emergencyRepositoryProvider = Provider<EmergencyRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return EmergencyRepositoryImpl(db);
});

final emergencyServiceProvider = Provider<EmergencyService>((ref) {
  final repo = ref.watch(emergencyRepositoryProvider);
  return EmergencyServiceImpl(repo);
});
