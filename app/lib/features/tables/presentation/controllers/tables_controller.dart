import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/tables_entity.dart';
import '../../domain/usecases/get_tabless_usecase.dart';

part 'tables_controller.g.dart';

@riverpod
class TablesController extends _$TablesController {
  @override
  FutureOr<List<TablesEntity>> build() {
    return ref.watch(getTablessProvider.future);
  }
  
  Future<void> refresh() async {
     state = const AsyncValue.loading();
     state = await AsyncValue.guard(() => ref.refresh(getTablessProvider.future));
  }
}
