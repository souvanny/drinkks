// flutter_lib/services/venue_service.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'api_service.dart';

part 'venue_service.g.dart';

class VenueService {
  final ApiService _apiService;

  VenueService({required ApiService apiService}) : _apiService = apiService;

  /// Récupère la liste paginée des venues
  Future<Map<String, dynamic>> getVenues({
    required int page,
    required int limit,
    String? search,
    int? type,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    if (type != null) {
      queryParams['type'] = type;
    }

    return _apiService.dio.get(
      '/venue/list',
      queryParameters: queryParams,
    ).then((response) => response.data as Map<String, dynamic>);
  }

  /// Récupère un venue par son UUID
  Future<Map<String, dynamic>> getVenue(String uuid) async {
    return _apiService.dio.get('/venue/$uuid')
        .then((response) => response.data as Map<String, dynamic>);
  }
}

@riverpod
VenueService venueService(Ref ref) {
  final apiService = ref.watch(apiServiceProvider);
  return VenueService(apiService: apiService);
}