import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../../../../core/providers/network_providers.dart';
import '../../../../providers/auth_provider.dart' hide dioProvider;
import '../models/user_profile_model.dart';

part 'user_profile_remote_data_source.g.dart';

abstract class UserProfileRemoteDataSource {
  Future<UserProfileModel> getProfile();
  Future<String> getAboutMe();
  Future<String> getPhoto();
  Future<void> updateProfile({
    String? username,
    int? gender,
    DateTime? birthdate,
  });
  Future<void> updateAboutMe(String aboutMe);
  Future<void> updatePhoto(String photoPath);
}

@riverpod
UserProfileRemoteDataSource userProfileRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  final authState = ref.watch(authStateNotifierProvider);
  return UserProfileRemoteDataSourceImpl(dio, authState.jwtToken);
}

class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final Dio _dio;
  final String? _jwtToken;

  UserProfileRemoteDataSourceImpl(this._dio, this._jwtToken) {
    if (_jwtToken != null) {
      _dio.options.headers['Authorization'] = 'Bearer $_jwtToken';
    }
  }

  @override
  Future<UserProfileModel> getProfile() async {
    final response = await _dio.get('/api/account/me');
    return UserProfileModel.fromJson(response.data);
  }

  @override
  Future<String> getAboutMe() async {
    final response = await _dio.get('/api/account/about-me');
    return response.data['about_me'] ?? '';
  }

  @override
  Future<String> getPhoto() async {
    final response = await _dio.get('/api/account/photo');
    return response.data['photo_url'] ?? '';
  }

  @override
  Future<void> updateProfile({
    String? username,
    int? gender,
    DateTime? birthdate,
  }) async {
    final data = <String, dynamic>{};
    if (username != null) data['username'] = username;
    if (gender != null) data['gender'] = gender;
    if (birthdate != null) data['birthdate'] = birthdate.toIso8601String();

    await _dio.put('/api/account/me', data: data);
  }

  @override
  Future<void> updateAboutMe(String aboutMe) async {
    await _dio.put('/api/account/about-me', data: {'about_me': aboutMe});
  }

  @override
  Future<void> updatePhoto(String photoPath) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(photoPath),
    });
    await _dio.put('/api/account/photo', data: formData);
  }
}