import 'dart:async';

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
  final Object? error;

  const AuthState({
    required this.status,
    this.user,
    this.jwtToken,
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

  // Méthode copyWith
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
    return 'AuthState(status: $status, user: ${user?.uid ?? 'null'}, hasJwt: ${jwtToken != null})';
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

    // Écouter DIRECTEMENT le stream Firebase Auth (plus fiable)
    _authSubscription = _authService.authStateChanges.listen(
          (user) {
        print('🔵 [NOTIFIER] Firebase Auth State Change: ${user?.uid ?? 'null'}');

        if (user != null) {
          print('✅ [NOTIFIER] Utilisateur Firebase connecté');
          state = AuthState.authenticated(user);
          _checkJwt(user);
        } else {
          // ⚠️ CRITIQUE: Utilisateur déconnecté
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
        // Le traitement est déjà fait par le listener direct
      });
    });

    // Écouter les événements d'authentification
    _authService.onAuthenticationEvent = (event) async {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        print('📡 [NOTIFIER] Événement d\'authentification reçu');

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

  Future<void> _checkJwt(User user) async {
    try {
      final existingJwt = await _authService.getAppJwt();
      if (existingJwt != null && existingJwt.isNotEmpty) {
        state = AuthState.fullyAuthenticated(
          user: user,
          jwtToken: existingJwt,
        );
        print('✅ [NOTIFIER] JWT déjà présent');
      }
    } catch (e) {
      print('❌ [NOTIFIER] Erreur vérification JWT: $e');
    }
  }

  // MÉTHODE DE DÉCONNEXION AMÉLIORÉE
  Future<void> signOut() async {
    print('🔴 [NOTIFIER] signOut() appelé');

    try {
      // 1. Réinitialisation immédiate de l'état
      state = AuthState.initial;
      print('✅ [NOTIFIER] État réinitialisé à initial');

      // 2. Déconnexion via le service
      await _authService.signOut();

      // 3. Vérification après déconnexion
      final userAfter = _authService.currentUser;
      print('👤 [NOTIFIER] Utilisateur après service.signOut(): ${userAfter?.uid ?? 'null'}');

      // 4. Attendre un peu pour la propagation
      await Future.delayed(const Duration(milliseconds: 200));

      // 5. Si toujours connecté, forcer la réinitialisation
      if (_authService.currentUser != null) {
        print('⚠️ [NOTIFIER] Utilisateur toujours connecté - tentative de force');
        await _authService.forceSignOut();
        state = AuthState.initial;
      }

      print('✅ [NOTIFIER] signOut() terminé');

    } catch (e, stack) {
      print('❌ [NOTIFIER] Erreur signOut: $e');
      print('📚 [NOTIFIER] Stack: $stack');

      // En cas d'erreur, forcer la réinitialisation
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