import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/asset_model.dart';

class AssetDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // 插入资产
  Future<String> insertAsset(AssetModel asset) async {
    final db = await _dbHelper.database;
    await db.insert('assets', asset.toMap());
    return asset.id;
  }

  // 更新资产
  Future<int> updateAsset(AssetModel asset) async {
    final db = await _dbHelper.database;
    return await db.update(
      'assets',
      asset.toMap(),
      where: 'id = ?',
      whereArgs: [asset.id],
    );
  }

  // 删除资产
  Future<int> deleteAsset(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'assets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 根据ID获取资产
  Future<AssetModel?> getAssetById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assets',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return AssetModel.fromMap(maps.first);
    }
    return null;
  }

  // 根据资产编码获取资产
  Future<AssetModel?> getAssetByCode(String assetCode) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assets',
      where: 'asset_code = ?',
      whereArgs: [assetCode],
    );

    if (maps.isNotEmpty) {
      return AssetModel.fromMap(maps.first);
    }
    return null;
  }

  // 根据条码获取资产
  Future<AssetModel?> getAssetByBarcode(String barcode) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assets',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );

    if (maps.isNotEmpty) {
      return AssetModel.fromMap(maps.first);
    }
    return null;
  }

  // 获取所有资产
  Future<List<AssetModel>> getAllAssets() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assets',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => AssetModel.fromMap(maps[i]));
  }

  // 分页获取资产
  Future<List<AssetModel>> getAssetsByPage(int page, int pageSize) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assets',
      orderBy: 'created_at DESC',
      limit: pageSize,
      offset: page * pageSize,
    );
    return List.generate(maps.length, (i) => AssetModel.fromMap(maps[i]));
  }

  // 根据条件筛选资产
  Future<List<AssetModel>> getAssetsByFilter({
    String? categoryId,
    String? departmentId,
    String? locationId,
    int? status,
    String? keyword,
  }) async {
    final db = await _dbHelper.database;
    
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (categoryId != null) {
      whereClause += ' AND category_id = ?';
      whereArgs.add(categoryId);
    }
    if (departmentId != null) {
      whereClause += ' AND department_id = ?';
      whereArgs.add(departmentId);
    }
    if (locationId != null) {
      whereClause += ' AND location_id = ?';
      whereArgs.add(locationId);
    }
    if (status != null) {
      whereClause += ' AND status = ?';
      whereArgs.add(status);
    }
    if (keyword != null && keyword.isNotEmpty) {
      whereClause += ' AND (asset_name LIKE ? OR asset_code LIKE ? OR barcode LIKE ?)';
      whereArgs.add('%$keyword%');
      whereArgs.add('%$keyword%');
      whereArgs.add('%$keyword%');
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'assets',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => AssetModel.fromMap(maps[i]));
  }

  // 获取资产总数
  Future<int> getAssetCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM assets');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 获取各状态资产数量
  Future<Map<String, int>> getAssetCountByStatus() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT status, COUNT(*) as count 
      FROM assets 
      GROUP BY status
    ''');
    
    Map<String, int> statusCount = {};
    for (var row in result) {
      statusCount[row['status'].toString()] = row['count'] as int;
    }
    return statusCount;
  }

  // 获取资产总价值
  Future<double> getTotalAssetValue() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(current_value) as total 
      FROM assets
    ''');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // 获取需要同步的资产
  Future<List<AssetModel>> getAssetsToSync() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assets',
      where: 'sync_status = ?',
      whereArgs: [0],
      orderBy: 'created_at ASC',
    );
    return List.generate(maps.length, (i) => AssetModel.fromMap(maps[i]));
  }

  // 更新同步状态
  Future<void> updateSyncStatus(String id, int status) async {
    final db = await _dbHelper.database;
    await db.update(
      'assets',
      {
        'sync_status': status,
        'sync_time': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 批量插入资产
  Future<void> batchInsertAssets(List<AssetModel> assets) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      for (var asset in assets) {
        await txn.insert('assets', asset.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  // 搜索资产
  Future<List<AssetModel>> searchAssets(String query) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assets',
      where: 'asset_name LIKE ? OR asset_code LIKE ? OR barcode LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
      orderBy: 'asset_name ASC',
    );
    return List.generate(maps.length, (i) => AssetModel.fromMap(maps[i]));
  }
}
