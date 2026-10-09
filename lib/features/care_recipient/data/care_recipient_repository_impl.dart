import '../../care_recipient/domain/care_recipient_entity.dart';
import '../../care_recipient/domain/care_recipient_repository.dart';
import '../../../core/database/app_database.dart';

class CareRecipientRepositoryImpl implements CareRecipientRepository {
  final AppDatabase _db;
  
  CareRecipientRepositoryImpl(this._db);

  @override
  Future<CareRecipientEntity?> getById(String id) {
    throw UnimplementedError('TODO: Implement getById');
  }

  @override
  Future<CareRecipientEntity?> getPrimary() {
    throw UnimplementedError('TODO: Implement getPrimary');
  }

  @override
  Future<List<CareRecipientEntity>> getAll() {
    throw UnimplementedError('TODO: Implement getAll');
  }

  @override
  Future<void> create(CareRecipientEntity entity) {
    throw UnimplementedError('TODO: Implement create');
  }

  @override
  Future<void> update(CareRecipientEntity entity) {
    throw UnimplementedError('TODO: Implement update');
  }

  @override
  Future<void> delete(String id) {
    throw UnimplementedError('TODO: Implement delete');
  }

  @override
  Stream<CareRecipientEntity?> watchPrimary() {
    throw UnimplementedError('TODO: Implement watchPrimary');
  }
}
