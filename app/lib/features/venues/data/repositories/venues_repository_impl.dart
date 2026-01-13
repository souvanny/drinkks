import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/venues_entity.dart';
import '../../domain/repositories/venues_repository.dart';
import '../datasources/venues_remote_data_source.dart';

part 'venues_repository_impl.g.dart';

@riverpod
VenuesRepository venuesRepository(Ref ref) {
  final remoteDataSource = ref.watch(venuesRemoteDataSourceProvider);
  return VenuesRepositoryImpl(remoteDataSource);
}

class VenuesRepositoryImpl implements VenuesRepository {
  final VenuesRemoteDataSource _remoteDataSource;

  VenuesRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<VenuesEntity>> getVenuess() async {
    final models = await _remoteDataSource.fetchVenuess();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<VenuesEntity> getVenues(String id) async {
    final model = await _remoteDataSource.fetchVenues(id);
    return model.toEntity();
  }
}
