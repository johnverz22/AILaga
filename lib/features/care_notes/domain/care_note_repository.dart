import 'care_note_entity.dart';

abstract class CareNoteRepository {
  Future<List<CareNoteEntity>> getByRecipient(String recipientId);
  Future<List<CareNoteEntity>> getForDateRange(String recipientId, DateTime start, DateTime end);
  Future<CareNoteEntity?> getById(String id);
  Future<void> create(CareNoteEntity entity);
  Future<void> update(CareNoteEntity entity);
  Future<void> updateReviewStatus(String id, String status);
  Future<void> delete(String id);
  Stream<List<CareNoteEntity>> watchRecent(String recipientId, {int limit = 20});
}
