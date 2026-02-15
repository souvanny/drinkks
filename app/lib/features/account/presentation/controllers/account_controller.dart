import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/usecases/get_accounts_usecase.dart';

part 'account_controller.g.dart';

@riverpod
class AccountController extends _$AccountController {
  @override
  FutureOr<List<AccountEntity>> build() {
    return ref.watch(getAccountsProvider.future);
  }
  
  Future<void> refresh() async {
     state = const AsyncValue.loading();
     state = await AsyncValue.guard(() => ref.refresh(getAccountsProvider.future));
  }
}
