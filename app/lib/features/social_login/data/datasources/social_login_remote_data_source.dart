import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../../../../core/providers/network_providers.dart';
import '../models/social_login_model.dart';

part 'social_login_remote_data_source.g.dart';

abstract class SocialLoginRemoteDataSource {
  Future<List<SocialLoginModel>> fetchSocialLogins();
  Future<SocialLoginModel> fetchSocialLogin(String id);
}

@riverpod
SocialLoginRemoteDataSource socialLoginRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return SocialLoginRemoteDataSourceImpl(dio);
}

class SocialLoginRemoteDataSourceImpl implements SocialLoginRemoteDataSource {
  final Dio _dio;
  
  SocialLoginRemoteDataSourceImpl(this._dio);

  @override
  Future<List<SocialLoginModel>> fetchSocialLogins() async {
    // final response = await _dio.get('/social_logins');
    // return (response.data as List).map((e) => SocialLoginModel.fromJson(e)).toList();
    await Future.delayed(const Duration(seconds: 1));
    return [
      const SocialLoginModel(id: '1', name: 'Item 1'),
      const SocialLoginModel(id: '2', name: 'Item 2'),
    ];
  }

  @override
  Future<SocialLoginModel> fetchSocialLogin(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    return SocialLoginModel(id: id, name: 'Item ');
  }
}
