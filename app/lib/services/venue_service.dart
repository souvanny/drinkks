// flutter_lib/services/venue_service.dart

import 'dart:convert';

import 'package:dio/dio.dart';
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
      options: Options(responseType: ResponseType.plain), // Force la réponse en texte brut
    );

    // Récupérer la réponse brute en texte
    String responseText = response.data.toString();

    // Nettoyer le JSON en remplaçant les [] par {}
    responseText = _cleanJson(responseText);

    try {
      // Décoder le texte modifié
      final Map<String, dynamic> decodedData = json.decode(responseText);

      // Retourner la liste des venues
      return decodedData['venues'] as List<dynamic>;
    } catch (e) {
      print('❌ Erreur lors du décodage JSON: $e');
      print('📄 Texte reçu: $responseText');
      rethrow;
    }
  }

// Fonction de nettoyage réutilisable (à placer dans la classe)
  String _cleanJson(String jsonString) {
    // Remplacer tous les tableaux vides par des objets vides
    return jsonString.replaceAllMapped(
      RegExp(r'"\s*([^"]+)\s*"\s*:\s*\[\s*\]'),
          (match) => '"${match.group(1)}": {}',
    );
  }

  /// Récupère un venue par son UUID
  Future<Map<String, dynamic>> getVenue(String uuid) async {
    final response = await _apiService.dio.get(
      '/venue/$uuid',
      options: Options(responseType: ResponseType.plain), // Force la réponse en texte brut
    );

    // Récupérer la réponse brute en texte
    String responseText = response.data.toString();

    // Remplacer tous les [] par {} dans le texte JSON
    responseText = responseText.replaceAll('[]', '{}');

    // Décoder le texte modifié en Map
    try {
      final Map<String, dynamic> decodedData = json.decode(responseText);
      return decodedData;
    } catch (e) {
      print('❌ Erreur lors du décodage JSON: $e');
      print('📄 Texte reçu: $responseText');
      rethrow;
    }
  }
}

@riverpod
VenueService venueService(Ref ref) {
  final apiService = ref.watch(apiServiceProvider);
  return VenueService(apiService: apiService);
}