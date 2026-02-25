import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ApiService _apiService;

  final _storage = const FlutterSecureStorage();

  static const _tokenKey = 'firebase_id_token';
  static const _appJwtKey = 'app_jwt_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdentityKey = 'connected_user_identity';
  static const _userDisplayNameKey = 'connected_user_displayname';

  Future<void> Function(GoogleSignInAuthenticationEvent)? onAuthenticationEvent;
  Future<void> Function(Object)? onAuthenticationError;

  AuthService({
    this.onAuthenticationEvent,
    this.onAuthenticationError,
    required ApiService apiService,
  }) : _apiService = apiService;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  bool _isSignInInitialized = false;

  String? clientId;
  String? serverClientId = '1084343369802-36565dmgarm2gkos54eb6j9q6so0s9bf.apps.googleusercontent.com';
  List<String> scopes = <String>[
    'https://www.googleapis.com/auth/userinfo.email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ];
  final GoogleSignIn signIn = GoogleSignIn.instance;

  Future<void> _handleAuthenticationEvent(GoogleSignInAuthenticationEvent event) async {
    final GoogleSignInAccount? user = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    final GoogleSignInClientAuthorization? authorization = await user?.authorizationClient.authorizationForScopes(scopes);

    if (user != null && authorization != null) {
      print(user);
      print("===== user =======");

      try {
        final OAuthCredential googleCredential = GoogleAuthProvider.credential(
          accessToken: authorization.accessToken,
          idToken: user.authentication.idToken,
        );

        final UserCredential googleUserCredential = await FirebaseAuth.instance.signInWithCredential(googleCredential);

        IdTokenResult tokenResult = await FirebaseAuth.instance.currentUser!.getIdTokenResult();

        print('============================ tokenResult.token ==================================');
        print('============================ tokenResult.token ==================================');
        print('============================ tokenResult.token ==================================');
        log(tokenResult.token.toString());

        if (tokenResult.token != null) {
          await _storage.write(key: _tokenKey, value: tokenResult.token);
          await _storage.write(key: _userIdentityKey, value: user.displayName);
          await _storage.write(key: _userDisplayNameKey, value: user.displayName);

          try {
            print('🔄 Récupération du JWT applicatif... =======================================');
            final response = await _apiService.getJwtFromFirebaseToken(tokenResult.token!);

            // La réponse contient maintenant jwt ET refresh_token
            if (response is Map<String, dynamic>) {
              print('TOKEN ==============');
              log('***** from firebase token : ' + response['token'].toString());
              await _storage.write(key: _appJwtKey, value: response['token']);
              if (response['refresh_token'] != null) {
                print('REFRESH TOKEN ==============');
                print(response['refresh_token']);
                await _storage.write(key: _refreshTokenKey, value: response['refresh_token']);
              }
            } else {
              // Pour compatibilité avec l'ancien format
              await _storage.write(key: _appJwtKey, value: response.toString());
            }

            print('✅ JWT applicatif récupéré et stocké');
          } catch (e) {
            print('❌ Erreur lors de la récupération du JWT applicatif: $e');
          }

          if (onAuthenticationEvent != null) {
            await onAuthenticationEvent!(event);
          }

          print(tokenResult.token);
          print("====== tokenResult.token =======");
        }
      } catch (error) {
        print(error);
        print('error');

        if (onAuthenticationError != null) {
          await onAuthenticationError!(error);
        }
      }
    }
  }

  Future<void> _handleAuthenticationError(Object e) async {
    print(e);
    if (onAuthenticationError != null) {
      await onAuthenticationError!(e);
    }
  }

  Future<void> initGoogleSignIn() async {
    if (_isSignInInitialized) return;

    _isSignInInitialized = true;

    await signIn.initialize(clientId: clientId, serverClientId: serverClientId).then((_) async {
      signIn.authenticationEvents.listen(_handleAuthenticationEvent).onError(_handleAuthenticationError);
    });
  }

  Future<User?> signInWithGoogle() async {
    await initGoogleSignIn();

    if (GoogleSignIn.instance.supportsAuthenticate()) {
      try {
        await GoogleSignIn.instance.authenticate();
      } catch (e) {
        print("Erreur Google Sign-In : $e");
      }
    }
  }

  Future<String?> getAppJwt() async {
    return await _storage.read(key: _appJwtKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /*
  // Nouvelle méthode pour rafraîchir le token
  Future<String?> refreshJwtToken() async {
    try {
      final refreshToken = await getRefreshToken();

      if (refreshToken == null) {
        print('⚠️ Pas de refresh token disponible');
        return null;
      }

      print('🔄 Tentative de rafraîchissement du token...');
      final response = await _apiService.refreshJwtToken(refreshToken);

      if (response != null) {
        // Stocker le nouveau token
        await _storage.write(key: _appJwtKey, value: response['token']);

        // Si un nouveau refresh token est fourni (rotation), le stocker
        if (response['refresh_token'] != null) {
          await _storage.write(key: _refreshTokenKey, value: response['refresh_token']);
        }

        print('✅ Token rafraîchi avec succès');
        return response['token'];
      }
    } catch (e) {
      print('❌ Erreur lors du rafraîchissement du token: $e');
    }

    return null;
  }

   */

  // Méthode de déconnexion améliorée
  Future<void> signOut() async {
    print('🔴 DÉBUT DÉCONNEXION - Utilisateur avant: ${_firebaseAuth.currentUser?.uid}');

    try {
      // 1. Révoquer le refresh token côté serveur
      final refreshToken = await getRefreshToken();
      if (refreshToken != null) {
        try {
          await _apiService.revokeRefreshToken(refreshToken);
          print('✅ Refresh token révoqué côté serveur');
        } catch (e) {
          print('⚠️ Erreur lors de la révocation du refresh token: $e');
        }
      }

      // 2. Déconnexion Google
      await GoogleSignIn.instance.signOut();

      // 3. Déconnexion Firebase
      print('🟡 Déconnexion Firebase...');
      await _firebaseAuth.signOut();
      print('✅ Firebase signOut() exécuté');

      // 4. Vérification post-déconnexion
      final userAfter = _firebaseAuth.currentUser;
      print('👤 Utilisateur après Firebase.signOut(): $userAfter');

      // 5. Attendre un cycle d'event loop pour propager le changement
      await Future.delayed(const Duration(milliseconds: 100));

      // 6. Nettoyer le stockage
      print('🟡 Nettoyage du stockage...');
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _appJwtKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userIdentityKey);
      await _storage.delete(key: _userDisplayNameKey);
      print('✅ Stockage nettoyé');

      // 7. Vérification finale
      final finalUser = _firebaseAuth.currentUser;
      if (finalUser != null) {
        print('⚠️ ATTENTION: Utilisateur toujours présent après déconnexion!');
        await forceSignOut();
      } else {
        print('✅ Utilisateur bien null après déconnexion');
      }

      print('✅ DÉCONNEXION TERMINÉE');
    } catch (e, stack) {
      print('❌ ERREUR DÉCONNEXION: $e');
      print('📚 Stack: $stack');
      rethrow;
    }
  }

  // Méthode utilitaire pour forcer une déconnexion radicale
  Future<void> forceSignOut() async {
    print('🔴 FORCE SIGN OUT - Méthode radicale');

    try {
      await _firebaseAuth.signOut();
      await GoogleSignIn.instance.signOut();
      await _storage.deleteAll();
      await Future.delayed(const Duration(milliseconds: 200));
      print('✅ Force sign out exécuté');
      print('👤 Utilisateur après force: ${_firebaseAuth.currentUser?.uid ?? 'null'}');
    } catch (e) {
      print('❌ Erreur force sign out: $e');
    }
  }

  bool isLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  Future<bool> isUserLoggedIn() async {
    return _firebaseAuth.currentUser != null;
  }


  Future<String?> refreshJwtToken() async {
    try {
      final refreshToken = await getRefreshToken();

      if (refreshToken == null) {
        print('⚠️ Pas de refresh token disponible');
        return null;
      }

      print('🔄 Tentative de rafraîchissement du token...');
      final response = await _apiService.refreshJwtToken(refreshToken);

      if (response != null) {
        // Stocker le nouveau token
        await _storage.write(key: _appJwtKey, value: response['token']);

        // Si un nouveau refresh token est fourni (rotation), le stocker
        if (response['refresh_token'] != null) {
          await _storage.write(key: _refreshTokenKey, value: response['refresh_token']);
        }

        print('✅ Token rafraîchi avec succès');
        return response['token'];
      }
    } catch (e) {
      print('❌ Erreur lors du rafraîchissement du token: $e');
    }

    return null;
  }
}