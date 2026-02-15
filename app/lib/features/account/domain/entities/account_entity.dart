import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_entity.freezed.dart';

@freezed
abstract class AccountEntity with _$AccountEntity {
  const factory AccountEntity({
    required String id,
    required String name,
  }) = _AccountEntity;
}
