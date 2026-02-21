import 'package:flutter/material.dart';
import '../../database/inventory_dao.dart';
import '../../database/asset_dao.dart';
import '../../models/inventory_model.dart';
import '../../models/asset_model.dart';

class InventoryScanScreen extends StatefulWidget {
  final String? taskId;

  const InventoryScanScreen({
    Key? key,
    this.taskId,
  }) : super(key: key);

  @override
  State<InventoryScanScreen> createState() => _InventoryScanScreenState();
}

class _InventoryScanScreenState extends State<InventoryScanScreen> {
  final InventoryDao _inventoryDao = InventoryDao();
  final AssetDao _assetDao = AssetDao();

  List<InventoryTaskModel> _tasks = [];
  InventoryTaskModel? _selectedTask;
  bool _isLoading = false;
  bool _isScanning = false;

  final TextEditingController _barcodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await _inventoryDao.getActiveTasks();
      setState(() {
        _tasks = tasks;
        if (widget.taskId != null) {
          _selectedTask = tasks.firstWhere(
            (t) => t.id == widget.taskId,
            orElse: () => tasks.isNotEmpty ? tasks.first : null!,
          );
        } else if (tasks.isNotEmpty) {
          _selectedTask = tasks.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processBarcode(String barcode) async {
    if (_selectedTask == null || barcode.isEmpty) return;

    setState(() => _isScanning = true);

    try {
      // 查找资产
      final asset = await _assetDao.getAssetByBarcode(barcode);
      
      if (asset == null) {
        // 资产不存在 - 盘盈
        _showResultDialog(
          title: '盘盈资产',
          message: '条码 $barcode 未在系统中找到',
          isSuccess: false,
          isSurplus: true,
        );
      } else {
        // 检查是否已有盘点记录
        final existingRecord = await _inventoryDao.getRecordByAssetAndTask(
          asset.id,
          _selectedTask!.id,
        );

        if (existingRecord != null) {
          if (existingRecord.isScanned) {
            // 已盘点过
            _showResultDialog(
              title: '重复扫描',
              message: '资产 ${asset.assetName} 已盘点',
              asset: asset,
              isSuccess: true,
            );
          } else {
            // 更新为已盘点
            await _updateRecord(existingRecord, asset);
            _showResultDialog(
              title: '盘点成功',
              message: '资产 ${asset.assetName} 盘点完成',
              asset: asset,
              isSuccess: true,
            );
          }
        } else {
          // 创建新盘点记录
          await _createRecord(asset);
          _showResultDialog(
            title: '盘点成功',
            message: '资产 ${asset.assetName} 盘点完成',
            asset: asset,
            isSuccess: true,
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('盘点失败: $e')),
      );
    } finally {
      setState(() => _isScanning = false);
      _barcodeController.clear();
    }
  }

  Future<void> _createRecord(AssetModel asset) async {
    final now = DateTime.now();
    final record = InventoryRecordModel(
      id: 'record_${now.millisecondsSinceEpoch}',
      taskId: _selectedTask!.id,
      assetId: asset.id,
      inventoryStatus: 1, // 已盘点
      scanTime: now,
      scanLocation: asset.locationName,
      createdAt: now,
      updatedAt: now,
    );
    await _inventoryDao.insertRecord(record);
  }

  Future<void> _updateRecord(InventoryRecordModel record, AssetModel asset) async {
    final updated = record.copyWith(
      inventoryStatus: 1,
      scanTime: DateTime.now(),
      scanLocation: asset.locationName,
      updatedAt: DateTime.now(),
    );
    await _inventoryDao.updateRecord(updated);
  }

  void _showResultDialog({
    required String title,
    required String message,
    AssetModel? asset,
    required bool isSuccess,
    bool isSurplus = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          isSurplus
              ? Icons.add_circle_outline
              : isSuccess
                  ? Icons.check_circle
                  : Icons.warning,
          color: isSurplus
              ? Colors.orange
              : isSuccess
                  ? Colors.green
                  : Colors.red,
          size: 48,
        ),
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            if (asset != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('资产编码', asset.assetCode),
                    _buildInfoRow('存放位置', asset.locationName ?? '未指定'),
                    _buildInfoRow('责任人', asset.responsiblePerson ?? '未指定'),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (isSurplus) {
                // 处理盘盈资产
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('扫码盘点'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 任务选择
                  if (_tasks.isNotEmpty)
                    DropdownButtonFormField<InventoryTaskModel>(
                      value: _selectedTask,
                      decoration: const InputDecoration(
                        labelText: '选择盘点任务',
                        prefixIcon: Icon(Icons.assignment_outlined),
                      ),
                      items: _tasks.map((task) {
                        return DropdownMenuItem(
                          value: task,
                          child: Text(task.taskName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedTask = value);
                      },
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text('没有进行中的盘点任务，请先创建任务'),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // 扫码输入
                  TextField(
                    controller: _barcodeController,
                    decoration: InputDecoration(
                      labelText: '输入或扫描条码',
                      hintText: '请扫描资产条码',
                      prefixIcon: const Icon(Icons.qr_code),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () => _processBarcode(_barcodeController.text),
                      ),
                    ),
                    onSubmitted: _processBarcode,
                    enabled: _selectedTask != null && !_isScanning,
                  ),
                  const SizedBox(height: 24),

                  // 扫描按钮
                  SizedBox(
                    width: double.infinity,
                    height: 120,
                    child: ElevatedButton.icon(
                      onPressed: _selectedTask == null || _isScanning
                          ? null
                          : () {
                              // 打开相机扫码
                              _simulateScan();
                            },
                      icon: _isScanning
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.qr_code_scanner, size: 48),
                      label: Text(
                        _isScanning ? '处理中...' : '点击扫码',
                        style: const TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 提示信息
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '使用说明',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('1. 选择要进行盘点的任务'),
                        Text('2. 点击扫码按钮扫描资产条码'),
                        Text('3. 或在输入框中手动输入条码'),
                        Text('4. 系统自动匹配资产并记录盘点结果'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // 模拟扫码（实际项目中使用相机扫码）
  void _simulateScan() {
    // 模拟扫码结果
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('模拟扫码'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '输入条码',
            hintText: '请输入资产条码',
          ),
          onSubmitted: (value) {
            Navigator.pop(context);
            _processBarcode(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processBarcode(_barcodeController.text);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }
}
