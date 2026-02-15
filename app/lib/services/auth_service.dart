import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart'; // Ajout de l'import

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ApiService _apiService; // Ajout du service API

  // Instance du stockage sécurisé
  final _storage = const FlutterSecureStorage();

  // Clé pour le stockage
  static const _tokenKey = 'firebase_id_token';
  static const _appJwtKey = 'app_jwt_token'; // Nouvelle clé pour le JWT applicatif
  static const _userIdentityKey = 'connected_user_identity';
  static const _userDisplayNameKey = 'connected_user_displayname';

  // Callbacks injectés
  final Future<void> Function(GoogleSignInAuthenticationEvent)? onAuthenticationEvent;
  final Future<void> Function(Object)? onAuthenticationError;

  AuthService({
    this.onAuthenticationEvent,
    this.onAuthenticationError,
    required ApiService apiService, // Ajout du paramètre
  }) : _apiService = apiService;

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream pour écouter les changements d'authentification
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  bool _isSignInInitialized = false;

  // GOOGLE SIGNIN
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

        if (tokenResult.token != null) {
          // Stocker le token Firebase
          await _storage.write(key: _tokenKey, value: tokenResult.token);
          await _storage.write(key: _userIdentityKey, value: user.displayName);
          await _storage.write(key: _userDisplayNameKey, value: user.displayName);

          // NOUVEAU : Appeler l'API pour obtenir le JWT applicatif
          try {
            print('🔄 Récupération du JWT applicatif...');
            final appJwt = await _apiService.getJwtFromFirebaseToken(tokenResult.token!);

            // Stocker le JWT applicatif
            await _storage.write(key: _appJwtKey, value: appJwt);
            print('✅ JWT applicatif récupéré et stocké');

          } catch (e) {
            print('❌ Erreur lors de la récupération du JWT applicatif: $e');
            // Ne pas bloquer la connexion si l'API JWT échoue ?
            // Selon votre logique métier, vous pouvez choisir de rethrow ou non
            if (e is ApiException) {
              print('Détails API: ${e.message} (${e.statusCode})');
            }

            // Option 1: Laisser l'erreur remonter (décommentez la ligne suivante)
            // rethrow;

            // Option 2: Continuer quand même (actuellement choisi)
          }

          // Appeler le callback injecté si présent
          if (onAuthenticationEvent != null) {
            await onAuthenticationEvent!(event);
          }

          print(tokenResult.token);
          print("====== tokenResult.token =======");
        }

      } catch (error) {
        print(error);
        print('error');

        // Appeler le callback d'erreur
        if (onAuthenticationError != null) {
          await onAuthenticationError!(error);
        }
      }
    }
  }

  // ... (le reste du code reste identique)

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

  // Nouvelle méthode pour récupérer le JWT applicatif
  Future<String?> getAppJwt() async {
    return await _storage.read(key: _appJwtKey);
  }

  // Méthode de déconnexion améliorée
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await GoogleSignIn.instance.signOut();

      // Nettoyer le stockage
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _appJwtKey);
      await _storage.delete(key: _userIdentityKey);
      await _storage.delete(key: _userDisplayNameKey);

      print('✅ Déconnexion réussie');
    } catch (e) {
      print('❌ Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }

  bool isLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }
}