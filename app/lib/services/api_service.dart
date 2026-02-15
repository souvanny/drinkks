import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_service.g.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  static const _baseUrl = 'http://192.168.1.56:8101/api';

  ApiService({
    required Dio dio,
    required FlutterSecureStorage storage,
  })  : _dio = dio,
        _storage = storage {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    _dio.interceptors
        .add(LogInterceptor(requestBody: true, responseBody: true));
  }





  // Méthode générique pour gérer les requêtes avec gestion d'erreur centralisée
  Future<T> safeApiCall<T>({
    required Future<T> Function() apiCall,
    String? errorMessage,
  }) async {
    try {
      return await apiCall();
    } on DioException catch (e) {
      throw _handleDioError(e, errorMessage);
    } catch (e) {
      throw ApiException(
        message: errorMessage ?? 'Une erreur inattendue est survenue',
        originalError: e,
      );
    }
  }

  ApiException _handleDioError(DioException e, String? customMessage) {
    String message;
    int? statusCode = e.response?.statusCode;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Délai de connexion dépassé';
        break;
      case DioExceptionType.badResponse:
        message = _parseErrorResponse(e.response);
        break;
      case DioExceptionType.cancel:
        message = 'Requête annulée';
        break;
      case DioExceptionType.connectionError:
        message = 'Erreur de connexion réseau';
        break;
      default:
        message = customMessage ?? 'Erreur réseau inconnue';
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      originalError: e,
    );
  }

  String _parseErrorResponse(Response? response) {
    try {
      if (response?.data != null && response!.data is Map) {
        return response.data['message'] ??
            response.data['error'] ??
            'Erreur serveur (${response.statusCode})';
      }
      return 'Erreur serveur (${response?.statusCode ?? 'inconnue'})';
    } catch (_) {
      return 'Erreur serveur inconnue';
    }
  }

  // Méthodes API spécifiques
  Future<String> getJwtFromFirebaseToken(String firebaseToken) async {
    return safeApiCall(
      apiCall: () async {
        final response = await _dio.post(
          '/users/jwt-by-firebase-token',
          data: {'token': firebaseToken},
        );

        if (response.statusCode == 200) {
          // Adapter selon le format de réponse de votre API
          // Supposons que l'API retourne { "jwt": "token_value" }
          final jwt = response.data['jwt'] ?? response.data['token'] ?? response.data;
          if (jwt == null) {
            throw ApiException(message: 'Format de réponse API invalide');
          }
          return jwt.toString();
        } else {
          throw ApiException(
            message: 'Erreur lors de la récupération du JWT',
            statusCode: response.statusCode,
          );
        }
      },
      errorMessage: 'Impossible de récupérer le token JWT',
    );
  }

// Nouvelle méthode pour générer le token LiveKit
  Future<Map<String, dynamic>> generateLiveKitToken({
    required String participantIdentity,
    required String participantName,
    required String roomName,
    String participantMetadata = '',
    Map<String, dynamic> participantAttributes = const {},
    Map<String, dynamic> roomConfig = const {},
  }) async {
    return safeApiCall(
      apiCall: () async {
        final payload = {
          "participant_identity": participantIdentity,
          "participant_name": participantName,
          "participant_metadata": participantMetadata,
          "participant_attributes": participantAttributes,
          "room_name": roomName,
          "room_config": roomConfig
        };

        // Récupérer le JWT pour l'authentification
        final appJwt = await _storage.read(key: 'app_jwt_token');

        if (appJwt == null) {
          throw ApiException(message: 'JWT token non disponible');
        }

        final response = await _dio.post(
          '/sfu/generate-token', // Note: plus besoin de l'URL complète, baseUrl est déjà configurée
          data: payload,
          options: Options(
            headers: {
              'Authorization': 'Bearer $appJwt',
            },
          ),
        );

        if (response.statusCode == 200) {
          return response.data as Map<String, dynamic>;
        } else {
          throw ApiException(
            message: 'Erreur lors de la génération du token LiveKit',
            statusCode: response.statusCode,
          );
        }
      },
      errorMessage: 'Impossible de générer le token LiveKit',
    );
  }
}

@riverpod
ApiService apiService(Ref ref) {
  final dio = Dio(); // À configurer selon vos besoins
  final storage = const FlutterSecureStorage();
  return ApiService(dio: dio, storage: storage);
}