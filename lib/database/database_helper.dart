import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/asset.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('state_asset.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE assets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        category TEXT NOT NULL,
        value REAL NOT NULL,
        status TEXT NOT NULL DEFAULT '正常',
        location TEXT,
        department TEXT,
        purchase_date INTEGER,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  // CRUD 操作
  Future<int> insertAsset(Asset asset) async {
    final db = await database;
    return await db.insert('assets', asset.toMap());
  }

  Future<List<Asset>> getAllAssets() async {
    final db = await database;
    final maps = await db.query('assets', orderBy: 'created_at DESC');
    return maps.map((map) => Asset.fromMap(map)).toList();
  }

  Future<int> updateAsset(Asset asset) async {
    final db = await database;
    return await db.update(
      'assets',
      asset.toMap(),
      where: 'id = ?',
      whereArgs: [asset.id],
    );
  }

  Future<int> deleteAsset(int id) async {
    final db = await database;
    return await db.delete(
      'assets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
