import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

// Provider pour FlutterSecureStorage (séparé pour éviter les dépendances circulaires)
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// Provider pour Dio
final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

// Provider pour ApiService (sans référence à authStateNotifierProvider)
final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(secureStorageProvider);
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

// Provider pour récupérer le refresh token
final refreshTokenProvider = FutureProvider<String?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getRefreshToken();
});

// ============================================================
// GESTION COMPLÈTE DE L'AUTH
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
  final String? refreshToken;
  final Object? error;

  const AuthState({
    required this.status,
    this.user,
    this.jwtToken,
    this.refreshToken,
    this.error,
  });

  static const AuthState initial = AuthState(status: AuthStatus.initial);

  const AuthState.authenticated(User user) : this(
    status: AuthStatus.authenticated,
    user: user,
  );

  const AuthState.fullyAuthenticated({
    required User user,
    required String jwtToken,
    String? refreshToken,
  }) : this(
    status: AuthStatus.fullyAuthenticated,
    user: user,
    jwtToken: jwtToken,
    refreshToken: refreshToken,
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

  // Méthode copyWith
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? jwtToken,
    String? refreshToken,
    Object? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      jwtToken: jwtToken ?? this.jwtToken,
      refreshToken: refreshToken ?? this.refreshToken,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'AuthState(status: $status, user: ${user?.uid ?? 'null'}, hasJwt: ${jwtToken != null}, hasRefresh: ${refreshToken != null})';
  }
}

