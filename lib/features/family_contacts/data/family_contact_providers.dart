import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../domain/family_contact_repository.dart';
import 'family_contact_repository_impl.dart';

final familyContactRepositoryProvider = Provider<FamilyContactRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return FamilyContactRepositoryImpl(db);
});
