import 'package:freezed_annotation/freezed_annotation.dart';

part 'tables_entity.freezed.dart';

@freezed
abstract class TablesEntity with _$TablesEntity {
  const factory TablesEntity({
    required String id,
    required String name,
  }) = _TablesEntity;
}
