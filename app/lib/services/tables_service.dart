// flutter_lib/services/tables_service.dart

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'api_service.dart';

part 'tables_service.g.dart';

class TablesService {
  final ApiService _apiService;

  TablesService({required ApiService apiService}) : _apiService = apiService;

  /// Récupère le nombre de tables pour un lieu
  Future<Map<String, dynamic>> getVenueTables(String venueUuid) async {
    final response = await _apiService.dio.get(
      '/venue/tables/list',
      queryParameters: {'venue': venueUuid},
      options: Options(responseType: ResponseType.plain), // Force la réponse en texte brut
    );

    // Récupérer la réponse brute en texte
    String responseText = response.data.toString();

    // Remplacer tous les [] par {} dans le texte JSON
    // Attention: cette méthode est basique et peut avoir des effets secondaires
    // si vous avez des chaînes de caractères contenant "[]"
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
TablesService tablesService(Ref ref) {
  final apiService = ref.watch(apiServiceProvider);
  return TablesService(apiService: apiService);
}