import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/asset_dao.dart';
import '../database/inventory_dao.dart';
import '../models/asset_model.dart';
import '../models/inventory_model.dart';
import '../router/app_router.dart';
import '../widgets/stat_card.dart';
import '../widgets/recent_activity_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AssetDao _assetDao = AssetDao();
  final InventoryDao _inventoryDao = InventoryDao();

  int _totalAssets = 0;
  double _totalValue = 0;
  int _activeTasks = 0;
  Map<String, int> _statusCount = {};
  List<InventoryTaskModel> _recentTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final totalAssets = await _assetDao.getAssetCount();
      final totalValue = await _assetDao.getTotalAssetValue();
      final statusCount = await _assetDao.getAssetCountByStatus();
      final activeTasks = await _inventoryDao.getActiveTasks();
      final allTasks = await _inventoryDao.getAllTasks();

      setState(() {
        _totalAssets = totalAssets;
        _totalValue = totalValue;
        _statusCount = statusCount;
        _activeTasks = activeTasks.length;
        _recentTasks = allTasks.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载数据失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'zh_CN', symbol: '¥');

    return Scaffold(
      appBar: AppBar(
        title: const Text('国有资产管理系统'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // 通知功能
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRouter.settings),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 统计卡片
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: '资产总数',
                            value: _totalAssets.toString(),
                            icon: Icons.inventory_2_outlined,
                            color: Colors.blue,
                            onTap: () => Navigator.pushNamed(context, AppRouter.assetList),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: '资产总值',
                            value: currencyFormat.format(_totalValue),
                            icon: Icons.account_balance_wallet_outlined,
                            color: Colors.green,
                            onTap: () => Navigator.pushNamed(context, AppRouter.reports),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: '进行中盘点',
                            value: _activeTasks.toString(),
                            icon: Icons.fact_check_outlined,
                            color: Colors.orange,
                            onTap: () => Navigator.pushNamed(context, AppRouter.inventoryList),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: '使用中资产',
                            value: (_statusCount['1'] ?? 0).toString(),
                            icon: Icons.check_circle_outline,
                            color: Colors.purple,
                            onTap: () => Navigator.pushNamed(context, AppRouter.assetList),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 快捷操作
                    Text(
                      '快捷操作',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildQuickAction(
                          icon: Icons.add_circle_outline,
                          label: '新增资产',
                          color: Colors.blue,
                          onTap: () => Navigator.pushNamed(context, AppRouter.assetForm),
                        ),
                        _buildQuickAction(
                          icon: Icons.qr_code_scanner,
                          label: '扫码盘点',
                          color: Colors.orange,
                          onTap: () => Navigator.pushNamed(context, AppRouter.inventoryScan),
                        ),
                        _buildQuickAction(
                          icon: Icons.assessment_outlined,
                          label: '报表分析',
                          color: Colors.green,
                          onTap: () => Navigator.pushNamed(context, AppRouter.reports),
                        ),
                        _buildQuickAction(
                          icon: Icons.sync,
                          label: '数据同步',
                          color: Colors.purple,
                          onTap: () => Navigator.pushNamed(context, AppRouter.sync),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 最近盘点任务
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '最近盘点任务',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, AppRouter.inventoryList),
                          child: const Text('查看全部'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_recentTasks.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('暂无盘点任务'),
                        ),
                      )
                    else
                      ..._recentTasks.map((task) => _buildTaskCard(task)),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, AppRouter.assetList);
              break;
            case 2:
              Navigator.pushNamed(context, AppRouter.inventoryList);
              break;
            case 3:
              Navigator.pushNamed(context, AppRouter.settings);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: '资产',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_outlined),
            activeIcon: Icon(Icons.fact_check),
            label: '盘点',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(InventoryTaskModel task) {
    final dateFormat = DateFormat('MM-dd');
    Color statusColor;
    switch (task.status) {
      case 0:
        statusColor = Colors.grey;
        break;
      case 1:
        statusColor = Colors.orange;
        break;
      case 2:
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(Icons.fact_check, color: statusColor),
        ),
        title: Text(task.taskName),
        subtitle: Text('${dateFormat.format(task.startDate)} - ${dateFormat.format(task.endDate)}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            task.statusText,
            style: TextStyle(color: statusColor, fontSize: 12),
          ),
        ),
        onTap: () => Navigator.pushNamed(
          context,
          AppRouter.inventoryTask,
          arguments: {'taskId': task.id},
        ),
      ),
    );
  }
}
