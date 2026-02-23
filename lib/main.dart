import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'screens/asset_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  runApp(const StateAssetApp());
}

class StateAssetApp extends StatelessWidget {
  const StateAssetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '国有资产管理系统',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AssetListScreen(),
    );
  }
}