// StateNotifier pour gérer l'état d'authentification complet
class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final Ref _ref;
  StreamSubscription<User?>? _authSubscription;

  AuthStateNotifier({
    required AuthService authService,
    required Ref ref,
  }) : _authService = authService,
        _ref = ref,
        super(AuthState.initial) {
    _init();
  }

  Future<void> _init() async {
    print('🟡 [NOTIFIER] Initialisation...');

    // Configurer le callback unauthorized dans ApiService APRÈS la création
    // Mais on ne peut pas le faire ici car ça créerait une dépendance circulaire
    // On va plutôt le faire depuis le main ou depuis un provider séparé

    // Écouter DIRECTEMENT le stream Firebase Auth (plus fiable)
    _authSubscription = _authService.authStateChanges.listen(
          (user) {
        print('🔵 [NOTIFIER] Firebase Auth State Change: ${user?.uid ?? 'null'}');

        if (user != null) {
          print('✅ [NOTIFIER] Utilisateur Firebase connecté');
          state = AuthState.authenticated(user);
          _checkTokens(user);
        } else {
          print('❌ [NOTIFIER] Utilisateur Firebase DÉCONNECTÉ - Réinitialisation');
          state = AuthState.initial;
        }
      },
      onError: (error) {
        print('❌ [NOTIFIER] Erreur auth stream: $error');
        state = AuthState.error(error);
      },
    );

    // Garder le listener du provider pour compatibilité
    _ref.listen(authStateProvider, (previous, next) {
      next.whenData((user) {
        print('🟡 [PROVIDER] authStateProvider: ${user?.uid ?? 'null'}');
      });
    });

    // Écouter les événements d'authentification
    _authService.onAuthenticationEvent = (event) async {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        print('📡 [NOTIFIER] Événement d\'authentification reçu');

        const maxAttempts = 10;
        var attempts = 0;
        String? jwt;
        String? refreshToken;

        while (attempts < maxAttempts) {
          await Future.delayed(const Duration(milliseconds: 300));
          jwt = await _authService.getAppJwt();
          refreshToken = await _authService.getRefreshToken();
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
            refreshToken: refreshToken,
          );
          print('✅ [NOTIFIER] Authentification complète (Firebase + JWT)');
        } else if (user != null) {
          state = AuthState.authenticated(user);
          print('⚠️ [NOTIFIER] Firebase authentifié mais JWT manquant');
        }
      }
    };

    // Écouter les erreurs d'authentification
    _authService.onAuthenticationError = (error) async {
      state = AuthState.error(error);
      print('❌ [NOTIFIER] Erreur d\'authentification: $error');
    };
  }

  Future<void> _checkTokens(User user) async {
    try {
      final existingJwt = await _authService.getAppJwt();
      final existingRefresh = await _authService.getRefreshToken();

      if (existingJwt != null && existingJwt.isNotEmpty) {
        state = AuthState.fullyAuthenticated(
          user: user,
          jwtToken: existingJwt,
          refreshToken: existingRefresh,
        );
        print('✅ [NOTIFIER] Tokens déjà présents');
      }
    } catch (e) {
      print('❌ [NOTIFIER] Erreur vérification tokens: $e');
    }
  }

  /*
  // Nouvelle méthode pour gérer les erreurs 401
  Future<void> handleUnauthorized() async {
    print('⚠️ [NOTIFIER] Erreur 401 - Tentative de refresh token...');

    try {
      final newToken = await _authService.refreshJwtToken();

      if (newToken != null && state.user != null) {
        final refreshToken = await _authService.getRefreshToken();
        state = AuthState.fullyAuthenticated(
          user: state.user!,
          jwtToken: newToken,
          refreshToken: refreshToken,
        );
        print('✅ [NOTIFIER] Token rafraîchi avec succès');
      } else {
        // Impossible de rafraîchir, déconnexion
        print('❌ [NOTIFIER] Échec du refresh - Déconnexion');
        await signOut();
      }
    } catch (e) {
      print('❌ [NOTIFIER] Erreur handleUnauthorized: $e');
      await signOut();
    }
  }

   */

  // Méthode de déconnexion améliorée
  Future<void> signOut() async {
    print('🔴 [NOTIFIER] signOut() appelé');

    try {
      state = AuthState.initial;
      await _authService.signOut();

      final userAfter = _authService.currentUser;
      print('👤 [NOTIFIER] Utilisateur après service.signOut(): ${userAfter?.uid ?? 'null'}');

      await Future.delayed(const Duration(milliseconds: 200));

      if (_authService.currentUser != null) {
        print('⚠️ [NOTIFIER] Utilisateur toujours connecté - tentative de force');
        await _authService.forceSignOut();
        state = AuthState.initial;
      }

      print('✅ [NOTIFIER] signOut() terminé');
    } catch (e, stack) {
      print('❌ [NOTIFIER] Erreur signOut: $e');
      print('📚 [NOTIFIER] Stack: $stack');
      state = AuthState.initial;
      rethrow;
    }
  }

  // Méthode pour réinitialiser manuellement l'état
  void reset() {
    print('🟡 [NOTIFIER] reset() appelé');
    state = AuthState.initial;
  }

  // Méthode pour forcer une erreur
  void setError(Object error) {
    print('❌ [NOTIFIER] setError(): $error');
    state = AuthState.error(error);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

// StateNotifierProvider
final authStateNotifierProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthStateNotifier(
    authService: authService,
    ref: ref,
  );
});

// Providers utilitaires
final isFullyAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateNotifierProvider);
  return authState.isFullyAuthenticated;
});

final appJwtSyncProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateNotifierProvider);
  return authState.jwtToken;
});

final refreshTokenSyncProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateNotifierProvider);
  return authState.refreshToken;
});

final currentUserSyncProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateNotifierProvider);
  return authState.user;
});

final isAuthenticatingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateNotifierProvider);
  return authState.status == AuthStatus.authenticated;
});

final authErrorProvider = Provider<Object?>((ref) {
  final authState = ref.watch(authStateNotifierProvider);
  return authState.error;
});

/*
// Provider séparé pour configurer le callback unauthorized (à utiliser dans main.dart)
final unauthorizedCallbackProvider = Provider<void Function()>((ref) {
  return () {
    // Cette fonction sera appelée quand une erreur 401 non récupérable survient
    ref.read(authStateNotifierProvider.notifier).handleUnauthorized();
  };
});

 */