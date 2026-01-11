import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_login_entity.freezed.dart';

@freezed
abstract class SocialLoginEntity with _$SocialLoginEntity {
  const factory SocialLoginEntity({
    required String id,
    required String name,
  }) = _SocialLoginEntity;
}
