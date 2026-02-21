import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/asset_dao.dart';
import '../../models/asset_model.dart';
import '../../router/app_router.dart';

class AssetDetailScreen extends StatefulWidget {
  final String assetId;

  const AssetDetailScreen({
    Key? key,
    required this.assetId,
  }) : super(key: key);

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  final AssetDao _assetDao = AssetDao();
  AssetModel? _asset;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAsset();
  }

  Future<void> _loadAsset() async {
    try {
      final asset = await _assetDao.getAssetById(widget.assetId);
      setState(() {
        _asset = asset;
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
    final dateFormat = DateFormat('yyyy-MM-dd');
    final currencyFormat = NumberFormat.currency(locale: 'zh_CN', symbol: '¥');

    return Scaffold(
      appBar: AppBar(
        title: const Text('资产详情'),
        actions: [
          if (_asset != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.pushNamed(
                context,
                AppRouter.assetForm,
                arguments: {'assetId': _asset!.id},
              ).then((_) => _loadAsset()),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _asset == null
              ? const Center(child: Text('资产不存在'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 资产图片
                      Center(
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            image: _asset!.imagePath != null
                                ? DecorationImage(
                                    image: NetworkImage(_asset!.imagePath!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _asset!.imagePath == null
                              ? const Icon(Icons.image, size: 64, color: Colors.grey)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 基本信息
                      _buildSectionTitle('基本信息'),
                      _buildInfoCard([
                        _buildInfoRow('资产名称', _asset!.assetName),
                        _buildInfoRow('资产编码', _asset!.assetCode),
                        _buildInfoRow('资产状态', _asset!.statusText),
                        _buildInfoRow('资产分类', _asset!.categoryName ?? '未分类'),
                      ]),
                      const SizedBox(height: 16),

                      // 位置信息
                      _buildSectionTitle('位置信息'),
                      _buildInfoCard([
                        _buildInfoRow('所属部门', _asset!.departmentName ?? '未分配'),
                        _buildInfoRow('存放位置', _asset!.locationName ?? '未指定'),
                        _buildInfoRow('责任人', _asset!.responsiblePerson ?? '未指定'),
                      ]),
                      const SizedBox(height: 16),

                      // 财务信息
                      _buildSectionTitle('财务信息'),
                      _buildInfoCard([
                        _buildInfoRow(
                          '购买日期',
                          _asset!.purchaseDate != null
                              ? dateFormat.format(_asset!.purchaseDate!)
                              : '未记录',
                        ),
                        _buildInfoRow(
                          '购买价格',
                          _asset!.purchasePrice != null
                              ? currencyFormat.format(_asset!.purchasePrice)
                              : '未记录',
                        ),
                        _buildInfoRow(
                          '当前价值',
                          _asset!.currentValue != null
                              ? currencyFormat.format(_asset!.currentValue)
                              : '未记录',
                        ),
                      ]),
                      const SizedBox(height: 16),

                      // 识别信息
                      _buildSectionTitle('识别信息'),
                      _buildInfoCard([
                        _buildInfoRow('条码', _asset!.barcode ?? '未绑定'),
                        _buildInfoRow('RFID', _asset!.rfid ?? '未绑定'),
                      ]),
                      const SizedBox(height: 16),

                      // 备注
                      if (_asset!.description != null && _asset!.description!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('备注'),
                            _buildInfoCard([
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(_asset!.description!),
                              ),
                            ]),
                          ],
                        ),

                      // 元数据
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          '创建时间: ${dateFormat.format(_asset!.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
