import 'family_contact_entity.dart';

abstract class FamilyContactRepository {
  Future<List<FamilyContactEntity>> getByCareRecipient(String recipientId);
  Future<List<FamilyContactEntity>> getEmergencyContacts(String recipientId);
  Future<FamilyContactEntity?> getById(String id);
  Future<void> create(FamilyContactEntity entity);
  Future<void> update(FamilyContactEntity entity);
  Future<void> delete(String id);
  Future<void> reorder(List<String> orderedIds);
  Stream<List<FamilyContactEntity>> watchByCareRecipient(String recipientId);
}
