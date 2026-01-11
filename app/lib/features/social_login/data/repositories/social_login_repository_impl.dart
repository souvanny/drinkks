import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/social_login_entity.dart';
import '../../domain/repositories/social_login_repository.dart';
import '../datasources/social_login_remote_data_source.dart';

part 'social_login_repository_impl.g.dart';

@riverpod
SocialLoginRepository socialLoginRepository(Ref ref) {
  final remoteDataSource = ref.watch(socialLoginRemoteDataSourceProvider);
  return SocialLoginRepositoryImpl(remoteDataSource);
}

class SocialLoginRepositoryImpl implements SocialLoginRepository {
  final SocialLoginRemoteDataSource _remoteDataSource;

  SocialLoginRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<SocialLoginEntity>> getSocialLogins() async {
    final models = await _remoteDataSource.fetchSocialLogins();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<SocialLoginEntity> getSocialLogin(String id) async {
    final model = await _remoteDataSource.fetchSocialLogin(id);
    return model.toEntity();
  }
}
