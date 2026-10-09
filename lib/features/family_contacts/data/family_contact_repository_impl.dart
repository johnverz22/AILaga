import '../../family_contacts/domain/family_contact_entity.dart';
import '../../family_contacts/domain/family_contact_repository.dart';
import '../../../core/database/app_database.dart';

class FamilyContactRepositoryImpl implements FamilyContactRepository {
  final AppDatabase _db;
  
  FamilyContactRepositoryImpl(this._db);

  @override
  Future<List<FamilyContactEntity>> getByCareRecipient(String recipientId) {
    throw UnimplementedError('TODO: Implement getByCareRecipient');
  }

  @override
  Future<List<FamilyContactEntity>> getEmergencyContacts(String recipientId) {
    throw UnimplementedError('TODO: Implement getEmergencyContacts');
  }

  @override
  Future<FamilyContactEntity?> getById(String id) {
    throw UnimplementedError('TODO: Implement getById');
  }

  @override
  Future<void> create(FamilyContactEntity entity) {
    throw UnimplementedError('TODO: Implement create');
  }

  @override
  Future<void> update(FamilyContactEntity entity) {
    throw UnimplementedError('TODO: Implement update');
  }

  @override
  Future<void> delete(String id) {
    throw UnimplementedError('TODO: Implement delete');
  }

  @override
  Future<void> reorder(List<String> orderedIds) {
    throw UnimplementedError('TODO: Implement reorder');
  }

  @override
  Stream<List<FamilyContactEntity>> watchByCareRecipient(String recipientId) {
    throw UnimplementedError('TODO: Implement watchByCareRecipient');
  }
}
