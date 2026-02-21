import 'package:equatable/equatable.dart';

// 应用设置模型
class AppSettingsModel extends Equatable {
  final String language;
  final String theme;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String dateFormat;
  final String currencySymbol;

  const AppSettingsModel({
    this.language = 'zh_CN',
    this.theme = 'system',
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.dateFormat = 'yyyy-MM-dd',
    this.currencySymbol = '¥',
  });

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      language: map['language'] as String? ?? 'zh_CN',
      theme: map['theme'] as String? ?? 'system',
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      vibrationEnabled: map['vibrationEnabled'] as bool? ?? true,
      dateFormat: map['dateFormat'] as String? ?? 'yyyy-MM-dd',
      currencySymbol: map['currencySymbol'] as String? ?? '¥',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'theme': theme,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'dateFormat': dateFormat,
      'currencySymbol': currencySymbol,
    };
  }

  AppSettingsModel copyWith({
    String? language,
    String? theme,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? dateFormat,
    String? currencySymbol,
  }) {
    return AppSettingsModel(
      language: language ?? this.language,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      dateFormat: dateFormat ?? this.dateFormat,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }

  @override
  List<Object?> get props => [
    language,
    theme,
    notificationsEnabled,
    soundEnabled,
    vibrationEnabled,
    dateFormat,
    currencySymbol,
  ];
}

// 用户设置模型
class UserSettingsModel extends Equatable {
  final String userId;
  final String username;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String? department;
  final String? role;
  final bool isLoggedIn;

  const UserSettingsModel({
    this.userId = '',
    this.username = '',
    this.email,
    this.phone,
    this.avatarUrl,
    this.department,
    this.role,
    this.isLoggedIn = false,
  });

  factory UserSettingsModel.fromMap(Map<String, dynamic> map) {
    return UserSettingsModel(
      userId: map['userId'] as String? ?? '',
      username: map['username'] as String? ?? '',
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      department: map['department'] as String?,
      role: map['role'] as String?,
      isLoggedIn: map['isLoggedIn'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'department': department,
      'role': role,
      'isLoggedIn': isLoggedIn,
    };
  }

  UserSettingsModel copyWith({
    String? userId,
    String? username,
    String? email,
    String? phone,
    String? avatarUrl,
    String? department,
    String? role,
    bool? isLoggedIn,
  }) {
    return UserSettingsModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      department: department ?? this.department,
      role: role ?? this.role,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    username,
    email,
    phone,
    avatarUrl,
    department,
    role,
    isLoggedIn,
  ];
}

// 数据备份设置模型
class BackupSettingsModel extends Equatable {
  final bool autoBackup;
  final int backupInterval;
  final String? lastBackupTime;
  final bool backupToCloud;
  final int keepBackupCount;

  const BackupSettingsModel({
    this.autoBackup = true,
    this.backupInterval = 7,
    this.lastBackupTime,
    this.backupToCloud = false,
    this.keepBackupCount = 5,
  });

  factory BackupSettingsModel.fromMap(Map<String, dynamic> map) {
    return BackupSettingsModel(
      autoBackup: map['autoBackup'] as bool? ?? true,
      backupInterval: map['backupInterval'] as int? ?? 7,
      lastBackupTime: map['lastBackupTime'] as String?,
      backupToCloud: map['backupToCloud'] as bool? ?? false,
      keepBackupCount: map['keepBackupCount'] as int? ?? 5,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'autoBackup': autoBackup,
      'backupInterval': backupInterval,
      'lastBackupTime': lastBackupTime,
      'backupToCloud': backupToCloud,
      'keepBackupCount': keepBackupCount,
    };
  }

  BackupSettingsModel copyWith({
    bool? autoBackup,
    int? backupInterval,
    String? lastBackupTime,
    bool? backupToCloud,
    int? keepBackupCount,
  }) {
    return BackupSettingsModel(
      autoBackup: autoBackup ?? this.autoBackup,
      backupInterval: backupInterval ?? this.backupInterval,
      lastBackupTime: lastBackupTime ?? this.lastBackupTime,
      backupToCloud: backupToCloud ?? this.backupToCloud,
      keepBackupCount: keepBackupCount ?? this.keepBackupCount,
    );
  }

  @override
  List<Object?> get props => [
    autoBackup,
    backupInterval,
    lastBackupTime,
    backupToCloud,
    keepBackupCount,
  ];
}
