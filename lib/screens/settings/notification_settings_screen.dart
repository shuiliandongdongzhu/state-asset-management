import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/settings_model.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _inventoryReminders = true;
  bool _syncNotifications = true;
  bool _systemUpdates = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('app_settings');
    if (settingsJson != null) {
      final settings = AppSettingsModel.fromMap(jsonDecode(settingsJson));
      setState(() {
        _notificationsEnabled = settings.notificationsEnabled;
        _soundEnabled = settings.soundEnabled;
        _vibrationEnabled = settings.vibrationEnabled;
      });
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('app_settings');
    final settings = settingsJson != null
        ? AppSettingsModel.fromMap(jsonDecode(settingsJson))
        : const AppSettingsModel();
    
    final newSettings = settings.copyWith(
      notificationsEnabled: _notificationsEnabled,
      soundEnabled: _soundEnabled,
      vibrationEnabled: _vibrationEnabled,
    );
    await prefs.setString('app_settings', jsonEncode(newSettings.toMap()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知设置'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('启用通知'),
            subtitle: const Text('接收应用通知'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              _saveSettings();
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('声音'),
            subtitle: const Text('通知时播放声音'),
            value: _soundEnabled,
            onChanged: _notificationsEnabled
                ? (value) {
                    setState(() => _soundEnabled = value);
                    _saveSettings();
                  }
                : null,
          ),
          SwitchListTile(
            title: const Text('振动'),
            subtitle: const Text('通知时振动'),
            value: _vibrationEnabled,
            onChanged: _notificationsEnabled
                ? (value) {
                    setState(() => _vibrationEnabled = value);
                    _saveSettings();
                  }
                : null,
          ),
          const Divider(),
          _buildSectionHeader('通知类型'),
          SwitchListTile(
            title: const Text('盘点提醒'),
            subtitle: const Text('盘点任务开始和截止提醒'),
            value: _inventoryReminders,
            onChanged: _notificationsEnabled
                ? (value) => setState(() => _inventoryReminders = value)
                : null,
          ),
          SwitchListTile(
            title: const Text('同步通知'),
            subtitle: const Text('数据同步完成或失败通知'),
            value: _syncNotifications,
            onChanged: _notificationsEnabled
                ? (value) => setState(() => _syncNotifications = value)
                : null,
          ),
          SwitchListTile(
            title: const Text('系统更新'),
            subtitle: const Text('应用更新和系统公告'),
            value: _systemUpdates,
            onChanged: _notificationsEnabled
                ? (value) => setState(() => _systemUpdates = value)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
