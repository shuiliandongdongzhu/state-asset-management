import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class I18nManager {
  static final I18nManager _instance = I18nManager._internal();
  factory I18nManager() => _instance;
  I18nManager._internal();

  String _currentLocale = 'zh_CN';
  Map<String, dynamic> _localizedStrings = {};

  String get currentLocale => _currentLocale;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLocale = prefs.getString('app_language') ?? 'zh_CN';
    await _loadStrings();
  }

  Future<void> setLocale(String locale) async {
    _currentLocale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', locale);
    await _loadStrings();
  }

  Future<void> _loadStrings() async {
    // 内置翻译
    _localizedStrings = _getBuiltinStrings(_currentLocale);
  }

  Map<String, dynamic> _getBuiltinStrings(String locale) {
    final strings = {
      'zh_CN': {
        'app_name': '国有资产管理系统',
        'home': '首页',
        'assets': '资产',
        'inventory': '盘点',
        'reports': '报表',
        'settings': '设置',
        'add': '新增',
        'edit': '编辑',
        'delete': '删除',
        'save': '保存',
        'cancel': '取消',
        'confirm': '确认',
        'search': '搜索',
        'filter': '筛选',
        'sync': '同步',
        'backup': '备份',
        'restore': '恢复',
        'export': '导出',
        'import': '导入',
        'total': '总数',
        'pending': '待处理',
        'completed': '已完成',
        'in_progress': '进行中',
        'asset_name': '资产名称',
        'asset_code': '资产编码',
        'category': '分类',
        'department': '部门',
        'location': '位置',
        'status': '状态',
        'purchase_date': '购买日期',
        'purchase_price': '购买价格',
        'current_value': '当前价值',
        'responsible_person': '责任人',
        'description': '备注',
        'barcode': '条码',
        'rfid': 'RFID',
        'normal': '正常',
        'in_use': '使用中',
        'maintenance': '维修中',
        'scrapped': '已报废',
        'idle': '闲置',
        'scan': '扫描',
        'task_name': '任务名称',
        'task_code': '任务编码',
        'start_date': '开始日期',
        'end_date': '结束日期',
        'scanned': '已盘点',
        'surplus': '盘盈',
        'deficit': '盘亏',
        'no_data': '暂无数据',
        'loading': '加载中...',
        'error': '错误',
        'success': '成功',
        'failed': '失败',
        'retry': '重试',
      },
      'en_US': {
        'app_name': 'State Asset Management',
        'home': 'Home',
        'assets': 'Assets',
        'inventory': 'Inventory',
        'reports': 'Reports',
        'settings': 'Settings',
        'add': 'Add',
        'edit': 'Edit',
        'delete': 'Delete',
        'save': 'Save',
        'cancel': 'Cancel',
        'confirm': 'Confirm',
        'search': 'Search',
        'filter': 'Filter',
        'sync': 'Sync',
        'backup': 'Backup',
        'restore': 'Restore',
        'export': 'Export',
        'import': 'Import',
        'total': 'Total',
        'pending': 'Pending',
        'completed': 'Completed',
        'in_progress': 'In Progress',
        'asset_name': 'Asset Name',
        'asset_code': 'Asset Code',
        'category': 'Category',
        'department': 'Department',
        'location': 'Location',
        'status': 'Status',
        'purchase_date': 'Purchase Date',
        'purchase_price': 'Purchase Price',
        'current_value': 'Current Value',
        'responsible_person': 'Responsible Person',
        'description': 'Description',
        'barcode': 'Barcode',
        'rfid': 'RFID',
        'normal': 'Normal',
        'in_use': 'In Use',
        'maintenance': 'Maintenance',
        'scrapped': 'Scrapped',
        'idle': 'Idle',
        'scan': 'Scan',
        'task_name': 'Task Name',
        'task_code': 'Task Code',
        'start_date': 'Start Date',
        'end_date': 'End Date',
        'scanned': 'Scanned',
        'surplus': 'Surplus',
        'deficit': 'Deficit',
        'no_data': 'No Data',
        'loading': 'Loading...',
        'error': 'Error',
        'success': 'Success',
        'failed': 'Failed',
        'retry': 'Retry',
      },
    };

    return strings[locale] ?? strings['zh_CN']!;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  String t(String key) => translate(key);
}

// 全局翻译函数
String tr(String key) => I18nManager().translate(key);
