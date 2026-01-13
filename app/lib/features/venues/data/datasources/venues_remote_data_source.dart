import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../../../../core/providers/network_providers.dart';
import '../models/venues_model.dart';

part 'venues_remote_data_source.g.dart';

abstract class VenuesRemoteDataSource {
  Future<List<VenuesModel>> fetchVenuess();
  Future<VenuesModel> fetchVenues(String id);
}

@riverpod
VenuesRemoteDataSource venuesRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return VenuesRemoteDataSourceImpl(dio);
}

class VenuesRemoteDataSourceImpl implements VenuesRemoteDataSource {
  final Dio _dio;
  
  VenuesRemoteDataSourceImpl(this._dio);

  @override
  Future<List<VenuesModel>> fetchVenuess() async {
    // final response = await _dio.get('/venuess');
    // return (response.data as List).map((e) => VenuesModel.fromJson(e)).toList();
    await Future.delayed(const Duration(seconds: 1));
    return [
      const VenuesModel(id: '1', name: 'Item 1'),
      const VenuesModel(id: '2', name: 'Item 2'),
    ];
  }

  @override
  Future<VenuesModel> fetchVenues(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    return VenuesModel(id: id, name: 'Item ');
  }
}
