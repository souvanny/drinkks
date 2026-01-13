import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/tables_entity.dart';
import '../../domain/repositories/tables_repository.dart';
import '../datasources/tables_remote_data_source.dart';

part 'tables_repository_impl.g.dart';

@riverpod
TablesRepository tablesRepository(Ref ref) {
  final remoteDataSource = ref.watch(tablesRemoteDataSourceProvider);
  return TablesRepositoryImpl(remoteDataSource);
}

class TablesRepositoryImpl implements TablesRepository {
  final TablesRemoteDataSource _remoteDataSource;

  TablesRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<TablesEntity>> getTabless() async {
    final models = await _remoteDataSource.fetchTabless();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<TablesEntity> getTables(String id) async {
    final model = await _remoteDataSource.fetchTables(id);
    return model.toEntity();
  }
}
