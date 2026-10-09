import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../domain/appointment_entity.dart';
import '../domain/appointment_repository.dart';
import 'appointment_repository_impl.dart';

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AppointmentRepositoryImpl(db);
});

/// Watches all upcoming scheduled appointments for a recipient.
final upcomingAppointmentsProvider =
    StreamProvider.family<List<AppointmentEntity>, String>(
  (ref, recipientId) {
    final repo = ref.watch(appointmentRepositoryProvider);
    return repo.watchUpcoming(recipientId);
  },
);
