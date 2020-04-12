import 'package:sqflite/sqflite.dart';
import 'package:yeah_passwords/src/helpers/database_helper.dart';
import 'package:yeah_passwords/src/models/user_model.dart';

class UserRepository {
  Future<List<User>> findAll() async {
    final Database db = await DatabaseHelper.instance.database;
    List<Map> users = await db.query("User");

    if (users.length > 0) {
      return users.map((user) => User.fromMap(user)).toList();
    }

    return null;
  }

  Future<User> findById(int id) async {
    final Database db = await DatabaseHelper.instance.database;
    List<Map> users = await db.query(
      "User",
      where: 'id = ?',
      whereArgs: [id],
    );

    if (users.length > 0) {
      return User.fromMap(users.first);
    }

    return null;
  }

  Future<User> findByName(String name) async {
    final Database db = await DatabaseHelper.instance.database;
    List<Map> users = await db.query(
      "User",
      where: 'name = ?',
      whereArgs: [name],
    );

    if (users.length > 0) {
      return User.fromMap(users.first);
    }

    return null;
  }

  Future<void> insert(User user) async {
    final Database db = await DatabaseHelper.instance.database;
    await db.insert(
      "User",
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(User user) async {
    final Database db = await DatabaseHelper.instance.database;
    await db.update(
      "User",
      user.toMap(),
      where: "id = ?",
      whereArgs: [user.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(int id) async {
    final Database db = await DatabaseHelper.instance.database;
    await db.delete(
      "User",
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
