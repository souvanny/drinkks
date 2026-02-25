// flutter_lib/features/venues/data/repositories/venues_repository_impl.dart

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
  Future<List<VenuesEntity>> getAllVenues({
    String? search,
    int? type,
  }) async {
    final models = await _remoteDataSource.getAllVenues(
      search: search,
      type: type,
    );

    // Trier par rank croissant
    models.sort((a, b) => (a.rank ?? 0).compareTo(b.rank ?? 0));

    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<VenuesEntity> getVenue(String uuid) async {
    final model = await _remoteDataSource.getVenue(uuid);
    return model.toEntity();
  }
}