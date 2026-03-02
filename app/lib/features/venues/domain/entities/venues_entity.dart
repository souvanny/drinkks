// flutter_lib/features/venues/domain/entities/venues_entity.dart
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
    // Nouveaux champs
    int? nbTables,
    int? seatsPerTable,
    int? totalCapacity,
    int? totalParticipants,
    Map<String, int>? nbParticipantsByTable,
    Map<String, int>? nbSeatsByTable,
    int? tablesAvailable,
    double? occupancyRate,
  }) = _VenuesEntity;
}