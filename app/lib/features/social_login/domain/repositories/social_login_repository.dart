import '../entities/social_login_entity.dart';

abstract class SocialLoginRepository {
  Future<List<SocialLoginEntity>> getSocialLogins();
  Future<SocialLoginEntity> getSocialLogin(String id);
}
