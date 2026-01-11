import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/social_login_entity.dart';

part 'social_login_model.freezed.dart';
part 'social_login_model.g.dart';

@freezed
abstract class SocialLoginModel with _$SocialLoginModel {
  const SocialLoginModel._();

  const factory SocialLoginModel({
    required String id,
    required String name,
  }) = _SocialLoginModel;

  factory SocialLoginModel.fromJson(Map<String, dynamic> json) => 
      _$SocialLoginModelFromJson(json);

  SocialLoginEntity toEntity() => SocialLoginEntity(id: id, name: name);
}
