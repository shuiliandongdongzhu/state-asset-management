import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/inventory_dao.dart';
import '../../database/asset_dao.dart';
import '../../models/inventory_model.dart';
import '../../models/asset_model.dart';
import '../../router/app_router.dart';

class InventoryTaskScreen extends StatefulWidget {
  final String taskId;

  const InventoryTaskScreen({
    Key? key,
    required this.taskId,
  }) : super(key: key);

  @override
  State<InventoryTaskScreen> createState() => _InventoryTaskScreenState();
}

class _InventoryTaskScreenState extends State<InventoryTaskScreen> {
  final InventoryDao _inventoryDao = InventoryDao();
  final AssetDao _assetDao = AssetDao();

  InventoryTaskModel? _task;
  Map<String, int> _statistics = {};
  List<InventoryRecordModel> _records = [];
  bool _isLoading = true;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final task = await _inventoryDao.getTaskById(widget.taskId);
      final stats = await _inventoryDao.getTaskStatistics(widget.taskId);
      final records = await _inventoryDao.getRecordsByTaskId(widget.taskId);

      setState(() {
        _task = task;
        _statistics = stats;
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载失败: $e')),
      );
    }
  }

  Future<void> _updateTaskStatus(int status) async {
    if (_task == null) return;

    try {
      final updated = _task!.copyWith(status: status);
      await _inventoryDao.updateTask(updated);
      _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(status == 2 ? '任务已完成' : '状态已更新')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('更新失败: $e')),
      );
    }
  }

  Future<void> _generateRecords() async {
    // 为所有资产生成盘点记录
    try {
      final assets = await _assetDao.getAllAssets();
      final now = DateTime.now();
      
      final newRecords = assets.map((asset) => InventoryRecordModel(
        id: 'record_${asset.id}_${now.millisecondsSinceEpoch}',
        taskId: widget.taskId,
        assetId: asset.id,
        inventoryStatus: 0,
        createdAt: now,
        updatedAt: now,
      )).toList();

      await _inventoryDao.batchInsertRecords(newRecords);
      _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已生成 ${newRecords.length} 条盘点记录')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('生成失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final total = _statistics['total'] ?? 0;
    final scanned = _statistics['scanned'] ?? 0;
    final progress = total > 0 ? scanned / total : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_task?.taskName ?? '盘点任务'),
        actions: [
          if (_task != null && _task!.status == 1)
            TextButton(
              onPressed: () => _updateTaskStatus(2),
              child: const Text('完成任务', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _task == null
              ? const Center(child: Text('任务不存在'))
              : DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      // 任务信息卡片
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _task!.taskName,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        _task!.taskCode,
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(_task!.status).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _task!.statusText,
                                    style: TextStyle(
                                      color: _getStatusColor(_task!.status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(Icons.date_range, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  '${dateFormat.format(_task!.startDate)} - ${dateFormat.format(_task!.endDate)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // 进度条
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 8,
                                      backgroundColor: Colors.grey[300],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${(progress * 100).toStringAsFixed(1)}%',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem('总数', total.toString(), Colors.blue),
                                _buildStatItem('已盘点', scanned.toString(), Colors.green),
                                _buildStatItem('待盘点', (total - scanned).toString(), Colors.orange),
                                _buildStatItem('盘盈', (_statistics['surplus'] ?? 0).toString(), Colors.purple),
                                _buildStatItem('盘亏', (_statistics['deficit'] ?? 0).toString(), Colors.red),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Tab栏
                      const TabBar(
                        tabs: [
                          Tab(text: '全部记录'),
                          Tab(text: '已盘点'),
                          Tab(text: '未盘点'),
                        ],
                      ),

                      // 操作按钮
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _task!.status == 1
                                    ? () => Navigator.pushNamed(
                                          context,
                                          AppRouter.inventoryScan,
                                          arguments: {'taskId': _task!.id},
                                        ).then((_) => _loadData())
                                    : null,
                                icon: const Icon(Icons.qr_code_scanner),
                                label: const Text('扫码盘点'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _records.isEmpty ? _generateRecords : null,
                                icon: const Icon(Icons.auto_fix_high),
                                label: const Text('生成记录'),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 记录列表
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildRecordList(_records),
                            _buildRecordList(_records.where((r) => r.isScanned).toList()),
                            _buildRecordList(_records.where((r) => !r.isScanned).toList()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordList(List<InventoryRecordModel> records) {
    if (records.isEmpty) {
      return const Center(child: Text('暂无记录'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return FutureBuilder<AssetModel?>(
          future: _assetDao.getAssetById(record.assetId),
          builder: (context, snapshot) {
            final asset = snapshot.data;
            return _buildRecordCard(record, asset);
          },
        );
      },
    );
  }

  Widget _buildRecordCard(InventoryRecordModel record, AssetModel? asset) {
    Color statusColor;
    IconData statusIcon;
    switch (record.inventoryStatus) {
      case 0:
        statusColor = Colors.grey;
        statusIcon = Icons.schedule;
        break;
      case 1:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 2:
        statusColor = Colors.orange;
        statusIcon = Icons.add_circle;
        break;
      case 3:
        statusColor = Colors.red;
        statusIcon = Icons.remove_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor, size: 20),
        ),
        title: Text(asset?.assetName ?? '未知资产'),
        subtitle: Text(asset?.assetCode ?? record.assetId),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            record.statusText,
            style: TextStyle(color: statusColor, fontSize: 12),
          ),
        ),
        onTap: asset != null
            ? () => Navigator.pushNamed(
                  context,
                  AppRouter.assetDetail,
                  arguments: {'assetId': asset.id},
                )
            : null,
      ),
    );
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.grey;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
