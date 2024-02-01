
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'User.dart';

class SqliteDatabaseHelper {

  final String _tableName = "users";
  SqliteDatabaseHelper._privateConstructor();
  static final SqliteDatabaseHelper instance = SqliteDatabaseHelper._privateConstructor();

  Future<Database> getDataBase() async {
    return openDatabase(
      join(await getDatabasesPath(), "usersDatabase.db"),
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE $_tableName (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)",
        );
      },
      version: 1,
    );
  }
  Future<int> insertUser(User user) async {
    int userId = 0;
    Database db = await getDataBase();
    try {
      await db.insert(_tableName, user.toMap(excludeId: true)).then((value) {
        userId = value;
      });
    }catch(e){
       print("Error inserting user: $e");
    }
    return userId;
  }
  Future<List<User>> getAllUsers() async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> usersMaps = await db.query(_tableName);
    return List.generate(usersMaps.length, (index) {
      return User(
          id: usersMaps[index]["id"] ?? 0,
          name: usersMaps[index]["name"] ?? '');
      });
  }

  Future<User> getUser(String userId)async{
    Database db = await getDataBase();
    List<Map<String, dynamic>> user = await db.rawQuery("SELECT * FROM $_tableName WHERE id = $userId");
    if(user.length == 1){
      return User(
        id: user[0]["id"] ?? 0,
        name: user[0]["name"] ?? '',
      );
    } else {
      return User();
    }
  }

  Future<void> updateUser(String userId, String name) async {
    Database db = await getDataBase();
    db.rawUpdate("UPDATE $_tableName SET name = '$name' WHERE id = '$userId'");
  }
  Future<void> deleteUser(int userId) async {
    Database db = await getDataBase();
    await db.rawDelete("DELETE FROM $_tableName WHERE id = '$userId'");
  }
}
