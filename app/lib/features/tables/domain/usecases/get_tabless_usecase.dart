import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/tables_entity.dart';
import '../repositories/tables_repository.dart';
import '../../data/repositories/tables_repository_impl.dart';

part 'get_tabless_usecase.g.dart';

@riverpod
Future<List<TablesEntity>> getTabless(Ref ref) {
  return ref.watch(tablesRepositoryProvider).getTabless();
}
