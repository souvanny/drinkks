import 'package:riverpod_annotation/riverpod_annotation.dart';
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
    state = await AsyncValue.guard(() async {
      try {
        await _accountService.updatePhoto(photoPath);
        print('✅ [Controller] Upload réussi');
        return ref.refresh(getUserProfileProvider.future);
      } catch (e) {
        print('❌ [Controller] Erreur upload: $e');
        rethrow;
      }
    });
  }


}