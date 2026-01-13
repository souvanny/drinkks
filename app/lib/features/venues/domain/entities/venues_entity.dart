import 'package:freezed_annotation/freezed_annotation.dart';

part 'venues_entity.freezed.dart';

@freezed
abstract class VenuesEntity with _$VenuesEntity {
  const factory VenuesEntity({
    required String id,
    required String name,
  }) = _VenuesEntity;
}
