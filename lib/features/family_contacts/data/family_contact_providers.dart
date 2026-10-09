import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../domain/family_contact_entity.dart';
import '../domain/family_contact_repository.dart';
import 'family_contact_repository_impl.dart';

final familyContactRepositoryProvider = Provider<FamilyContactRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return FamilyContactRepositoryImpl(db);
});

/// Watches all family contacts for the given care recipient id.
final familyContactsProvider =
    StreamProvider.family<List<FamilyContactEntity>, String>(
  (ref, recipientId) {
    final repo = ref.watch(familyContactRepositoryProvider);
    return repo.watchByCareRecipient(recipientId);
  },
);
