import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

// final authServiceProvider = Provider<AuthService>((ref) {
//   return AuthService();
// });

final apiServiceProvider = Provider<ApiService>((ref) {
  // À adapter selon votre implémentation d'ApiService
  final dio = Dio(); // Si vous utilisez Dio
  final storage = const FlutterSecureStorage();
  return ApiService(dio: dio, storage: storage);
});


// final authStateProvider = StreamProvider<User?>((ref) {
//   final authService = ref.watch(authServiceProvider);
//   return authService.authStateChanges;
// });

final authServiceProvider = Provider<AuthService>((ref) {
  // Récupération de l'ApiService
  final apiService = ref.watch(apiServiceProvider);

  // Injection de l'ApiService dans AuthService
  return AuthService(
    onAuthenticationEvent: (event) async {
      // Logique optionnelle si besoin
      print('Authentication event: $event');
    },
    onAuthenticationError: (error) async {
      // Logique optionnelle si besoin
      print('Authentication error: $error');
    },
    apiService: apiService, // Passage du service API
  );
});



// final currentUserProvider = Provider<User?>((ref) {
//   return ref.watch(authServiceProvider).currentUser;
// });

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authServiceProvider).currentUser;
});

// Provider optionnel pour récupérer le JWT applicatif
final appJwtProvider = FutureProvider<String?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getAppJwt();
});