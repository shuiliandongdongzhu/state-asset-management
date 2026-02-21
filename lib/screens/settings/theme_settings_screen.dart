import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/settings_model.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  String _selectedTheme = 'system';

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('app_settings');
    if (settingsJson != null) {
      final settings = AppSettingsModel.fromMap(jsonDecode(settingsJson));
      setState(() => _selectedTheme = settings.theme);
    }
  }

  Future<void> _saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('app_settings');
    final settings = settingsJson != null
        ? AppSettingsModel.fromMap(jsonDecode(settingsJson))
        : const AppSettingsModel();
    
    final newSettings = settings.copyWith(theme: theme);
    await prefs.setString('app_settings', jsonEncode(newSettings.toMap()));
    
    setState(() => _selectedTheme = theme);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('主题设置已保存')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('主题设置'),
      ),
      body: ListView(
        children: [
          _buildThemeOption(
            '跟随系统',
            'system',
            Icons.brightness_auto,
            Colors.blue,
          ),
          _buildThemeOption(
            '浅色模式',
            'light',
            Icons.brightness_high,
            Colors.orange,
          ),
          _buildThemeOption(
            '深色模式',
            'dark',
            Icons.brightness_2,
            Colors.indigo,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String title, String value, IconData icon, Color color) {
    final isSelected = _selectedTheme == value;
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
          : null,
      onTap: () => _saveTheme(value),
    );
  }
}
