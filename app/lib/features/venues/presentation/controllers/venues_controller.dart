import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/venues_entity.dart';
import '../../domain/usecases/get_venuess_usecase.dart';

part 'venues_controller.g.dart';

@riverpod
class VenuesController extends _$VenuesController {
  @override
  FutureOr<List<VenuesEntity>> build() {
    return ref.watch(getVenuessProvider.future);
  }
  
  Future<void> refresh() async {
     state = const AsyncValue.loading();
     state = await AsyncValue.guard(() => ref.refresh(getVenuessProvider.future));
  }
}
