import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static const String userTable =
      'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, password TEXT, dateOfBirth TEXT)';

  static const String cartTable = 'CREATE TABLE cart(id INTEGER, product TEXT)';

  static final _instance = DatabaseProvider._internal();
  static DatabaseProvider get = _instance;

  Database? _dataBase;
  bool isInitialized = false;

  DatabaseProvider._internal() {
    initTable();
  }

  Future<Database> db() async {
    if (!isInitialized) {
      await initTable();
    }

    return Future.value(_dataBase);
  }

  Future<void> initTable() async {
    final Directory documentDirectory =
        await getApplicationDocumentsDirectory();

    await databaseExists(documentDirectory.path);
    openDatabase(join(await getDatabasesPath(), 'BShoppingDB.db'),
            onCreate: (db, version) async {
      await db.execute(userTable);
      await db.execute(cartTable);
    }, version: 1)
        .then((value) {
      /// create the database and hold in DatabaseService
      _dataBase = value;
      isInitialized = true;
    });
  }
}
