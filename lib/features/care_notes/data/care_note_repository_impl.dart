import '../../care_notes/domain/care_note_entity.dart';
import '../../care_notes/domain/care_note_repository.dart';
import '../../../core/database/app_database.dart';

class CareNoteRepositoryImpl implements CareNoteRepository {
  final AppDatabase _db;
  
  CareNoteRepositoryImpl(this._db);

  @override
  Future<List<CareNoteEntity>> getByRecipient(String recipientId) {
    throw UnimplementedError('TODO: Implement getByRecipient');
  }

  @override
  Future<List<CareNoteEntity>> getForDateRange(String recipientId, DateTime start, DateTime end) {
    throw UnimplementedError('TODO: Implement getForDateRange');
  }

  @override
  Future<CareNoteEntity?> getById(String id) {
    throw UnimplementedError('TODO: Implement getById');
  }

  @override
  Future<void> create(CareNoteEntity entity) {
    throw UnimplementedError('TODO: Implement create');
  }

  @override
  Future<void> update(CareNoteEntity entity) {
    throw UnimplementedError('TODO: Implement update');
  }

  @override
  Future<void> updateReviewStatus(String id, String status) {
    throw UnimplementedError('TODO: Implement updateReviewStatus');
  }

  @override
  Future<void> delete(String id) {
    throw UnimplementedError('TODO: Implement delete');
  }

  @override
  Stream<List<CareNoteEntity>> watchRecent(String recipientId, {int limit = 20}) {
    throw UnimplementedError('TODO: Implement watchRecent');
  }
}
