import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../../../../core/providers/network_providers.dart';
import '../models/account_model.dart';

part 'account_remote_data_source.g.dart';

abstract class AccountRemoteDataSource {
  Future<List<AccountModel>> fetchAccounts();
  Future<AccountModel> fetchAccount(String id);
}

@riverpod
AccountRemoteDataSource accountRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return AccountRemoteDataSourceImpl(dio);
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final Dio _dio;
  
  AccountRemoteDataSourceImpl(this._dio);

  @override
  Future<List<AccountModel>> fetchAccounts() async {
    // final response = await _dio.get('/accounts');
    // return (response.data as List).map((e) => AccountModel.fromJson(e)).toList();
    await Future.delayed(const Duration(seconds: 1));
    return [
      const AccountModel(id: '1', name: 'Item 1'),
      const AccountModel(id: '2', name: 'Item 2'),
    ];
  }

  @override
  Future<AccountModel> fetchAccount(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    return AccountModel(id: id, name: 'Item ');
  }
}
