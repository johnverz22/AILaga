import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../domain/emergency_repository.dart';
import 'emergency_repository_impl.dart';

final emergencyRepositoryProvider = Provider<EmergencyRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return EmergencyRepositoryImpl(db);
});
