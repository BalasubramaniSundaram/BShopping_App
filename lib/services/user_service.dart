import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shopping_app/service_interface/database_service.dart';
import 'package:shopping_app/services/database_provider.dart';
import 'package:sqflite/sqflite.dart';

class UsersService with DatabaseService, ChangeNotifier {
  late File userJsonFile;

  late Directory documentDirectory;

  @override
  DatabaseProvider databaseProvider;

  UsersService(this.databaseProvider);

  @override
  Future<bool> insert(String tableName, Map<String, dynamic> data) async {
    final db = await databaseProvider.db();
    return db
        .insert('$tableName', data,
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) {
      if (value == 1) {
        return Future.value(true);
      }
      return Future.value(false);
    });
  }

  @override
  Future<bool> isExist(String userName, String passWord) async {
    final db = await databaseProvider.db();
    bool isUserExist = false;
    return await db
        .query('users',
            columns: ["name", "password"],
            where: "name = ? AND password = ? ",
            whereArgs: [userName, passWord])
        .then((value) {
      if (value.isEmpty) {
        isUserExist = false;
      } else {
        isUserExist = true;
      }

      return Future.value(isUserExist);
    });
  }

  @override
  Future<List<Map<String, dynamic>>> get(
      {int? id, required String userName, required String password}) async {
    final db = await databaseProvider.db();
    return await db.query('users',
        columns: ["id", "name", "password", "dateOfBirth"],
        where: "name = ? AND password = ? ",
        whereArgs: [userName, password]);
  }

  Future<void> writeIntoJson(Map<String, dynamic> content) async {
    documentDirectory = await getApplicationDocumentsDirectory();
    userJsonFile = new File(documentDirectory.path + "/" + "user_details.json");
    if (!userJsonFile.existsSync()) {
      userJsonFile.createSync();
      userJsonFile.writeAsStringSync(json.encode(content));
    } else {
      userJsonFile.writeAsStringSync(json.encode(content));
    }
  }

  Future<void> clearJson(Map<String, dynamic> content) async {
    documentDirectory = await getApplicationDocumentsDirectory();
    userJsonFile = new File(documentDirectory.path + "/" + "user_details.json");
    if (!userJsonFile.existsSync()) {
      userJsonFile.createSync();
      userJsonFile.writeAsStringSync(json.encode(content));
    } else {
      userJsonFile.writeAsStringSync(json.encode(content));
    }
  }

  Future<Map<String, dynamic>> readFormJson() async {
    String response = userJsonFile.readAsStringSync();
    return await json.decode(response);
  }

  void update() {
    notifyListeners();
  }
}
