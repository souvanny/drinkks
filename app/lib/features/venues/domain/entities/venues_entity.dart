import 'package:freezed_annotation/freezed_annotation.dart';

part 'venues_entity.freezed.dart';

@freezed
abstract class VenuesEntity with _$VenuesEntity {
  const factory VenuesEntity({
    required int id,
    required String uuid,
    required String name,
    String? description,
    int? type,
    int? rank,
  }) = _VenuesEntity;
}