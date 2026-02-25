// flutter_lib/features/venues/domain/repositories/venues_repository.dart

import '../entities/venues_entity.dart';

abstract class VenuesRepository {
  Future<List<VenuesEntity>> getAllVenues({
    String? search,
    int? type,
  });
  Future<VenuesEntity> getVenue(String uuid);
}