import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/assets/asset_list_screen.dart';
import '../screens/assets/asset_detail_screen.dart';
import '../screens/assets/asset_form_screen.dart';
import '../screens/inventory/inventory_list_screen.dart';
import '../screens/inventory/inventory_scan_screen.dart';
import '../screens/inventory/inventory_task_screen.dart';
import '../screens/reports/report_dashboard_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/user_profile_screen.dart';
import '../screens/settings/language_settings_screen.dart';
import '../screens/settings/theme_settings_screen.dart';
import '../screens/settings/notification_settings_screen.dart';
import '../screens/settings/backup_settings_screen.dart';
import '../screens/sync/sync_screen.dart';

class AppRouter {
  // 路由名称常量
  static const String home = '/';
  static const String assetList = '/assets';
  static const String assetDetail = '/assets/detail';
  static const String assetForm = '/assets/form';
  static const String inventoryList = '/inventory';
  static const String inventoryScan = '/inventory/scan';
  static const String inventoryTask = '/inventory/task';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String userProfile = '/settings/profile';
  static const String languageSettings = '/settings/language';
  static const String themeSettings = '/settings/theme';
  static const String notificationSettings = '/settings/notifications';
  static const String backupSettings = '/settings/backup';
  static const String sync = '/sync';

  // 路由映射
  static Map<String, WidgetBuilder> get routes => {
    home: (context) => const HomeScreen(),
    assetList: (context) => const AssetListScreen(),
    inventoryList: (context) => const InventoryListScreen(),
    reports: (context) => const ReportDashboardScreen(),
    settings: (context) => const SettingsScreen(),
    userProfile: (context) => const UserProfileScreen(),
    languageSettings: (context) => const LanguageSettingsScreen(),
    themeSettings: (context) => const ThemeSettingsScreen(),
    notificationSettings: (context) => const NotificationSettingsScreen(),
    backupSettings: (context) => const BackupSettingsScreen(),
    sync: (context) => const SyncScreen(),
  };

  // 带参数的路由处理
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case assetDetail:
        final assetId = args?['assetId'] as String?;
        if (assetId == null) return _errorRoute('缺少资产ID');
        return MaterialPageRoute(
          builder: (context) => AssetDetailScreen(assetId: assetId),
        );

      case assetForm:
        final assetId = args?['assetId'] as String?;
        return MaterialPageRoute(
          builder: (context) => AssetFormScreen(assetId: assetId),
        );

      case inventoryTask:
        final taskId = args?['taskId'] as String?;
        if (taskId == null) return _errorRoute('缺少任务ID');
        return MaterialPageRoute(
          builder: (context) => InventoryTaskScreen(taskId: taskId),
        );

      case inventoryScan:
        final taskId = args?['taskId'] as String?;
        return MaterialPageRoute(
          builder: (context) => InventoryScanScreen(taskId: taskId),
        );

      default:
        return null;
    }
  }

  // 错误路由
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('错误')),
        body: Center(child: Text(message)),
      ),
    );
  }

  // 导航辅助方法
  static void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, home, (route) => false);
  }

  static void navigateToAssetList(BuildContext context) {
    Navigator.pushNamed(context, assetList);
  }

  static void navigateToAssetDetail(BuildContext context, String assetId) {
    Navigator.pushNamed(context, assetDetail, arguments: {'assetId': assetId});
  }

  static void navigateToAssetForm(BuildContext context, {String? assetId}) {
    Navigator.pushNamed(context, assetForm, arguments: assetId != null ? {'assetId': assetId} : null);
  }

  static void navigateToInventoryList(BuildContext context) {
    Navigator.pushNamed(context, inventoryList);
  }

  static void navigateToInventoryTask(BuildContext context, String taskId) {
    Navigator.pushNamed(context, inventoryTask, arguments: {'taskId': taskId});
  }

  static void navigateToInventoryScan(BuildContext context, {String? taskId}) {
    Navigator.pushNamed(context, inventoryScan, arguments: taskId != null ? {'taskId': taskId} : null);
  }

  static void navigateToReports(BuildContext context) {
    Navigator.pushNamed(context, reports);
  }

  static void navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, settings);
  }

  static void navigateToSync(BuildContext context) {
    Navigator.pushNamed(context, sync);
  }
}
