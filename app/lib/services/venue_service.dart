// flutter_lib/services/venue_service.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'api_service.dart';

part 'venue_service.g.dart';

class VenueService {
  final ApiService _apiService;

  VenueService({required ApiService apiService}) : _apiService = apiService;

  /// Récupère toutes les venues (sans pagination serveur)
  Future<List<dynamic>> getAllVenues({
    String? search,
    int? type,
  }) async {
    final queryParams = <String, dynamic>{};

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    if (type != null) {
      queryParams['type'] = type;
    }

    final response = await _apiService.dio.get(
      '/venue/list',
      queryParameters: queryParams,
    );

    // La réponse est maintenant directement une liste
    return response.data as List<dynamic>;
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