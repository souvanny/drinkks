import '../entities/venues_entity.dart';

abstract class VenuesRepository {
  Future<List<VenuesEntity>> getVenuess();
  Future<VenuesEntity> getVenues(String id);
}
