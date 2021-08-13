import 'package:shopping_app/service_interface/database_service.dart';
import 'package:shopping_app/services/user_service.dart';
import 'package:sqflite/sqflite.dart';

import 'database_provider.dart';

class CartService extends DatabaseService {
  final UsersService usersService;

  static Map<String, dynamic> localCartItems = {};

  @override
  DatabaseProvider databaseProvider;

  CartService(this.usersService, this.databaseProvider);

  Future<List<Map<String, dynamic>>> get(
      {int? id, required String userName, required String password}) {
    return Future.value([{}]);
  }

  @override
  Future<bool> insert(String tableName, Map<String, dynamic> data) async {
    final db = await databaseProvider.db();
    return db
        .insert('$tableName', data,
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) {
      if (value != 0) {
        return Future.value(true);
      }
      return Future.value(false);
    });
  }

  @override
  Future<bool> delete(String tableName, Map<String, dynamic> data) async {
    final db = await databaseProvider.db();
    return db.delete('$tableName',
        where: "id= ? AND product= ?",
        whereArgs: [data['id'], data['product']]).then((value) {
      if (value != 0) {
        return Future.value(true);
      }
      return Future.value(false);
    });
  }
}
