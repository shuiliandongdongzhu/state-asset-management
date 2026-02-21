import 'package:flutter/material.dart';
import '../../database/asset_dao.dart';
import '../../models/asset_model.dart';
import '../../router/app_router.dart';
import '../../widgets/asset_list_item.dart';
import '../../widgets/search_bar.dart';

class AssetListScreen extends StatefulWidget {
  const AssetListScreen({Key? key}) : super(key: key);

  @override
  State<AssetListScreen> createState() => _AssetListScreenState();
}

class _AssetListScreenState extends State<AssetListScreen> {
  final AssetDao _assetDao = AssetDao();
  final ScrollController _scrollController = ScrollController();
  
  List<AssetModel> _assets = [];
  List<AssetModel> _filteredAssets = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedCategory;
  int? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    setState(() => _isLoading = true);
    
    try {
      final assets = await _assetDao.getAllAssets();
      setState(() {
        _assets = assets;
        _filterAssets();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载失败: $e')),
      );
    }
  }

  void _filterAssets() {
    setState(() {
      _filteredAssets = _assets.where((asset) {
        // 搜索过滤
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          final matchesSearch = asset.assetName.toLowerCase().contains(query) ||
              asset.assetCode.toLowerCase().contains(query) ||
              (asset.barcode?.toLowerCase().contains(query) ?? false);
          if (!matchesSearch) return false;
        }

        // 分类过滤
        if (_selectedCategory != null && asset.categoryId != _selectedCategory) {
          return false;
        }

        // 状态过滤
        if (_selectedStatus != null && asset.status != _selectedStatus) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterAssets();
    });
  }

  Future<void> _deleteAsset(AssetModel asset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除资产 "${asset.assetName}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _assetDao.deleteAsset(asset.id);
        _loadAssets();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除成功')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('资产管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: AssetSearchDelegate(_assets),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomSearchBar(
              hintText: '搜索资产名称、编码或条码',
              onChanged: _onSearchChanged,
            ),
          ),

          // 筛选标签
          if (_selectedCategory != null || _selectedStatus != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (_selectedCategory != null)
                    InputChip(
                      label: Text('分类: $_selectedCategory'),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _selectedCategory = null;
                          _filterAssets();
                        });
                      },
                    ),
                  const SizedBox(width: 8),
                  if (_selectedStatus != null)
                    InputChip(
                      label: Text('状态: ${_getStatusText(_selectedStatus!)}'),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _selectedStatus = null;
                          _filterAssets();
                        });
                      },
                    ),
                ],
              ),
            ),

          // 资产列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAssets.isEmpty
                    ? const Center(child: Text('暂无资产数据'))
                    : RefreshIndicator(
                        onRefresh: _loadAssets,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredAssets.length,
                          itemBuilder: (context, index) {
                            final asset = _filteredAssets[index];
                            return AssetListItem(
                              asset: asset,
                              onTap: () => _navigateToDetail(asset),
                              onEdit: () => _navigateToEdit(asset),
                              onDelete: () => _deleteAsset(asset),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRouter.assetForm),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToDetail(AssetModel asset) {
    Navigator.pushNamed(
      context,
      AppRouter.assetDetail,
      arguments: {'assetId': asset.id},
    );
  }

  void _navigateToEdit(AssetModel asset) {
    Navigator.pushNamed(
      context,
      AppRouter.assetForm,
      arguments: {'assetId': asset.id},
    );
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return '正常';
      case 1:
        return '使用中';
      case 2:
        return '维修中';
      case 3:
        return '已报废';
      case 4:
        return '闲置';
      default:
        return '未知';
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '筛选条件',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              '资产状态',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (int i = 0; i <= 4; i++)
                  ChoiceChip(
                    label: Text(_getStatusText(i)),
                    selected: _selectedStatus == i,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = selected ? i : null;
                      });
                      _filterAssets();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('确定'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 搜索委托
class AssetSearchDelegate extends SearchDelegate<AssetModel?> {
  final List<AssetModel> assets;

  AssetSearchDelegate(this.assets);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = assets.where((asset) {
      final q = query.toLowerCase();
      return asset.assetName.toLowerCase().contains(q) ||
          asset.assetCode.toLowerCase().contains(q);
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final asset = results[index];
        return AssetListItem(
          asset: asset,
          onTap: () => close(context, asset),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('输入关键词搜索资产'));
    }

    final suggestions = assets.where((asset) {
      final q = query.toLowerCase();
      return asset.assetName.toLowerCase().contains(q) ||
          asset.assetCode.toLowerCase().contains(q);
    }).take(10).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final asset = suggestions[index];
        return ListTile(
          title: Text(asset.assetName),
          subtitle: Text(asset.assetCode),
          onTap: () => close(context, asset),
        );
      },
    );
  }
}
