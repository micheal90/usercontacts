import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:usercontacts/models/user_model.dart';

import '../constants.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper db = DatabaseHelper._();
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await iniDb();
    return _database;
  }

  Future<Database> iniDb() async {
    String path = join(await getDatabasesPath(), 'userData.db');
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
          CREATE TABLE $tableUser (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
           $columnName TEXT NOT NULL,
          $columnEmail TEXT NOT NULL,
          $columnPhone TEXT NOT NULL)
          ''');
    });
  }

  ///CURD

  //create
  Future<void> insert(UserModel user) async {
    var dbClient = await database;
    await dbClient.insert(tableUser, user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  //update
  Future<void> update(UserModel user) async {
    //print(user.id);
    var dbClient = await database;
    await dbClient.update(tableUser, user.toJson(),
        where: '$columnId = ?', whereArgs: [user.id]);
  }

  //read user
  Future<UserModel> getUser(int id) async {
    var dbClient = await database;
    List<Map> userData = await dbClient
        .query(tableUser, where: '$columnId = ?', whereArgs: [id]);
    if (userData.length > 0) {
      return UserModel.fromJson(userData.first);
    } else
      return null;
  }

  //read all users
  Future<List<UserModel>> getAllUsers() async {
    var dbClient = await database;
    List<Map> allUsers = await dbClient.query(tableUser);

    return allUsers.isNotEmpty
        ? allUsers.map((user) => UserModel.fromJson(user)).toList()
        : [];
  }

  //delete user
  Future<int> deleteUser(int id) async {
    var dbClient = await database;
    return await dbClient
        .delete(tableUser, where: '$columnId = ?', whereArgs: [id]);
  }
}
