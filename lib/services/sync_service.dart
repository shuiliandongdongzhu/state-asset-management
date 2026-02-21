import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/asset_dao.dart';
import '../database/inventory_dao.dart';
import '../models/asset_model.dart';
import '../models/inventory_model.dart';
import '../models/sync_model.dart';
import '../utils/logger.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final AssetDao _assetDao = AssetDao();
  final InventoryDao _inventoryDao = InventoryDao();
  final Connectivity _connectivity = Connectivity();

  SyncConfigModel _config = const SyncConfigModel();
  SyncStatus _status = SyncStatus.idle;
  String? _lastError;

  SyncStatus get status => _status;
  String? get lastError => _lastError;
  SyncConfigModel get config => _config;

  // 初始化同步服务
  Future<void> initialize() async {
    await _loadConfig();
    Logger.i('SyncService initialized');
  }

  // 加载配置
  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final configJson = prefs.getString('sync_config');
    if (configJson != null) {
      _config = SyncConfigModel.fromMap(jsonDecode(configJson));
    }
  }

  // 保存配置
  Future<void> saveConfig(SyncConfigModel config) async {
    _config = config;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sync_config', jsonEncode(config.toMap()));
  }

  // 检查网络连接
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // 执行同步
  Future<SyncResultModel> sync() async {
    if (_status == SyncStatus.syncing) {
      return SyncResultModel.failure('同步正在进行中');
    }

    if (!await checkConnectivity()) {
      _status = SyncStatus.offline;
      return SyncResultModel.failure('网络连接不可用');
    }

    _status = SyncStatus.syncing;
    _lastError = null;

    final stopwatch = Stopwatch()..start();
    
    try {
      int uploadedCount = 0;
      int downloadedCount = 0;

      // 同步资产数据
      final assetResult = await _syncAssets();
      uploadedCount += assetResult.uploadedCount;
      downloadedCount += assetResult.downloadedCount;

      // 同步盘点任务
      final taskResult = await _syncInventoryTasks();
      uploadedCount += taskResult.uploadedCount;
      downloadedCount += taskResult.downloadedCount;

      // 更新最后同步时间
      final newConfig = _config.copyWith(
        lastSyncTime: DateTime.now().toIso8601String(),
      );
      await saveConfig(newConfig);

      _status = SyncStatus.success;
      stopwatch.stop();

      Logger.i('Sync completed: uploaded=$uploadedCount, downloaded=$downloadedCount, duration=${stopwatch.elapsedMilliseconds}ms');

      return SyncResultModel.success(
        uploadedCount: uploadedCount,
        downloadedCount: downloadedCount,
      );
    } catch (e, stackTrace) {
      _status = SyncStatus.failed;
      _lastError = e.toString();
      stopwatch.stop();
      
      Logger.e('Sync failed', e, stackTrace);
      return SyncResultModel.failure(e.toString());
    }
  }

  // 同步资产数据
  Future<SyncResultModel> _syncAssets() async {
    try {
      int uploadedCount = 0;
      int downloadedCount = 0;

      // 获取需要上传的资产
      final assetsToUpload = await _assetDao.getAssetsToSync();
      
      if (assetsToUpload.isNotEmpty && _config.serverUrl.isNotEmpty) {
        // 上传资产数据
        final uploadData = assetsToUpload.map((a) => a.toMap()).toList();
        
        final response = await http.post(
          Uri.parse('${_config.serverUrl}/api/assets/sync'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'assets': uploadData}),
        );

        if (response.statusCode == 200) {
          // 更新同步状态
          for (var asset in assetsToUpload) {
            await _assetDao.updateSyncStatus(asset.id, 1);
          }
          uploadedCount = assetsToUpload.length;
        } else {
          throw Exception('上传失败: ${response.statusCode}');
        }
      }

      // 下载服务器数据（模拟）
      if (_config.serverUrl.isNotEmpty) {
        // 实际项目中这里会从服务器获取更新的数据
        // final response = await http.get(Uri.parse('${_config.serverUrl}/api/assets'));
        // 处理下载的数据...
      }

      return SyncResultModel.success(
        uploadedCount: uploadedCount,
        downloadedCount: downloadedCount,
      );
    } catch (e) {
      Logger.e('Asset sync failed', e);
      return SyncResultModel.failure(e.toString());
    }
  }

  // 同步盘点任务
  Future<SyncResultModel> _syncInventoryTasks() async {
    try {
      int uploadedCount = 0;
      int downloadedCount = 0;

      // 获取所有盘点任务
      final tasks = await _inventoryDao.getAllTasks();
      final tasksToSync = tasks.where((t) => t.syncStatus == 0).toList();

      if (tasksToSync.isNotEmpty && _config.serverUrl.isNotEmpty) {
        // 上传盘点任务
        final uploadData = tasksToSync.map((t) => t.toMap()).toList();
        
        final response = await http.post(
          Uri.parse('${_config.serverUrl}/api/inventory/sync'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'tasks': uploadData}),
        );

        if (response.statusCode == 200) {
          for (var task in tasksToSync) {
            await _inventoryDao.updateTaskSyncStatus(task.id, 1);
          }
          uploadedCount = tasksToSync.length;
        }
      }

      return SyncResultModel.success(
        uploadedCount: uploadedCount,
        downloadedCount: downloadedCount,
      );
    } catch (e) {
      Logger.e('Inventory sync failed', e);
      return SyncResultModel.failure(e.toString());
    }
  }

  // 导出数据为JSON
  Future<String> exportToJson() async {
    final assets = await _assetDao.getAllAssets();
    final tasks = await _inventoryDao.getAllTasks();

    final data = {
      'exportTime': DateTime.now().toIso8601String(),
      'assets': assets.map((a) => a.toMap()).toList(),
      'inventoryTasks': tasks.map((t) => t.toMap()).toList(),
    };

    return jsonEncode(data);
  }

  // 从JSON导入数据
  Future<SyncResultModel> importFromJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // 导入资产
      final assetsData = data['assets'] as List<dynamic>? ?? [];
      final assets = assetsData.map((a) => AssetModel.fromMap(a as Map<String, dynamic>)).toList();
      await _assetDao.batchInsertAssets(assets);

      // 导入盘点任务
      final tasksData = data['inventoryTasks'] as List<dynamic>? ?? [];
      final tasks = tasksData.map((t) => InventoryTaskModel.fromMap(t as Map<String, dynamic>)).toList();
      for (var task in tasks) {
        await _inventoryDao.insertTask(task);
      }

      return SyncResultModel.success(
        uploadedCount: 0,
        downloadedCount: assets.length + tasks.length,
      );
    } catch (e) {
      Logger.e('Import failed', e);
      return SyncResultModel.failure(e.toString());
    }
  }

  // 获取待同步数量
  Future<Map<String, int>> getPendingSyncCount() async {
    final assetsToSync = await _assetDao.getAssetsToSync();
    final tasks = await _inventoryDao.getAllTasks();
    final tasksToSync = tasks.where((t) => t.syncStatus == 0).toList();

    return {
      'assets': assetsToSync.length,
      'tasks': tasksToSync.length,
      'total': assetsToSync.length + tasksToSync.length,
    };
  }

  // 清除同步状态
  Future<void> clearSyncStatus() async {
    final assets = await _assetDao.getAllAssets();
    for (var asset in assets) {
      await _assetDao.updateSyncStatus(asset.id, 0);
    }

    final tasks = await _inventoryDao.getAllTasks();
    for (var task in tasks) {
      await _inventoryDao.updateTaskSyncStatus(task.id, 0);
    }
  }
}
