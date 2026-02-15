// Créer un nouveau fichier: flutter_lib/features/tables/services/sfu_service.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../services/api_service.dart';

part 'sfu_service.g.dart';

class SfuService {
  final ApiService _apiService;

  SfuService({required ApiService apiService}) : _apiService = apiService;

  Future<Map<String, dynamic>> generateToken({
    required String participantIdentity,
    required String participantName,
    required String roomName,
    String participantMetadata = '',
    Map<String, dynamic> participantAttributes = const {},
    Map<String, dynamic> roomConfig = const {},
  }) async {
    return _apiService.generateLiveKitToken(
      participantIdentity: participantIdentity,
      participantName: participantName,
      participantAttributes: participantAttributes,
      participantMetadata: participantMetadata,
      roomName: roomName,
      roomConfig: roomConfig,
    );
  }
}

@riverpod
SfuService sfuService(Ref ref) {
  final apiService = ref.watch(apiServiceProvider);
  return SfuService(apiService: apiService);
}