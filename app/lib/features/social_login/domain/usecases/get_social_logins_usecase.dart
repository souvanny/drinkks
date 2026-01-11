import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/social_login_entity.dart';
import '../repositories/social_login_repository.dart';
import '../../data/repositories/social_login_repository_impl.dart';

part 'get_social_logins_usecase.g.dart';

@riverpod
Future<List<SocialLoginEntity>> getSocialLogins(Ref ref) {
  return ref.watch(socialLoginRepositoryProvider).getSocialLogins();
}
