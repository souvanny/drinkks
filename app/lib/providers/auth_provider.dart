import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

// Provider pour ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = Dio();
  final storage = const FlutterSecureStorage();
  return ApiService(dio: dio, storage: storage);
});

// Provider pour AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthService(
    onAuthenticationEvent: (event) async {
      print('Authentication event: $event');
    },
    onAuthenticationError: (error) async {
      print('Authentication error: $error');
    },
    apiService: apiService,
  );
});

// Stream provider pour les changements d'état Firebase
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Provider pour l'utilisateur courant Firebase
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authServiceProvider).currentUser;
});

// Provider pour récupérer le JWT applicatif (version FutureProvider)
final appJwtProvider = FutureProvider<String?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getAppJwt();
});

// ============================================================
// NOUVEAUX PROVIDERS POUR LA GESTION COMPLÈTE DE L'AUTH
// ============================================================

// Enum pour les différents statuts d'authentification
enum AuthStatus {
  initial,           // Non connecté
  authenticated,     // Firebase OK mais JWT en cours
  fullyAuthenticated, // Firebase + JWT OK
  error,             // Erreur
}

// Classe représentant l'état d'authentification complet
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? jwtToken;
  final Object? error;

  const AuthState({
    required this.status,
    this.user,
    this.jwtToken,
    this.error,
  });

  // ⚠️ CORRECTION ICI : Ce ne sont plus des factory constructors
  // Ce sont des constructors nommés qui retournent une nouvelle instance

  static const AuthState initial = AuthState(status: AuthStatus.initial);

  const AuthState.authenticated(User user) : this(
    status: AuthStatus.authenticated,
    user: user,
  );

  const AuthState.fullyAuthenticated({
    required User user,
    required String jwtToken,
  }) : this(
    status: AuthStatus.fullyAuthenticated,
    user: user,
    jwtToken: jwtToken,
  );

  const AuthState.error(Object error) : this(
    status: AuthStatus.error,
    error: error,
  );

  // Méthodes utilitaires
  bool get isFullyAuthenticated => status == AuthStatus.fullyAuthenticated;
  bool get isAuthenticated => status == AuthStatus.authenticated || status == AuthStatus.fullyAuthenticated;
  bool get isInitial => status == AuthStatus.initial;
  bool get hasError => status == AuthStatus.error;

  // Méthode copyWith pour faciliter les mises à jour
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? jwtToken,
    Object? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      jwtToken: jwtToken ?? this.jwtToken,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'AuthState(status: $status, user: ${user?.uid}, hasJwt: ${jwtToken != null})';
  }
}

// StateNotifier pour gérer l'état d'authentification complet
class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final Ref _ref;

  AuthStateNotifier({
    required AuthService authService,
    required Ref ref,
  }) : _authService = authService,
        _ref = ref,
        super(AuthState.initial) {  // ⚠️ CORRECTION ICI : AuthState.initial (sans parenthèses)
    _init();
  }

  Future<void> _init() async {
    // Écouter les changements d'authentification Firebase
    _ref.listen(authStateProvider, (previous, next) {
      next.whenData((user) async {
        if (user != null) {
          // Utilisateur Firebase connecté
          state = AuthState.authenticated(user);

          // Vérifier si on a déjà un JWT
          try {
            final existingJwt = await _authService.getAppJwt();
            if (existingJwt != null && existingJwt.isNotEmpty) {
              // JWT déjà présent
              state = AuthState.fullyAuthenticated(
                user: user,
                jwtToken: existingJwt,
              );
              print('✅ JWT déjà présent dans le stockage');
            } else {
              print('⏳ En attente du JWT applicatif...');
            }
          } catch (e) {
            print('❌ Erreur lors de la vérification du JWT: $e');
          }
        } else {
          // Déconnecté
          state = AuthState.initial;  // ⚠️ CORRECTION ICI : AuthState.initial (sans parenthèses)
          print('👤 Utilisateur déconnecté');
        }
      });
    });

    // Écouter les événements d'authentification pour capturer le JWT
    _authService.onAuthenticationEvent = (event) async {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        print('📡 Événement d\'authentification reçu, attente du JWT...');

        // Attendre que le JWT soit stocké (avec timeout)
        const maxAttempts = 10;
        var attempts = 0;
        String? jwt;

        while (attempts < maxAttempts) {
          await Future.delayed(const Duration(milliseconds: 300));
          jwt = await _authService.getAppJwt();
          if (jwt != null && jwt.isNotEmpty) {
            break;
          }
          attempts++;
        }

        final user = _authService.currentUser;

        if (jwt != null && jwt.isNotEmpty && user != null) {
          state = AuthState.fullyAuthenticated(
            user: user,
            jwtToken: jwt,
          );
          print('✅ Authentification complète (Firebase + JWT)');
        } else if (user != null) {
          // Firebase OK mais pas de JWT
          state = AuthState.authenticated(user);
          print('⚠️ Firebase authentifié mais JWT manquant');
        }
      }
    };

    // Écouter les erreurs d'authentification
    _authService.onAuthenticationError = (error) async {
      state = AuthState.error(error);
      print('❌ Erreur d\'authentification: $error');
    };
  }

  // Méthode pour réinitialiser manuellement l'état
  void reset() {
    state = AuthState.initial;  // ⚠️ CORRECTION ICI : AuthState.initial (sans parenthèses)
  }

  // Méthode pour forcer une erreur
  void setError(Object error) {
    state = AuthState.error(error);
  }

  // Méthode pour rafraîchir le JWT (si nécessaire)
  /*
  Future<bool> refreshJwt() async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        return false;
      }

      // Récupérer un nouveau token Firebase
      final tokenResult = await user.getIdTokenResult(true);
      if (tokenResult.token == null) {
        return false;
      }

      // Appeler l'API pour obtenir un nouveau JWT
      final newJwt = await _authService.refreshJwtFromApi(tokenResult.token!);

      if (newJwt != null && newJwt.isNotEmpty) {
        state = state.copyWith(
          jwtToken: newJwt,
          status: AuthStatus.fullyAuthenticated,
        );
        return true;
      }
      return false;
    } catch (e) {
      setError(e);
      return false;
    }
  }

   */
}

// StateNotifierProvider
final authStateNotifierProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthStateNotifier(
    authService: authService,
    ref: ref,
  );
});

// Providers utilitaires pour faciliter l'accès à l'état

// Provider pour savoir si l'utilisateur est complètement authentifié
final isFullyAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateNotifierProvider);
  return authState.isFullyAuthenticated;
});

// Provider pour récupérer le JWT de manière synchrone (si disponible)
final appJwtSyncProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateNotifierProvider);
  return authState.jwtToken;
});

// Provider pour récupérer l'utilisateur de manière synchrone
final currentUserSyncProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateNotifierProvider);
  return authState.user;
});

// Provider pour vérifier si l'authentification est en cours
final isAuthenticatingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateNotifierProvider);
  return authState.status == AuthStatus.authenticated;
});

// Provider pour obtenir le message d'erreur (si présent)
final authErrorProvider = Provider<Object?>((ref) {
  final authState = ref.watch(authStateNotifierProvider);
  return authState.error;
});