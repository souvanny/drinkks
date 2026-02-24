import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_remote_data_source.dart';

part 'user_profile_repository_impl.g.dart';

@riverpod
UserProfileRepository userProfileRepository(Ref ref) {
  final remoteDataSource = ref.watch(userProfileRemoteDataSourceProvider);
  return UserProfileRepositoryImpl(remoteDataSource);
}

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource _remoteDataSource;

  UserProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserProfileEntity> getProfile() async {
    final model = await _remoteDataSource.getProfile();
    return model.toEntity();
  }

  @override
  Future<String?> getAboutMe() async {
    return await _remoteDataSource.getAboutMe();
  }

  @override
  Future<String?> getPhoto() async {
    return await _remoteDataSource.getPhoto();
  }

  @override
  Future<void> updateProfile({
    String? displayName,
    int? gender,
    DateTime? birthdate,
  }) async {
    await _remoteDataSource.updateProfile(
      displayName: displayName,
      gender: gender,
      birthdate: birthdate,
    );
  }

  @override
  Future<void> updateAboutMe(String aboutMe) async {
    await _remoteDataSource.updateAboutMe(aboutMe);
  }

  @override
  Future<void> updatePhoto(String photoPath) async {
    await _remoteDataSource.updatePhoto(photoPath);
  }
}