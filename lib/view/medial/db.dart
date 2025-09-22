import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? db;

  static Future<Database> getDb() async {
    if (db != null) return db!;
    db = await initDb();
    return db!;
  }

  static Future<Database> initDb() async {
    final path = join(await getDatabasesPath(), 'locker.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE locked_files(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          fileName TEXT,
          originalPath TEXT,
          lockedPath TEXT,
          status TEXT
        )
      ''');
    });
  }

  static Future<int> insertFile(Map<String, dynamic> row) async {
    final db = await getDb();
    return await db.insert('locked_files', row);
  }

  static Future<int> updateFile(int id, Map<String, dynamic> row) async {
    final db = await getDb();
    return await db.update('locked_files', row, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> getAllFiles() async {
    final db = await getDb();
    return await db.query('locked_files');
  }
}
