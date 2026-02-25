// flutter_lib/features/venues/data/datasources/venues_remote_data_source.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../services/venue_service.dart';
import '../models/venues_model.dart';
import '../models/paginated_response_model.dart';

part 'venues_remote_data_source.g.dart';

abstract class VenuesRemoteDataSource {
  Future<PaginatedResponseModel> getVenues({
    required int page,
    required int limit,
    String? search,
    int? type,
  });
  Future<VenuesModel> getVenue(String uuid);
}

@riverpod
VenuesRemoteDataSource venuesRemoteDataSource(Ref ref) {
  final venueService = ref.watch(venueServiceProvider);
  return VenuesRemoteDataSourceImpl(venueService);
}

class VenuesRemoteDataSourceImpl implements VenuesRemoteDataSource {
  final VenueService _venueService;

  VenuesRemoteDataSourceImpl(this._venueService);

  @override
  Future<PaginatedResponseModel> getVenues({
    required int page,
    required int limit,
    String? search,
    int? type,
  }) async {
    final response = await _venueService.getVenues(
      page: page,
      limit: limit,
      search: search,
      type: type,
    );

    return PaginatedResponseModel.fromJson(response);
  }

  @override
  Future<VenuesModel> getVenue(String uuid) async {
    final response = await _venueService.getVenue(uuid);
    return VenuesModel.fromJson(response);
  }
}