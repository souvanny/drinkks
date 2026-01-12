import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream pour écouter les changements d'authentification
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  bool _isSignInInitialized = false;

  //


  // GOOGLE SIGNIN

  String? clientId = '1084343369802-ju6glrsj87do2hf4h3o7cp2u6ak7c8hr.apps.googleusercontent.com';
  String? serverClientId = '1084343369802-36565dmgarm2gkos54eb6j9q6so0s9bf.apps.googleusercontent.com';

  // String? serverClientId = '347370813567-6lj7snvup33n9nbt43r7iedrluo1mk6s.apps.googleusercontent.com';
  List<String> scopes = <String>[
    // 'https://www.googleapis.com/auth/contacts.readonly',
    'https://www.googleapis.com/auth/userinfo.email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ];
  final GoogleSignIn signIn = GoogleSignIn.instance;


  Future<void> _handleAuthenticationEvent(GoogleSignInAuthenticationEvent event) async {

    print("#### TEST 1");

    final GoogleSignInAccount? user = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    // Check for existing authorization.
    // #docregion CheckAuthorization
    final GoogleSignInClientAuthorization? authorization = await user?.authorizationClient.authorizationForScopes(scopes);
    // #enddocregion CheckAuthorization

    print("#### TEST 2");

    if (user != null && authorization != null) {
      print(user);

      try {

        final OAuthCredential googleCredential = GoogleAuthProvider.credential(
          accessToken: authorization.accessToken,
          idToken: user.authentication.idToken,
        );

        final UserCredential googleUserCredential =
        await FirebaseAuth.instance.signInWithCredential(googleCredential);

        IdTokenResult tokenResult =
        await FirebaseAuth.instance.currentUser!.getIdTokenResult();

        // await fetchJwtToken(tokenResult.token);


      } catch (error) {

        print("#### TEST 3");

        print(error);
        print('error');

      }

    }
  }

  Future<void> _handleAuthenticationError(Object e) async {

    print("#### TEST 4");

    print(e);
  }

  Future<void> initGoogleSignIn() async {
    if (_isSignInInitialized) return; // Déjà fait → on sort

    _isSignInInitialized = true;

    await signIn.initialize(clientId: clientId, serverClientId: serverClientId).then((_) async {

      signIn.authenticationEvents
          .listen(_handleAuthenticationEvent)
          .onError(_handleAuthenticationError);

    });

  }

  // Connexion avec Google
  Future<User?> signInWithGoogle() async {

    await initGoogleSignIn();

    if (GoogleSignIn.instance.supportsAuthenticate()) {
      try {
        await GoogleSignIn.instance.authenticate();
      } catch (e) {
        print("Erreur Google Sign-In : $e");
      }
    }

    print("#### TEST 5");


  }

  // Déconnexion
  Future<void> signOut() async {

  }

  // Vérifier si l'utilisateur est connecté
  bool isLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }
}