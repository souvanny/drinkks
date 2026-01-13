import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../../../../core/providers/network_providers.dart';
import '../models/tables_model.dart';

part 'tables_remote_data_source.g.dart';

abstract class TablesRemoteDataSource {
  Future<List<TablesModel>> fetchTabless();
  Future<TablesModel> fetchTables(String id);
}

@riverpod
TablesRemoteDataSource tablesRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return TablesRemoteDataSourceImpl(dio);
}

class TablesRemoteDataSourceImpl implements TablesRemoteDataSource {
  final Dio _dio;
  
  TablesRemoteDataSourceImpl(this._dio);

  @override
  Future<List<TablesModel>> fetchTabless() async {
    // final response = await _dio.get('/tabless');
    // return (response.data as List).map((e) => TablesModel.fromJson(e)).toList();
    await Future.delayed(const Duration(seconds: 1));
    return [
      const TablesModel(id: '1', name: 'Item 1'),
      const TablesModel(id: '2', name: 'Item 2'),
    ];
  }

  @override
  Future<TablesModel> fetchTables(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    return TablesModel(id: id, name: 'Item ');
  }
}
