import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/tables_entity.dart';

part 'tables_model.freezed.dart';
part 'tables_model.g.dart';

@freezed
abstract class TablesModel with _$TablesModel {
  const TablesModel._();

  const factory TablesModel({
    required String id,
    required String name,
  }) = _TablesModel;

  factory TablesModel.fromJson(Map<String, dynamic> json) => 
      _$TablesModelFromJson(json);

  TablesEntity toEntity() => TablesEntity(id: id, name: name);
}
