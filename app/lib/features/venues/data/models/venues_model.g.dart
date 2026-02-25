// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venues_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VenuesModel _$VenuesModelFromJson(Map<String, dynamic> json) => _VenuesModel(
  id: (json['id'] as num).toInt(),
  uuid: json['uuid'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  type: (json['type'] as num?)?.toInt(),
  rank: (json['rank'] as num?)?.toInt(),
);

Map<String, dynamic> _$VenuesModelToJson(_VenuesModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'name': instance.name,
      'description': instance.description,
      'type': instance.type,
      'rank': instance.rank,
    };
