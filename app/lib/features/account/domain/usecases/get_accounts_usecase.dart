import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/account_entity.dart';
import '../repositories/account_repository.dart';
import '../../data/repositories/account_repository_impl.dart';

part 'get_accounts_usecase.g.dart';

@riverpod
Future<List<AccountEntity>> getAccounts(Ref ref) {
  return ref.watch(accountRepositoryProvider).getAccounts();
}
