import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/venues_entity.dart';
import '../repositories/venues_repository.dart';
import '../../data/repositories/venues_repository_impl.dart';

part 'get_venuess_usecase.g.dart';

@riverpod
Future<List<VenuesEntity>> getVenuess(Ref ref) {
  return ref.watch(venuesRepositoryProvider).getVenuess();
}
