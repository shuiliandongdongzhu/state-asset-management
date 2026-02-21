import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/inventory_model.dart';

class InventoryDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ========== 盘点任务操作 ==========

  // 插入盘点任务
  Future<String> insertTask(InventoryTaskModel task) async {
    final db = await _dbHelper.database;
    await db.insert('inventory_tasks', task.toMap());
    return task.id;
  }

  // 更新盘点任务
  Future<int> updateTask(InventoryTaskModel task) async {
    final db = await _dbHelper.database;
    return await db.update(
      'inventory_tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // 删除盘点任务
  Future<int> deleteTask(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'inventory_tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 根据ID获取盘点任务
  Future<InventoryTaskModel?> getTaskById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'inventory_tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return InventoryTaskModel.fromMap(maps.first);
    }
    return null;
  }

  // 获取所有盘点任务
  Future<List<InventoryTaskModel>> getAllTasks() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'inventory_tasks',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => InventoryTaskModel.fromMap(maps[i]));
  }

  // 获取进行中的盘点任务
  Future<List<InventoryTaskModel>> getActiveTasks() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'inventory_tasks',
      where: 'status = ?',
      whereArgs: [1], // 1 = 进行中
      orderBy: 'end_date ASC',
    );
    return List.generate(maps.length, (i) => InventoryTaskModel.fromMap(maps[i]));
  }

  // 获取任务统计
  Future<Map<String, int>> getTaskStatistics(String taskId) async {
    final db = await _dbHelper.database;
    
    // 总记录数
    final totalResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM inventory_records WHERE task_id = ?
    ''', [taskId]);
    final total = Sqflite.firstIntValue(totalResult) ?? 0;

    // 已盘点数
    final scannedResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM inventory_records 
      WHERE task_id = ? AND inventory_status = ?
    ''', [taskId, 1]);
    final scanned = Sqflite.firstIntValue(scannedResult) ?? 0;

    // 盘盈数
    final surplusResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM inventory_records 
      WHERE task_id = ? AND inventory_status = ?
    ''', [taskId, 2]);
    final surplus = Sqflite.firstIntValue(surplusResult) ?? 0;

    // 盘亏数
    final deficitResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM inventory_records 
      WHERE task_id = ? AND inventory_status = ?
    ''', [taskId, 3]);
    final deficit = Sqflite.firstIntValue(deficitResult) ?? 0;

    return {
      'total': total,
      'scanned': scanned,
      'surplus': surplus,
      'deficit': deficit,
      'pending': total - scanned,
    };
  }

  // ========== 盘点记录操作 ==========

  // 插入盘点记录
  Future<String> insertRecord(InventoryRecordModel record) async {
    final db = await _dbHelper.database;
    await db.insert('inventory_records', record.toMap());
    return record.id;
  }

  // 更新盘点记录
  Future<int> updateRecord(InventoryRecordModel record) async {
    final db = await _dbHelper.database;
    return await db.update(
      'inventory_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // 根据ID获取盘点记录
  Future<InventoryRecordModel?> getRecordById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'inventory_records',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return InventoryRecordModel.fromMap(maps.first);
    }
    return null;
  }

  // 根据任务ID获取盘点记录
  Future<List<InventoryRecordModel>> getRecordsByTaskId(String taskId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'inventory_records',
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'scan_time DESC',
    );
    return List.generate(maps.length, (i) => InventoryRecordModel.fromMap(maps[i]));
  }

  // 根据资产ID和任务ID获取盘点记录
  Future<InventoryRecordModel?> getRecordByAssetAndTask(String assetId, String taskId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'inventory_records',
      where: 'asset_id = ? AND task_id = ?',
      whereArgs: [assetId, taskId],
    );

    if (maps.isNotEmpty) {
      return InventoryRecordModel.fromMap(maps.first);
    }
    return null;
  }

  // 根据条码获取盘点记录
  Future<InventoryRecordModel?> getRecordByBarcode(String barcode, String taskId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT r.* FROM inventory_records r
      INNER JOIN assets a ON r.asset_id = a.id
      WHERE a.barcode = ? AND r.task_id = ?
    ''', [barcode, taskId]);

    if (maps.isNotEmpty) {
      return InventoryRecordModel.fromMap(maps.first);
    }
    return null;
  }

  // 获取任务的待盘点记录
  Future<List<InventoryRecordModel>> getPendingRecords(String taskId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'inventory_records',
      where: 'task_id = ? AND inventory_status = ?',
      whereArgs: [taskId, 0], // 0 = 未盘点
      orderBy: 'created_at ASC',
    );
    return List.generate(maps.length, (i) => InventoryRecordModel.fromMap(maps[i]));
  }

  // 获取任务的已盘点记录
  Future<List<InventoryRecordModel>> getScannedRecords(String taskId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'inventory_records',
      where: 'task_id = ? AND inventory_status != ?',
      whereArgs: [taskId, 0],
      orderBy: 'scan_time DESC',
    );
    return List.generate(maps.length, (i) => InventoryRecordModel.fromMap(maps[i]));
  }

  // 批量插入盘点记录
  Future<void> batchInsertRecords(List<InventoryRecordModel> records) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      for (var record in records) {
        await txn.insert('inventory_records', record.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  // 删除任务的盘点记录
  Future<int> deleteRecordsByTaskId(String taskId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'inventory_records',
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
  }

  // 更新同步状态
  Future<void> updateTaskSyncStatus(String id, int status) async {
    final db = await _dbHelper.database;
    await db.update(
      'inventory_tasks',
      {
        'sync_status': status,
        'sync_time': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
