import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/user_profile_repository_impl.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/repositories/user_profile_repository.dart';

part 'user_profile_controller.g.dart';

@riverpod
class UserProfileController extends _$UserProfileController {
  @override
  FutureOr<UserProfileEntity> build() {
    return ref.watch(getUserProfileProvider.future);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
            () => ref.refresh(getUserProfileProvider.future));
  }

  Future<void> updateProfile({
    String? username,
    int? gender,
    DateTime? birthdate,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(userProfileRepositoryProvider);
      await repository.updateProfile(
        username: username,
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
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(userProfileRepositoryProvider);
      await repository.updatePhoto(photoPath);
      return ref.refresh(getUserProfileProvider.future);
    });
  }
}