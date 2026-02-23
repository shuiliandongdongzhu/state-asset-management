import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/asset.dart';

class AssetListScreen extends StatefulWidget {
  const AssetListScreen({super.key});

  @override
  State<AssetListScreen> createState() => _AssetListScreenState();
}

class _AssetListScreenState extends State<AssetListScreen> {
  List<Asset> _assets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    setState(() => _isLoading = true);
    final assets = await DatabaseHelper.instance.getAllAssets();
    setState(() {
      _assets = assets;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('国有资产管理系统'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _assets.isEmpty
              ? const Center(child: Text('暂无资产，点击右下角添加'))
              : ListView.builder(
                  itemCount: _assets.length,
                  itemBuilder: (context, index) {
                    final asset = _assets[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(asset.code.substring(0, 1)),
                      ),
                      title: Text(asset.name),
                      subtitle: Text('${asset.code} | ${asset.category}'),
                      trailing: Text(
                        '¥${asset.value.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      onTap: () => _showAssetDetail(asset),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAssetDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAssetDetail(Asset asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(asset.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('编码: ${asset.code}'),
            Text('分类: ${asset.category}'),
            Text('价值: ¥${asset.value.toStringAsFixed(2)}'),
            Text('状态: ${asset.status}'),
            if (asset.location != null) Text('位置: ${asset.location}'),
            if (asset.department != null) Text('部门: ${asset.department}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseHelper.instance.deleteAsset(asset.id!);
              _loadAssets();
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddAssetDialog() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final categoryController = TextEditingController();
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加资产'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '资产名称'),
              ),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: '资产编码'),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: '分类'),
              ),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(labelText: '价值'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  codeController.text.isNotEmpty) {
                final asset = Asset(
                  name: nameController.text,
                  code: codeController.text,
                  category: categoryController.text.isEmpty
                      ? '未分类'
                      : categoryController.text,
                  value: double.tryParse(valueController.text) ?? 0.0,
                );
                await DatabaseHelper.instance.insertAsset(asset);
                Navigator.pop(context);
                _loadAssets();
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
