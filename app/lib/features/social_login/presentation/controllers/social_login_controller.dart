import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/social_login_entity.dart';
import '../../domain/usecases/get_social_logins_usecase.dart';

part 'social_login_controller.g.dart';

@riverpod
class SocialLoginController extends _$SocialLoginController {
  @override
  FutureOr<List<SocialLoginEntity>> build() {
    return ref.watch(getSocialLoginsProvider.future);
  }
  
  Future<void> refresh() async {
     state = const AsyncValue.loading();
     state = await AsyncValue.guard(() => ref.refresh(getSocialLoginsProvider.future));
  }
}
