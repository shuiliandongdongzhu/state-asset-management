import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/settings_model.dart';

class BackupSettingsScreen extends StatefulWidget {
  const BackupSettingsScreen({Key? key}) : super(key: key);

  @override
  State<BackupSettingsScreen> createState() => _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends State<BackupSettingsScreen> {
  bool _autoBackup = true;
  int _backupInterval = 7;
  String? _lastBackupTime;
  bool _isBackingUp = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('backup_settings');
    if (settingsJson != null) {
      final settings = BackupSettingsModel.fromMap(jsonDecode(settingsJson));
      setState(() {
        _autoBackup = settings.autoBackup;
        _backupInterval = settings.backupInterval;
        _lastBackupTime = settings.lastBackupTime;
      });
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = BackupSettingsModel(
      autoBackup: _autoBackup,
      backupInterval: _backupInterval,
      lastBackupTime: _lastBackupTime,
    );
    await prefs.setString('backup_settings', jsonEncode(settings.toMap()));
  }

  Future<void> _performBackup() async {
    setState(() => _isBackingUp = true);

    // 模拟备份过程
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _lastBackupTime = DateTime.now().toIso8601String();
      _isBackingUp = false;
    });
    _saveSettings();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('备份完成')),
      );
    }
  }

  Future<void> _restoreBackup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('恢复数据'),
        content: const Text('确定要恢复备份数据吗？当前数据将被覆盖。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('恢复'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // 模拟恢复过程
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('数据恢复中...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('备份与恢复'),
      ),
      body: ListView(
        children: [
          // 备份状态
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.cloud_done, size: 48, color: Colors.green[700]),
                const SizedBox(height: 8),
                Text(
                  '数据已保护',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _lastBackupTime != null
                      ? '上次备份: ${_formatDate(_lastBackupTime!)}'
                      : '尚未备份',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // 自动备份设置
          SwitchListTile(
            title: const Text('自动备份'),
            subtitle: const Text('定期自动备份数据'),
            value: _autoBackup,
            onChanged: (value) {
              setState(() => _autoBackup = value);
              _saveSettings();
            },
          ),

          // 备份频率
          ListTile(
            title: const Text('备份频率'),
            subtitle: Text('每 $_backupInterval 天'),
            enabled: _autoBackup,
            trailing: DropdownButton<int>(
              value: _backupInterval,
              onChanged: _autoBackup
                  ? (value) {
                      if (value != null) {
                        setState(() => _backupInterval = value);
                        _saveSettings();
                      }
                    }
                  : null,
              items: [1, 3, 7, 14, 30].map((days) {
                return DropdownMenuItem(
                  value: days,
                  child: Text('$days 天'),
                );
              }).toList(),
            ),
          ),
          const Divider(),

          // 手动备份
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('立即备份'),
            subtitle: const Text('手动备份当前数据'),
            trailing: _isBackingUp
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
            onTap: _isBackingUp ? null : _performBackup,
          ),

          // 恢复数据
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('恢复数据'),
            subtitle: const Text('从备份恢复数据'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _restoreBackup,
          ),

          // 导出备份文件
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('导出备份文件'),
            subtitle: const Text('导出备份到本地存储'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('导出功能开发中')),
              );
            },
          ),

          // 导入备份文件
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('导入备份文件'),
            subtitle: const Text('从本地文件导入备份'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('导入功能开发中')),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
