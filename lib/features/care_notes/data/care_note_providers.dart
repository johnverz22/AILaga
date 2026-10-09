import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../domain/care_note_repository.dart';
import 'care_note_repository_impl.dart';

final careNoteRepositoryProvider = Provider<CareNoteRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CareNoteRepositoryImpl(db);
});
