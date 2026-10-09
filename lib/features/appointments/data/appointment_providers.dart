import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../domain/appointment_repository.dart';
import 'appointment_repository_impl.dart';

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AppointmentRepositoryImpl(db);
});
