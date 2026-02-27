// flutter_lib/services/tables_service.dart

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
    );

    return response.data as Map<String, dynamic>;
  }
}

@riverpod
TablesService tablesService(Ref ref) {
  final apiService = ref.watch(apiServiceProvider);
  return TablesService(apiService: apiService);
}