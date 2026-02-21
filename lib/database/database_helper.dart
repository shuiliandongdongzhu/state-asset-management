import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'state_asset.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 资产表
    await db.execute('''
      CREATE TABLE assets (
        id TEXT PRIMARY KEY,
        asset_code TEXT NOT NULL UNIQUE,
        asset_name TEXT NOT NULL,
        category_id TEXT,
        category_name TEXT,
        department_id TEXT,
        department_name TEXT,
        location_id TEXT,
        location_name TEXT,
        purchase_date INTEGER,
        purchase_price REAL,
        current_value REAL,
        status INTEGER DEFAULT 0,
        responsible_person TEXT,
        description TEXT,
        image_path TEXT,
        barcode TEXT,
        rfid TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        sync_status INTEGER DEFAULT 0,
        sync_time INTEGER
      )
    ''');

    // 资产分类表
    await db.execute('''
      CREATE TABLE asset_categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        parent_id TEXT,
        description TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 部门表
    await db.execute('''
      CREATE TABLE departments (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        parent_id TEXT,
        manager TEXT,
        description TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 位置表
    await db.execute('''
      CREATE TABLE locations (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        parent_id TEXT,
        description TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 盘点任务表
    await db.execute('''
      CREATE TABLE inventory_tasks (
        id TEXT PRIMARY KEY,
        task_name TEXT NOT NULL,
        task_code TEXT NOT NULL UNIQUE,
        start_date INTEGER NOT NULL,
        end_date INTEGER NOT NULL,
        status INTEGER DEFAULT 0,
        department_id TEXT,
        location_id TEXT,
        description TEXT,
        created_by TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        sync_status INTEGER DEFAULT 0,
        sync_time INTEGER
      )
    ''');

    // 盘点记录表
    await db.execute('''
      CREATE TABLE inventory_records (
        id TEXT PRIMARY KEY,
        task_id TEXT NOT NULL,
        asset_id TEXT NOT NULL,
        inventory_status INTEGER DEFAULT 0,
        scan_time INTEGER,
        scan_location TEXT,
        scan_user TEXT,
        notes TEXT,
        image_path TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (task_id) REFERENCES inventory_tasks (id),
        FOREIGN KEY (asset_id) REFERENCES assets (id)
      )
    ''');

    // 操作日志表
    await db.execute('''
      CREATE TABLE operation_logs (
        id TEXT PRIMARY KEY,
        operation_type TEXT NOT NULL,
        table_name TEXT,
        record_id TEXT,
        old_values TEXT,
        new_values TEXT,
        operator TEXT,
        operation_time INTEGER NOT NULL,
        device_info TEXT
      )
    ''');

    // 插入默认数据
    await _insertDefaultData(db);
  }

  Future<void> _insertDefaultData(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // 默认分类
    await db.insert('asset_categories', {
      'id': 'cat_001',
      'name': '电子设备',
      'code': 'ELEC',
      'description': '电脑、打印机等电子设备',
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('asset_categories', {
      'id': 'cat_002',
      'name': '办公家具',
      'code': 'FURN',
      'description': '桌椅、柜子等家具',
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('asset_categories', {
      'id': 'cat_003',
      'name': '交通工具',
      'code': 'VEHI',
      'description': '车辆等交通工具',
      'created_at': now,
      'updated_at': now,
    });

    // 默认部门
    await db.insert('departments', {
      'id': 'dept_001',
      'name': '总经办',
      'code': 'GM',
      'description': '总经理办公室',
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('departments', {
      'id': 'dept_002',
      'name': '财务部',
      'code': 'FIN',
      'description': '财务部门',
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('departments', {
      'id': 'dept_003',
      'name': '技术部',
      'code': 'TECH',
      'description': '技术研发部门',
      'created_at': now,
      'updated_at': now,
    });

    // 默认位置
    await db.insert('locations', {
      'id': 'loc_001',
      'name': '一楼办公室',
      'code': 'F1',
      'description': '一楼办公区域',
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('locations', {
      'id': 'loc_002',
      'name': '二楼办公室',
      'code': 'F2',
      'description': '二楼办公区域',
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('locations', {
      'id': 'loc_003',
      'name': '仓库',
      'code': 'WH',
      'description': '存储仓库',
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 数据库升级逻辑
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  Future<void> deleteDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'state_asset.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
