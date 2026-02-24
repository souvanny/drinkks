// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfileModel _$UserProfileModelFromJson(Map<String, dynamic> json) =>
    _UserProfileModel(
      id: json['id'] as String,
      displayName: json['displayName'] as String?,
      gender: (json['gender'] as num?)?.toInt(),
      birthdate: const DateTimeConverter().fromJson(
        json['birthdate'] as String?,
      ),
      aboutMe: json['about_me'] as String?,
      photoUrl: json['photo_url'] as String?,
      hasPhoto: json['has_photo'] as bool? ?? false,
    );

Map<String, dynamic> _$UserProfileModelToJson(_UserProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'gender': instance.gender,
      'birthdate': const DateTimeConverter().toJson(instance.birthdate),
      'about_me': instance.aboutMe,
      'photo_url': instance.photoUrl,
      'has_photo': instance.hasPhoto,
    };
