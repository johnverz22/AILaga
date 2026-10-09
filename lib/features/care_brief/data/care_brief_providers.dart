import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'deterministic_care_brief_service.dart';
final careBriefServiceProvider = Provider((ref) => DeterministicCareBriefService());
