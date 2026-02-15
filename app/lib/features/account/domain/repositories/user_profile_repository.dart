import '../entities/user_profile_entity.dart';

abstract class UserProfileRepository {
  Future<UserProfileEntity> getProfile();
  Future<String?> getAboutMe();
  Future<String?> getPhoto();
  Future<void> updateProfile({
    String? username,
    int? gender,
    DateTime? birthdate,
  });
  Future<void> updateAboutMe(String aboutMe);
  Future<void> updatePhoto(String photoPath);
}