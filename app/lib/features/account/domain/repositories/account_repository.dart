import '../entities/account_entity.dart';

abstract class AccountRepository {
  Future<List<AccountEntity>> getAccounts();
  Future<AccountEntity> getAccount(String id);
}
