import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  static Future<Database> initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "vault.db");

    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE images (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          path TEXT
        )
      ''');
    });
  }

  static Future<int> insertImage(String path) async {
    final dbClient = await db;
    return await dbClient.insert("images", {"path": path});
  }

  static Future<List<Map<String, dynamic>>> getImages() async {
    final dbClient = await db;
    return await dbClient.query("images");
  }

  static Future<int> deleteImage(String path) async {
    final dbClient = await db;
    return await dbClient.delete("images", where: "path = ?", whereArgs: [path]);
  }
}
