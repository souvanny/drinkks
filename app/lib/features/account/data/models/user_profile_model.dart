import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_profile_entity.dart';

part 'user_profile_model.freezed.dart';
part 'user_profile_model.g.dart';

@freezed
abstract class UserProfileModel with _$UserProfileModel {
  const UserProfileModel._();

  const factory UserProfileModel({
    required String id,
    @JsonKey(name: 'displayName') String? displayName,
    int? gender,
    @JsonKey(name: 'birthdate') @DateTimeConverter() DateTime? birthdate,
    @JsonKey(name: 'about_me') String? aboutMe,
    @JsonKey(name: 'photo_url') String? photoUrl,
    @JsonKey(name: 'has_photo') @Default(false) bool hasPhoto,
    @JsonKey(name: 'first_access') @Default(true) bool firstAccess, // NOUVEAU
  }) = _UserProfileModel;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);

  UserProfileEntity toEntity() => UserProfileEntity(
    id: id,
    displayName: displayName,
    gender: gender,
    birthdate: birthdate,
    aboutMe: aboutMe,
    photoUrl: photoUrl,
    hasPhoto: hasPhoto,
    firstAccess: firstAccess, // NOUVEAU
  );
}

class DateTimeConverter implements JsonConverter<DateTime?, String?> {
  const DateTimeConverter();

  @override
  DateTime? fromJson(String? json) {
    if (json == null) return null;
    return DateTime.parse(json);
  }

  @override
  String? toJson(DateTime? object) {
    if (object == null) return null;
    return object.toIso8601String();
  }
}