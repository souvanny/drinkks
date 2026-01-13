import '../entities/tables_entity.dart';

abstract class TablesRepository {
  Future<List<TablesEntity>> getTabless();
  Future<TablesEntity> getTables(String id);
}
