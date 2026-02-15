import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/account_entity.dart';

part 'account_model.freezed.dart';
part 'account_model.g.dart';

@freezed
abstract class AccountModel with _$AccountModel {
  const AccountModel._();

  const factory AccountModel({
    required String id,
    required String name,
  }) = _AccountModel;

  factory AccountModel.fromJson(Map<String, dynamic> json) => 
      _$AccountModelFromJson(json);

  AccountEntity toEntity() => AccountEntity(id: id, name: name);
}
