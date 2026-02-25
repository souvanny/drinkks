import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/venues_entity.dart';
import '../../domain/repositories/venues_repository.dart';
import '../datasources/venues_remote_data_source.dart';
import '../models/paginated_response_model.dart';

part 'venues_repository_impl.g.dart';

@riverpod
VenuesRepository venuesRepository(Ref ref) {
  final remoteDataSource = ref.watch(venuesRemoteDataSourceProvider);
  return VenuesRepositoryImpl(remoteDataSource);
}

class VenuesRepositoryImpl implements VenuesRepository {
  final VenuesRemoteDataSource _remoteDataSource;

  // Cache pour stocker la dernière réponse paginée
  PaginatedResponseModel? _lastResponse;

  VenuesRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<VenuesEntity>> getVenues({
    required int page,
    required int limit,
    String? search,
    int? type,
  }) async {
    final response = await _remoteDataSource.getVenues(
      page: page,
      limit: limit,
      search: search,
      type: type,
    );

    // Mettre en cache la réponse pour les métadonnées
    _lastResponse = response;

    return response.items.map((model) => model.toEntity()).toList();
  }

  @override
  Future<VenuesEntity> getVenue(String uuid) async {
    final model = await _remoteDataSource.getVenue(uuid);
    return model.toEntity();
  }

  @override
  Future<int> getTotalPages() async {
    return _lastResponse?.pages ?? 1;
  }

  @override
  Future<int> getTotalItems() async {
    return _lastResponse?.total ?? 0;
  }
}