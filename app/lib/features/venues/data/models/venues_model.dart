// flutter_lib/features/venues/data/models/venues_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/venues_entity.dart';

part 'venues_model.freezed.dart';
part 'venues_model.g.dart';

@freezed
abstract class VenuesModel with _$VenuesModel {
  const VenuesModel._();

  const factory VenuesModel({
    required int id,
    required String uuid,
    required String name,
    String? description,
    int? type,
    int? rank,
    // Nouveaux champs
    int? nbTables,
    int? seatsPerTable,
    int? totalCapacity,
    int? totalParticipants,
    Map<String, int>? nbParticipantsByTable,
    Map<String, int>? nbSeatsByTable,
    int? tablesAvailable,
    double? occupancyRate,
  }) = _VenuesModel;

  factory VenuesModel.fromJson(Map<String, dynamic> json) =>
      _$VenuesModelFromJson(json);

  VenuesEntity toEntity() => VenuesEntity(
    id: id,
    uuid: uuid,
    name: name,
    description: description,
    type: type,
    rank: rank,
    nbTables: nbTables,
    seatsPerTable: seatsPerTable,
    totalCapacity: totalCapacity,
    totalParticipants: totalParticipants,
    nbParticipantsByTable: nbParticipantsByTable,
    nbSeatsByTable: nbSeatsByTable,
    tablesAvailable: tablesAvailable,
    occupancyRate: occupancyRate,
  );
}