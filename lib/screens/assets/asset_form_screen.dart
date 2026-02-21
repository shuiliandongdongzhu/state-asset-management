import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../database/asset_dao.dart';
import '../../database/database_helper.dart';
import '../../models/asset_model.dart';
import '../../router/app_router.dart';
import '../../utils/logger.dart';

class AssetFormScreen extends StatefulWidget {
  final String? assetId;

  const AssetFormScreen({
    Key? key,
    this.assetId,
  }) : super(key: key);

  @override
  State<AssetFormScreen> createState() => _AssetFormScreenState();
}

class _AssetFormScreenState extends State<AssetFormScreen> {
  final AssetDao _assetDao = AssetDao();
  final _formKey = GlobalKey<FormState>();
  final _dbHelper = DatabaseHelper();

  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _priceController = TextEditingController();
  final _valueController = TextEditingController();
  final _personController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _rfidController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String? _selectedDepartmentId;
  String? _selectedDepartmentName;
  String? _selectedLocationId;
  String? _selectedLocationName;
  DateTime? _purchaseDate;
  int _status = 0;

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _locations = [];

  bool _isLoading = false;
  bool _isSaving = false;
  AssetModel? _existingAsset;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
    if (widget.assetId != null) {
      _loadAsset();
    }
  }

  Future<void> _loadDropdownData() async {
    try {
      final db = await _dbHelper.database;
      final categories = await db.query('asset_categories');
      final departments = await db.query('departments');
      final locations = await db.query('locations');

      setState(() {
        _categories = categories;
        _departments = departments;
        _locations = locations;
      });
    } catch (e) {
      Logger.e('Failed to load dropdown data', e);
    }
  }

  Future<void> _loadAsset() async {
    setState(() => _isLoading = true);
    
    try {
      final asset = await _assetDao.getAssetById(widget.assetId!);
      if (asset != null) {
        _existingAsset = asset;
        _nameController.text = asset.assetName;
        _codeController.text = asset.assetCode;
        _priceController.text = asset.purchasePrice?.toString() ?? '';
        _valueController.text = asset.currentValue?.toString() ?? '';
        _personController.text = asset.responsiblePerson ?? '';
        _barcodeController.text = asset.barcode ?? '';
        _rfidController.text = asset.rfid ?? '';
        _descriptionController.text = asset.description ?? '';
        _selectedCategoryId = asset.categoryId;
        _selectedCategoryName = asset.categoryName;
        _selectedDepartmentId = asset.departmentId;
        _selectedDepartmentName = asset.departmentName;
        _selectedLocationId = asset.locationId;
        _selectedLocationName = asset.locationName;
        _purchaseDate = asset.purchaseDate;
        _status = asset.status;
      }
    } catch (e) {
      Logger.e('Failed to load asset', e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAsset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final asset = AssetModel(
        id: _existingAsset?.id ?? 'asset_${now.millisecondsSinceEpoch}',
        assetCode: _codeController.text.trim(),
        assetName: _nameController.text.trim(),
        categoryId: _selectedCategoryId,
        categoryName: _selectedCategoryName,
        departmentId: _selectedDepartmentId,
        departmentName: _selectedDepartmentName,
        locationId: _selectedLocationId,
        locationName: _selectedLocationName,
        purchaseDate: _purchaseDate,
        purchasePrice: _priceController.text.isNotEmpty
            ? double.tryParse(_priceController.text)
            : null,
        currentValue: _valueController.text.isNotEmpty
            ? double.tryParse(_valueController.text)
            : null,
        status: _status,
        responsiblePerson: _personController.text.isNotEmpty
            ? _personController.text.trim()
            : null,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        barcode: _barcodeController.text.isNotEmpty
            ? _barcodeController.text.trim()
            : null,
        rfid: _rfidController.text.isNotEmpty
            ? _rfidController.text.trim()
            : null,
        createdAt: _existingAsset?.createdAt ?? now,
        updatedAt: now,
        syncStatus: 0,
      );

      if (_existingAsset != null) {
        await _assetDao.updateAsset(asset);
      } else {
        await _assetDao.insertAsset(asset);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存成功')),
        );
      }
    } catch (e) {
      Logger.e('Failed to save asset', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _purchaseDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(
        title: Text(_existingAsset != null ? '编辑资产' : '新增资产'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 基本信息
                    _buildSectionTitle('基本信息'),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '资产名称 *',
                        prefixIcon: Icon(Icons.label_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入资产名称';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: '资产编码 *',
                        prefixIcon: Icon(Icons.qr_code),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入资产编码';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 分类选择
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: '资产分类',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat['id'] as String,
                          child: Text(cat['name'] as String),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                          _selectedCategoryName = _categories
                              .firstWhere((c) => c['id'] == value)['name'] as String?;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // 状态选择
                    DropdownButtonFormField<int>(
                      value: _status,
                      decoration: const InputDecoration(
                        labelText: '资产状态',
                        prefixIcon: Icon(Icons.info_outline),
                      ),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('正常')),
                        DropdownMenuItem(value: 1, child: Text('使用中')),
                        DropdownMenuItem(value: 2, child: Text('维修中')),
                        DropdownMenuItem(value: 3, child: Text('已报废')),
                        DropdownMenuItem(value: 4, child: Text('闲置')),
                      ],
                      onChanged: (value) {
                        setState(() => _status = value ?? 0);
                      },
                    ),
                    const SizedBox(height: 24),

                    // 位置信息
                    _buildSectionTitle('位置信息'),
                    DropdownButtonFormField<String>(
                      value: _selectedDepartmentId,
                      decoration: const InputDecoration(
                        labelText: '所属部门',
                        prefixIcon: Icon(Icons.business_outlined),
                      ),
                      items: _departments.map((dept) {
                        return DropdownMenuItem(
                          value: dept['id'] as String,
                          child: Text(dept['name'] as String),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartmentId = value;
                          _selectedDepartmentName = _departments
                              .firstWhere((d) => d['id'] == value)['name'] as String?;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedLocationId,
                      decoration: const InputDecoration(
                        labelText: '存放位置',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      items: _locations.map((loc) {
                        return DropdownMenuItem(
                          value: loc['id'] as String,
                          child: Text(loc['name'] as String),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLocationId = value;
                          _selectedLocationName = _locations
                              .firstWhere((l) => l['id'] == value)['name'] as String?;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _personController,
                      decoration: const InputDecoration(
                        labelText: '责任人',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 财务信息
                    _buildSectionTitle('财务信息'),
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '购买日期',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _purchaseDate != null
                              ? dateFormat.format(_purchaseDate!)
                              : '选择日期',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: '购买价格',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _valueController,
                      decoration: const InputDecoration(
                        labelText: '当前价值',
                        prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 识别信息
                    _buildSectionTitle('识别信息'),
                    TextFormField(
                      controller: _barcodeController,
                      decoration: InputDecoration(
                        labelText: '条码',
                        prefixIcon: const Icon(Icons.barcode_reader),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.qr_code_scanner),
                          onPressed: () {
                            // 扫码功能
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _rfidController,
                      decoration: const InputDecoration(
                        labelText: 'RFID',
                        prefixIcon: Icon(Icons.nfc),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 备注
                    _buildSectionTitle('备注'),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: '备注说明',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // 保存按钮
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveAsset,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('保存'),
                      ),
                    ),
                  ],
                ),
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

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _priceController.dispose();
    _valueController.dispose();
    _personController.dispose();
    _barcodeController.dispose();
    _rfidController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
