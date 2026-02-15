import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_data_source.dart';

part 'account_repository_impl.g.dart';

@riverpod
AccountRepository accountRepository(Ref ref) {
  final remoteDataSource = ref.watch(accountRemoteDataSourceProvider);
  return AccountRepositoryImpl(remoteDataSource);
}

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource _remoteDataSource;

  AccountRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AccountEntity>> getAccounts() async {
    final models = await _remoteDataSource.fetchAccounts();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<AccountEntity> getAccount(String id) async {
    final model = await _remoteDataSource.fetchAccount(id);
    return model.toEntity();
  }
}
