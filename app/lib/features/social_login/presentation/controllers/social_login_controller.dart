import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../providers/auth_provider.dart';
import '../../domain/entities/social_login_entity.dart';
import '../../domain/usecases/get_social_logins_usecase.dart';
import '../../../../services/auth_service.dart';

part 'social_login_controller.g.dart';

@riverpod
class SocialLoginController extends _$SocialLoginController {
  late AuthService _authService;

  @override
  FutureOr<List<SocialLoginEntity>> build() {
    _authService = ref.read(authServiceProvider);

    print('🟡 SocialLoginController initialisé');
    return ref.watch(getSocialLoginsProvider.future);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.refresh(getSocialLoginsProvider.future));
  }

  // NOUVELLE MÉTHODE : Connexion avec Google
  Future<User?> signInWithGoogle() async {
    print('🔵 SocialLoginController.signInWithGoogle() appelé');

    try {
      // Appeler le service d'authentification
      await _authService.signInWithGoogle();
    } catch (e, stack) {
      print('❌ Erreur dans signInWithGoogle: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  // Méthode de déconnexion
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      print('✅ Déconnexion effectuée depuis SocialLoginController');
    } catch (e) {
      print('❌ Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }
}
