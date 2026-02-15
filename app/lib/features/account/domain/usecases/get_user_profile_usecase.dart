import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/user_profile_repository.dart';
import '../../data/repositories/user_profile_repository_impl.dart';

part 'get_user_profile_usecase.g.dart';

@riverpod
Future<UserProfileEntity> getUserProfile(Ref ref) {
  return ref.watch(userProfileRepositoryProvider).getProfile();
}