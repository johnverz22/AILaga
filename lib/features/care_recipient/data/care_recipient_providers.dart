import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../domain/care_recipient_entity.dart';
import '../domain/care_recipient_repository.dart';
import 'care_recipient_repository_impl.dart';

final careRecipientRepositoryProvider = Provider<CareRecipientRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CareRecipientRepositoryImpl(db);
});

/// Watches the primary (first) care recipient — null if none exists
final primaryCareRecipientProvider = StreamProvider<CareRecipientEntity?>((ref) {
  final repo = ref.watch(careRecipientRepositoryProvider);
  return repo.watchPrimary();
});
