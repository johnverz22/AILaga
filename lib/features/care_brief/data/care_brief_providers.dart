import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/care_brief_service.dart';
import 'deterministic_care_brief_service.dart';
import '../../care_recipient/data/care_recipient_providers.dart';
import '../../medications/data/medication_providers.dart';
import '../../measurements/data/measurement_providers.dart';
import '../../appointments/data/appointment_providers.dart';
import '../../care_notes/data/care_note_providers.dart';

final careBriefServiceProvider = Provider<CareBriefService>((ref) {
  return DeterministicCareBriefService(
    ref.watch(careRecipientRepositoryProvider),
    ref.watch(medicationRepositoryProvider),
    ref.watch(measurementRepositoryProvider),
    ref.watch(appointmentRepositoryProvider),
    ref.watch(careNoteRepositoryProvider),
  );
});
