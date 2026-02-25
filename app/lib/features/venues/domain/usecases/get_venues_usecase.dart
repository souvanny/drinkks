// flutter_lib/features/venues/domain/usecases/get_venues_usecase.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/venues_entity.dart';
import '../repositories/venues_repository.dart';
import '../../data/repositories/venues_repository_impl.dart';

part 'get_venues_usecase.g.dart';

@riverpod
Future<List<VenuesEntity>> getVenues(
    Ref ref, {
      String? search,
      int? type,
    }) {
  return ref.watch(venuesRepositoryProvider).getAllVenues(
    search: search,
    type: type,
  );
}