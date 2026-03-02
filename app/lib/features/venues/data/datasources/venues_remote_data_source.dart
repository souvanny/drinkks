// flutter_lib/features/venues/data/datasources/venues_remote_data_source.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../services/venue_service.dart';
import '../models/venues_model.dart';

part 'venues_remote_data_source.g.dart';

abstract class VenuesRemoteDataSource {
  Future<List<VenuesModel>> getAllVenues({
    String? search,
    int? type,
  });
  Future<VenuesModel> getVenue(String uuid);
  Future<Map<String, dynamic>> getVenuesStats(); // Nouvelle méthode
}

@riverpod
VenuesRemoteDataSource venuesRemoteDataSource(Ref ref) {
  final venueService = ref.watch(venueServiceProvider);
  return VenuesRemoteDataSourceImpl(venueService);
}

class VenuesRemoteDataSourceImpl implements VenuesRemoteDataSource {
  final VenueService _venueService;

  VenuesRemoteDataSourceImpl(this._venueService);

  @override
  Future<List<VenuesModel>> getAllVenues({
    String? search,
    int? type,
  }) async {
    final response = await _venueService.getAllVenues(
      search: search,
      type: type,
    );

    // La réponse contient maintenant 'venues' (liste) et 'stats'
    final List<dynamic> items = response['venues'] ?? [];
    return items.map((json) => VenuesModel.fromJson(json)).toList();
  }

  @override
  Future<VenuesModel> getVenue(String uuid) async {
    final response = await _venueService.getVenue(uuid);
    return VenuesModel.fromJson(response);
  }

  @override
  Future<Map<String, dynamic>> getVenuesStats() async {
    final response = await _venueService.getAllVenues();
    return response['stats'] as Map<String, dynamic>;
  }
}