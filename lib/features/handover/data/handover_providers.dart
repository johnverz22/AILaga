import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'deterministic_handover_service.dart';
final handoverServiceProvider = Provider((ref) => DeterministicHandoverService());
