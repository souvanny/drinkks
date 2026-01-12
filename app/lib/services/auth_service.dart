import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream pour écouter les changements d'authentification
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Connexion avec Google
  Future<User?> signInWithGoogle() async {
    try {
      print('🔵 Début de la connexion Google...');

      // 1. Lancer le flux de connexion Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('❌ L\'utilisateur a annulé la connexion');
        return null;
      }

      // 2. Obtenir les détails d'authentification
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // 3. Créer les credentials Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('✅ Google auth réussie, connexion à Firebase...');

      // 4. Se connecter à Firebase avec les credentials
      final UserCredential userCredential =
      await _firebaseAuth.signInWithCredential(credential);

      final user = userCredential.user;
      print('✅ Firebase connexion réussie: ${user?.email}');

      return user;

    } catch (e) {
      print('❌ Erreur lors de la connexion Google: $e');
      rethrow;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      print('✅ Déconnexion réussie');
    } catch (e) {
      print('❌ Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }

  // Vérifier si l'utilisateur est connecté
  bool isLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }
}