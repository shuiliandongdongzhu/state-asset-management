import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/settings_model.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selectedLanguage = 'zh_CN';

  final List<Map<String, String>> _languages = [
    {'code': 'zh_CN', 'name': '简体中文', 'flag': '🇨🇳'},
    {'code': 'zh_TW', 'name': '繁體中文', 'flag': '🇹🇼'},
    {'code': 'en_US', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'ja_JP', 'name': '日本語', 'flag': '🇯🇵'},
    {'code': 'ko_KR', 'name': '한국어', 'flag': '🇰🇷'},
  ];

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('app_settings');
    if (settingsJson != null) {
      final settings = AppSettingsModel.fromMap(jsonDecode(settingsJson));
      setState(() => _selectedLanguage = settings.language);
    }
  }

  Future<void> _saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('app_settings');
    final settings = settingsJson != null
        ? AppSettingsModel.fromMap(jsonDecode(settingsJson))
        : const AppSettingsModel();
    
    final newSettings = settings.copyWith(language: language);
    await prefs.setString('app_settings', jsonEncode(newSettings.toMap()));
    
    setState(() => _selectedLanguage = language);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('语言设置已保存')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('语言设置'),
      ),
      body: ListView.builder(
        itemCount: _languages.length,
        itemBuilder: (context, index) {
          final lang = _languages[index];
          final isSelected = lang['code'] == _selectedLanguage;
          
          return RadioListTile<String>(
            title: Row(
              children: [
                Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Text(lang['name']!),
              ],
            ),
            value: lang['code']!,
            groupValue: _selectedLanguage,
            onChanged: (value) {
              if (value != null) {
                _saveLanguage(value);
              }
            },
            secondary: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
          );
        },
      ),
    );
  }
}
