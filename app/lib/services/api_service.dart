import 'dart:async';
import 'dart:developer';
import 'dart:ui';

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

  // Callback pour la déconnexion en cas d'échec de refresh
  VoidCallback? onUnauthorized;

  ApiService({
    required Dio dio,
    required FlutterSecureStorage storage,
  })  : _dio = dio,
        _storage = storage {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers['accept'] = 'application/json';
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    _dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    // Ajouter l'intercepteur pour le refresh token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {

          print("******************* ON REQUEST *******************************");
          print(options.path);


          // Ne pas ajouter le token pour les endpoints d'auth
          // if (!options.path.contains('/auth/refresh') &&
          if (!options.path.contains('/auth/refresh') &&
          // if (
              !options.path.contains('/auth/login') &&
              !options.path.contains('/users/jwt-by-firebase-token')) {

            print("******************* TEST 1 *******************************");

            final token = await _storage.read(key: 'app_jwt_token');

            print("******************* TEST 2 *******************************");
            // print(token);

            if (token != null) {
              print("******************* TEST 3 *******************************");
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          print("******************* ON REQUEST END *******************************");
          log(options.headers['Authorization'].toString());

          return handler.next(options);
        },
        onError: (error, handler) async {
          // Si erreur 401 et que ce n'est pas déjà une tentative de refresh
          if (error.response?.statusCode == 401 &&
              !error.requestOptions.path.contains('/auth/refresh')) {

            try {
              // Tenter de rafraîchir le token
              final newToken = await _refreshToken();
              // final refreshToken = await _storage.read(key: 'refresh_token');
              // final newToken = await refreshJwtToken(refreshToken.toString());

              if (newToken != null) {
                // Rejouer la requête originale avec le nouveau token
                final options = error.requestOptions;
                options.headers['Authorization'] = 'Bearer $newToken';

                final response = await _dio.fetch(options);
                return handler.resolve(response);
              }
            } catch (refreshError) {
              print('❌ Erreur lors du refresh: $refreshError');
            }

            // Si le refresh échoue, notifier pour déconnecter l'utilisateur
            if (onUnauthorized != null) {
              onUnauthorized!();
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  bool _isRefreshing = false;
  final List<Completer<String?>> _refreshCompleters = [];

  Future<String?> _refreshToken() async {
    if (_isRefreshing) {
      // Si un refresh est déjà en cours, attendre son résultat
      final completer = Completer<String?>();
      _refreshCompleters.add(completer);
      return completer.future;
    }

    _isRefreshing = true;
    final completer = Completer<String?>();
    _refreshCompleters.add(completer);

    try {
      final refreshToken = await _storage.read(key: 'refresh_token');

      if (refreshToken == null) {
        throw Exception('No refresh token');
      }

      final appJwtToken = await _storage.read(key: 'app_jwt_token');

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(
          extra: {'noToken': true},
          headers: {'Authorization': 'Bearer $appJwtToken'}

        ),
      );

      if (response.statusCode == 200) {
        final newToken = response.data['token'];
        final newRefreshToken = response.data['refresh_token'];

        await _storage.write(key: 'app_jwt_token', value: newToken);
        if (newRefreshToken != null) {
          await _storage.write(key: 'refresh_token', value: newRefreshToken);
        }

        // Résoudre tous les completer en attente
        for (final c in _refreshCompleters) {
          c.complete(newToken);
        }

        return newToken;
      }
    } catch (e) {
      print('❌ Erreur refresh token: $e');
      // En cas d'erreur, échouer tous les completer
      for (final c in _refreshCompleters) {
        c.completeError(e);
      }
    } finally {
      _isRefreshing = false;
      _refreshCompleters.clear();
    }

    return null;
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
  Future<Map<String, dynamic>> getJwtFromFirebaseToken(String firebaseToken) async {
    return safeApiCall(
      apiCall: () async {
        final response = await _dio.post(
          '/users/jwt-by-firebase-token',
          data: {'token': firebaseToken},
          options: Options(extra: {'noToken': true}),
        );

        if (response.statusCode == 200) {
          return response.data as Map<String, dynamic>;
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

  // Nouvelle méthode pour rafraîchir le token
  Future<Map<String, dynamic>?> refreshJwtToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(extra: {'noToken': true}),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      print('❌ Erreur refresh token API: $e');
    }
    return null;
  }

  // Nouvelle méthode pour révoquer le refresh token (logout)
  Future<void> revokeRefreshToken(String refreshToken) async {
    try {
      final token = await _storage.read(key: 'app_jwt_token');
      await _dio.post(
        '/auth/logout',
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : {},
          extra: {'noToken': true},
        ),
      );
    } catch (e) {
      print('⚠️ Erreur lors de la révocation du refresh token: $e');
    }
  }

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

        final appJwt = await _storage.read(key: 'app_jwt_token');

        if (appJwt == null) {
          throw ApiException(message: 'JWT token non disponible');
        }

        final response = await _dio.post(
          '/sfu/generate-token',
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
  final dio = Dio();
  final storage = const FlutterSecureStorage();
  return ApiService(dio: dio, storage: storage);
}