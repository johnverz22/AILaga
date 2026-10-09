import 'care_recipient_entity.dart';

abstract class CareRecipientRepository {
  Future<CareRecipientEntity?> getById(String id);
  Future<CareRecipientEntity?> getPrimary();
  Future<List<CareRecipientEntity>> getAll();
  Future<void> create(CareRecipientEntity entity);
  Future<void> update(CareRecipientEntity entity);
  Future<void> delete(String id);
  Stream<CareRecipientEntity?> watchPrimary();
}
