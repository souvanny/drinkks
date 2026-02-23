import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'api_service.dart';

part 'account_service.g.dart';

class AccountService {
  final ApiService _apiService;

  AccountService({required ApiService apiService}) : _apiService = apiService;

  // Profile
  Future<Map<String, dynamic>> getProfile() async {
    return _apiService.getProfile();
  }

  Future<Map<String, dynamic>> getAboutMe() async {
    return _apiService.getAboutMe();
  }

  Future<Map<String, dynamic>> getPhoto() async {
    return _apiService.getPhoto();
  }

  Future<void> updateProfile({
    String? username,
    int? gender,
    DateTime? birthdate,
  }) async {
    await _apiService.updateProfile(
      username: username,
      gender: gender,
      birthdate: birthdate,
    );
  }

  Future<void> updateAboutMe(String aboutMe) async {
    await _apiService.updateAboutMe(aboutMe);
  }

  Future<void> updatePhoto(String photoPath) async {
    await _apiService.updatePhoto(photoPath);
  }
}

@riverpod
AccountService accountService(Ref ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AccountService(apiService: apiService);
}