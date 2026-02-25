import '../entities/venues_entity.dart';

abstract class VenuesRepository {
  Future<List<VenuesEntity>> getVenues({
    required int page,
    required int limit,
    String? search,
    int? type,
  });
  Future<VenuesEntity> getVenue(String uuid);
  Future<int> getTotalPages();
  Future<int> getTotalItems();
}