import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/venues_entity.dart';

part 'venues_model.freezed.dart';
part 'venues_model.g.dart';

@freezed
abstract class VenuesModel with _$VenuesModel {
  const VenuesModel._();

  const factory VenuesModel({
    required String id,
    required String name,
  }) = _VenuesModel;

  factory VenuesModel.fromJson(Map<String, dynamic> json) => 
      _$VenuesModelFromJson(json);

  VenuesEntity toEntity() => VenuesEntity(id: id, name: name);
}
