import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_entity.freezed.dart';

@freezed
abstract class UserProfileEntity with _$UserProfileEntity {
  const factory UserProfileEntity({
    required String id,
    required String? username,
    required int? gender, // 1 = masculin, 2 = féminin
    required DateTime? birthdate,
    required String? aboutMe,
    required String? photoUrl,
  }) = _UserProfileEntity;
}