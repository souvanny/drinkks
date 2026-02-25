import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../providers/auth_provider.dart';
import '../../data/repositories/user_profile_repository_impl.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../../../services/account_service.dart'; // NOUVEAU

part 'user_profile_controller.g.dart';

@riverpod
class UserProfileController extends _$UserProfileController {
  late AccountService _accountService; // NOUVEAU

  @override
  FutureOr<UserProfileEntity> build() {
    _accountService = ref.watch(accountServiceProvider); // NOUVEAU
    return ref.watch(getUserProfileProvider.future);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
            () => ref.refresh(getUserProfileProvider.future));
  }

  Future<void> updateProfile({
    String? displayName,
    int? gender,
    DateTime? birthdate,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(userProfileRepositoryProvider);
      await repository.updateProfile(
        displayName: displayName,
        gender: gender,
        birthdate: birthdate,
      );
      return ref.refresh(getUserProfileProvider.future);
    });
  }

  Future<void> updateAboutMe(String aboutMe) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(userProfileRepositoryProvider);
      await repository.updateAboutMe(aboutMe);
      return ref.refresh(getUserProfileProvider.future);
    });
  }

  Future<void> updatePhoto(String photoPath) async {
    print('🔄 [Controller] Début upload photo: $photoPath');
    state = const AsyncValue.loading();

    try {
      // Tentative d'upload
      await _accountService.updatePhoto(photoPath);

      // Si succès, rafraîchir le profil
      state = await AsyncValue.guard(() async {
        return ref.refresh(getUserProfileProvider.future);
      });

      print('✅ [Controller] Upload réussi');
    } catch (e) {
      print('❌ [Controller] Erreur upload: $e');

      // Vérifier si c'est une erreur 401 (token expiré)
      if (e.toString().contains('401') || e.toString().contains('Expired JWT Token')) {
        print('🔄 [Controller] Token expiré, tentative de refresh...');

        try {
          // Récupérer le refresh token
          final authService = ref.read(authServiceProvider);
          final newToken = await authService.refreshJwtToken(); // À implémenter

          if (newToken != null) {
            print('✅ [Controller] Token rafraîchi, nouvelle tentative...');
            // Réessayer l'upload avec le nouveau token
            await _accountService.updatePhoto(photoPath);

            // Rafraîchir le profil
            state = await AsyncValue.guard(() async {
              return ref.refresh(getUserProfileProvider.future);
            });

            print('✅ [Controller] Upload réussi après refresh');
            return;
          }
        } catch (refreshError) {
          print('❌ [Controller] Échec du refresh: $refreshError');
          // En cas d'échec, déconnecter l'utilisateur
          await ref.read(authStateNotifierProvider.notifier).signOut();
        }
      }

      // Si on arrive ici, c'est que toutes les tentatives ont échoué
      state = AsyncValue.error(e, StackTrace.current);
    }
  }


}