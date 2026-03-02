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
  nbTables: (json['nbTables'] as num?)?.toInt(),
  seatsPerTable: (json['seatsPerTable'] as num?)?.toInt(),
  totalCapacity: (json['totalCapacity'] as num?)?.toInt(),
  totalParticipants: (json['totalParticipants'] as num?)?.toInt(),
  nbParticipantsByTable:
      (json['nbParticipantsByTable'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
  nbSeatsByTable: (json['nbSeatsByTable'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toInt()),
  ),
  tablesAvailable: (json['tablesAvailable'] as num?)?.toInt(),
  occupancyRate: (json['occupancyRate'] as num?)?.toDouble(),
);

Map<String, dynamic> _$VenuesModelToJson(_VenuesModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'name': instance.name,
      'description': instance.description,
      'type': instance.type,
      'rank': instance.rank,
      'nbTables': instance.nbTables,
      'seatsPerTable': instance.seatsPerTable,
      'totalCapacity': instance.totalCapacity,
      'totalParticipants': instance.totalParticipants,
      'nbParticipantsByTable': instance.nbParticipantsByTable,
      'nbSeatsByTable': instance.nbSeatsByTable,
      'tablesAvailable': instance.tablesAvailable,
      'occupancyRate': instance.occupancyRate,
    };
