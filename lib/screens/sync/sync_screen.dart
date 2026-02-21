import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/sync_service.dart';
import '../../models/sync_model.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({Key? key}) : super(key: key);

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  final SyncService _syncService = SyncService();
  final _urlController = TextEditingController();
  final _intervalController = TextEditingController();

  bool _autoSync = true;
  bool _syncOnWifiOnly = false;
  bool _isSyncing = false;
  SyncResultModel? _lastResult;
  Map<String, int> _pendingCount = {};

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _syncService.initialize();
    _loadConfig();
    _loadPendingCount();
  }

  void _loadConfig() {
    final config = _syncService.config;
    setState(() {
      _urlController.text = config.serverUrl;
      _intervalController.text = config.syncInterval.toString();
      _autoSync = config.autoSync;
      _syncOnWifiOnly = config.syncOnWifiOnly;
    });
  }

  Future<void> _loadPendingCount() async {
    final count = await _syncService.getPendingSyncCount();
    setState(() => _pendingCount = count);
  }

  Future<void> _saveConfig() async {
    final config = SyncConfigModel(
      serverUrl: _urlController.text.trim(),
      syncInterval: int.tryParse(_intervalController.text) ?? 30,
      autoSync: _autoSync,
      syncOnWifiOnly: _syncOnWifiOnly,
      lastSyncTime: _syncService.config.lastSyncTime,
    );
    await _syncService.saveConfig(config);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('配置已保存')),
      );
    }
  }

  Future<void> _performSync() async {
    setState(() => _isSyncing = true);

    final result = await _syncService.sync();

    setState(() {
      _isSyncing = false;
      _lastResult = result;
    });

    await _loadPendingCount();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.success ? '同步成功' : '同步失败: ${result.errorMessage}'),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _testConnection() async {
    final hasConnection = await _syncService.checkConnectivity();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(hasConnection ? '网络连接正常' : '网络连接不可用'),
          backgroundColor: hasConnection ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据同步'),
        actions: [
          TextButton(
            onPressed: _saveConfig,
            child: const Text('保存', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 同步状态卡片
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    _getStatusIcon(),
                    size: 48,
                    color: _getStatusColor(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getStatusText(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (_syncService.config.lastSyncTime != null)
                    Text(
                      '上次同步: ${_syncService.config.lastSyncTime}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 待同步数据
            Text(
              '待同步数据',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPendingCard(
                    '资产',
                    (_pendingCount['assets'] ?? 0).toString(),
                    Icons.inventory_2,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPendingCard(
                    '盘点任务',
                    (_pendingCount['tasks'] ?? 0).toString(),
                    Icons.fact_check,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 服务器配置
            Text(
              '服务器配置',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: '服务器地址',
                hintText: 'https://api.example.com',
                prefixIcon: const Icon(Icons.link),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.network_check),
                  onPressed: _testConnection,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _intervalController,
              decoration: const InputDecoration(
                labelText: '同步间隔（分钟）',
                prefixIcon: Icon(Icons.timer),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 24),

            // 同步选项
            Text(
              '同步选项',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('自动同步'),
              subtitle: const Text('按设定间隔自动同步数据'),
              value: _autoSync,
              onChanged: (value) => setState(() => _autoSync = value),
            ),
            SwitchListTile(
              title: const Text('仅WiFi同步'),
              subtitle: const Text('仅在WiFi连接时同步'),
              value: _syncOnWifiOnly,
              onChanged: (value) => setState(() => _syncOnWifiOnly = value),
            ),
            const SizedBox(height: 24),

            // 同步按钮
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isSyncing ? null : _performSync,
                icon: _isSyncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.sync),
                label: Text(_isSyncing ? '同步中...' : '立即同步'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _showExportDialog(),
                icon: const Icon(Icons.download),
                label: const Text('导出数据'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _showImportDialog(),
                icon: const Icon(Icons.upload),
                label: const Text('导入数据'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (_syncService.status) {
      case SyncStatus.syncing:
        return Colors.orange;
      case SyncStatus.success:
        return Colors.green;
      case SyncStatus.failed:
        return Colors.red;
      case SyncStatus.offline:
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon() {
    switch (_syncService.status) {
      case SyncStatus.syncing:
        return Icons.sync;
      case SyncStatus.success:
        return Icons.check_circle;
      case SyncStatus.failed:
        return Icons.error;
      case SyncStatus.offline:
        return Icons.cloud_off;
      default:
        return Icons.cloud_queue;
    }
  }

  String _getStatusText() {
    switch (_syncService.status) {
      case SyncStatus.syncing:
        return '同步中...';
      case SyncStatus.success:
        return '同步成功';
      case SyncStatus.failed:
        return '同步失败';
      case SyncStatus.offline:
        return '离线模式';
      default:
        return '准备就绪';
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导出数据'),
        content: const Text('确定要导出所有数据吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final json = await _syncService.exportToJson();
              // 保存或分享JSON
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('数据已导出')),
              );
            },
            child: const Text('导出'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导入数据'),
        content: const Text('导入数据将覆盖现有数据，确定要继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 选择文件并导入
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('请选择导入文件')),
              );
            },
            child: const Text('导入'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _intervalController.dispose();
    super.dispose();
  }
}
