import 'package:shopping_app/services/database_provider.dart';

abstract class DatabaseService {
  late DatabaseProvider databaseProvider;

  Future<bool> insert(String tableName, Map<String, dynamic> data) =>
      Future.value(false);

  Future<bool> delete(String tableName, Map<String, dynamic> data) =>
      Future.value(false);

  Future<List<Map<String, dynamic>>> get(
          {int? id, required String userName, required String password}) =>
      Future.value([]);

  Future<bool> isExist(String userName, String passWord) => Future.value(false);
}
