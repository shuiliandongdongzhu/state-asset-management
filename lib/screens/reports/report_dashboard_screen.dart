import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../database/asset_dao.dart';
import '../../database/inventory_dao.dart';

class ReportDashboardScreen extends StatefulWidget {
  const ReportDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ReportDashboardScreen> createState() => _ReportDashboardScreenState();
}

class _ReportDashboardScreenState extends State<ReportDashboardScreen> {
  final AssetDao _assetDao = AssetDao();
  final InventoryDao _inventoryDao = InventoryDao();

  bool _isLoading = true;
  int _totalAssets = 0;
  double _totalValue = 0;
  Map<String, int> _statusCount = {};
  Map<String, int> _categoryCount = {};
  Map<String, int> _departmentCount = {};
  List<Map<String, dynamic>> _recentInventory = [];

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
      
      // 获取所有资产用于分类统计
      final allAssets = await _assetDao.getAllAssets();
      final categoryCount = <String, int>{};
      final departmentCount = <String, int>{};
      
      for (var asset in allAssets) {
        final catName = asset.categoryName ?? '未分类';
        categoryCount[catName] = (categoryCount[catName] ?? 0) + 1;
        
        final deptName = asset.departmentName ?? '未分配';
        departmentCount[deptName] = (departmentCount[deptName] ?? 0) + 1;
      }

      // 获取盘点统计
      final tasks = await _inventoryDao.getAllTasks();
      final recentInventory = tasks.take(5).map((task) async {
        final stats = await _inventoryDao.getTaskStatistics(task.id);
        return {
          'task': task,
          'stats': stats,
        };
      }).toList();

      setState(() {
        _totalAssets = totalAssets;
        _totalValue = totalValue;
        _statusCount = statusCount;
        _categoryCount = categoryCount;
        _departmentCount = departmentCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'zh_CN', symbol: '¥');

    return Scaffold(
      appBar: AppBar(
        title: const Text('报表分析'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReport,
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
                    // 总览卡片
                    Row(
                      children: [
                        Expanded(
                          child: _buildOverviewCard(
                            '资产总数',
                            _totalAssets.toString(),
                            Icons.inventory_2,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildOverviewCard(
                            '资产总值',
                            currencyFormat.format(_totalValue),
                            Icons.account_balance_wallet,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 状态分布
                    _buildChartCard(
                      '资产状态分布',
                      _statusCount.isNotEmpty
                          ? SizedBox(
                              height: 200,
                              child: PieChart(
                                PieChartData(
                                  sections: _buildStatusPieSections(),
                                  centerSpaceRadius: 40,
                                  sectionsSpace: 2,
                                ),
                              ),
                            )
                          : const Center(child: Text('暂无数据')),
                    ),
                    const SizedBox(height: 16),

                    // 分类分布
                    _buildChartCard(
                      '资产分类分布',
                      _categoryCount.isNotEmpty
                          ? SizedBox(
                              height: 200,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: (_categoryCount.values.isNotEmpty
                                          ? _categoryCount.values.reduce((a, b) => a > b ? a : b)
                                          : 0)
                                      .toDouble() *
                                      1.2,
                                  barGroups: _buildCategoryBarGroups(),
                                  titlesData: FlTitlesData(
                                    leftTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final keys = _categoryCount.keys.toList();
                                          if (value.toInt() < keys.length) {
                                            return Text(
                                              keys[value.toInt()],
                                              style: const TextStyle(fontSize: 10),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const Center(child: Text('暂无数据')),
                    ),
                    const SizedBox(height: 16),

                    // 部门分布
                    _buildChartCard(
                      '部门资产分布',
                      _departmentCount.isNotEmpty
                          ? Column(
                              children: _departmentCount.entries.map((entry) {
                                final percent = _totalAssets > 0
                                    ? entry.value / _totalAssets
                                    : 0.0;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(entry.key),
                                          Text('${entry.value} (${(percent * 100).toStringAsFixed(1)}%)'),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      LinearProgressIndicator(
                                        value: percent,
                                        backgroundColor: Colors.grey[200],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            )
                          : const Center(child: Text('暂无数据')),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget child) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildStatusPieSections() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
    ];
    
    final statusNames = {
      '0': '正常',
      '1': '使用中',
      '2': '维修中',
      '3': '已报废',
      '4': '闲置',
    };

    int index = 0;
    return _statusCount.entries.map((entry) {
      final color = colors[index % colors.length];
      index++;
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${statusNames[entry.key] ?? entry.key}\n${entry.value}',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _buildCategoryBarGroups() {
    int index = 0;
    return _categoryCount.entries.map((entry) {
      return BarChartGroupData(
        x: index++,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: Colors.blue,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  void _exportReport() {
    // 导出报表功能
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导出报表'),
        content: const Text('选择导出格式'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('CSV导出功能开发中')),
              );
            },
            child: const Text('CSV'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF导出功能开发中')),
              );
            },
            child: const Text('PDF'),
          ),
        ],
      ),
    );
  }
}
