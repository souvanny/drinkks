import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../services/account_service.dart';
import '../models/user_profile_model.dart';

part 'user_profile_remote_data_source.g.dart';

abstract class UserProfileRemoteDataSource {
  Future<UserProfileModel> getProfile();
  Future<String> getAboutMe();
  Future<String> getPhoto();
  Future<void> updateProfile({
    String? displayName,
    int? gender,
    DateTime? birthdate,
  });
  Future<void> updateAboutMe(String aboutMe);
  Future<void> updatePhoto(String photoPath);
}

@riverpod
UserProfileRemoteDataSource userProfileRemoteDataSource(Ref ref) {
  final accountService = ref.watch(accountServiceProvider);
  return UserProfileRemoteDataSourceImpl(accountService);
}

class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final AccountService _accountService;

  UserProfileRemoteDataSourceImpl(this._accountService);

  @override
  Future<UserProfileModel> getProfile() async {
    final response = await _accountService.getProfile();
    return UserProfileModel.fromJson(response);
  }

  @override
  Future<String> getAboutMe() async {
    final response = await _accountService.getAboutMe();
    return response['about_me'] ?? '';
  }

  @override
  Future<String> getPhoto() async {
    final response = await _accountService.getPhoto();
    return response['photo_url'] ?? '';
  }

  @override
  Future<void> updateProfile({
    String? displayName,
    int? gender,
    DateTime? birthdate,
  }) async {
    await _accountService.updateProfile(
      displayName: displayName,
      gender: gender,
      birthdate: birthdate,
    );
  }

  @override
  Future<void> updateAboutMe(String aboutMe) async {
    await _accountService.updateAboutMe(aboutMe);
  }

  @override
  Future<void> updatePhoto(String photoPath) async {
    await _accountService.updatePhoto(photoPath);
  }
}