import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_entity.freezed.dart';

@freezed
abstract class UserProfileEntity with _$UserProfileEntity {
  const factory UserProfileEntity({
    required String id,
    required String? displayName,
    required int? gender,
    required DateTime? birthdate,
    required String? aboutMe,
    required String? photoUrl,
    @Default(false) bool hasPhoto,
    @Default(true) bool firstAccess, // NOUVEAU : true par défaut
  }) = _UserProfileEntity;
}