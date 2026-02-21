import 'package:equatable/equatable.dart';

// 同步状态枚举
enum SyncStatus {
  idle,       // 空闲
  syncing,    // 同步中
  success,    // 成功
  failed,     // 失败
  offline,    // 离线
}

// 同步配置模型
class SyncConfigModel extends Equatable {
  final String serverUrl;
  final int syncInterval;
  final bool autoSync;
  final bool syncOnWifiOnly;
  final String? lastSyncTime;
  final int syncBatchSize;

  const SyncConfigModel({
    this.serverUrl = '',
    this.syncInterval = 30,
    this.autoSync = true,
    this.syncOnWifiOnly = false,
    this.lastSyncTime,
    this.syncBatchSize = 100,
  });

  factory SyncConfigModel.fromMap(Map<String, dynamic> map) {
    return SyncConfigModel(
      serverUrl: map['serverUrl'] as String? ?? '',
      syncInterval: map['syncInterval'] as int? ?? 30,
      autoSync: map['autoSync'] as bool? ?? true,
      syncOnWifiOnly: map['syncOnWifiOnly'] as bool? ?? false,
      lastSyncTime: map['lastSyncTime'] as String?,
      syncBatchSize: map['syncBatchSize'] as int? ?? 100,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serverUrl': serverUrl,
      'syncInterval': syncInterval,
      'autoSync': autoSync,
      'syncOnWifiOnly': syncOnWifiOnly,
      'lastSyncTime': lastSyncTime,
      'syncBatchSize': syncBatchSize,
    };
  }

  SyncConfigModel copyWith({
    String? serverUrl,
    int? syncInterval,
    bool? autoSync,
    bool? syncOnWifiOnly,
    String? lastSyncTime,
    int? syncBatchSize,
  }) {
    return SyncConfigModel(
      serverUrl: serverUrl ?? this.serverUrl,
      syncInterval: syncInterval ?? this.syncInterval,
      autoSync: autoSync ?? this.autoSync,
      syncOnWifiOnly: syncOnWifiOnly ?? this.syncOnWifiOnly,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      syncBatchSize: syncBatchSize ?? this.syncBatchSize,
    );
  }

  @override
  List<Object?> get props => [
    serverUrl,
    syncInterval,
    autoSync,
    syncOnWifiOnly,
    lastSyncTime,
    syncBatchSize,
  ];
}

// 同步记录模型
class SyncRecordModel extends Equatable {
  final String id;
  final DateTime syncTime;
  final String syncType;
  final int recordsCount;
  final bool success;
  final String? errorMessage;
  final int durationMs;

  const SyncRecordModel({
    required this.id,
    required this.syncTime,
    required this.syncType,
    required this.recordsCount,
    required this.success,
    this.errorMessage,
    required this.durationMs,
  });

  factory SyncRecordModel.fromMap(Map<String, dynamic> map) {
    return SyncRecordModel(
      id: map['id'] as String,
      syncTime: DateTime.parse(map['syncTime'] as String),
      syncType: map['syncType'] as String,
      recordsCount: map['recordsCount'] as int,
      success: map['success'] as bool,
      errorMessage: map['errorMessage'] as String?,
      durationMs: map['durationMs'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'syncTime': syncTime.toIso8601String(),
      'syncType': syncType,
      'recordsCount': recordsCount,
      'success': success,
      'errorMessage': errorMessage,
      'durationMs': durationMs,
    };
  }

  @override
  List<Object?> get props => [
    id,
    syncTime,
    syncType,
    recordsCount,
    success,
    errorMessage,
    durationMs,
  ];
}

// 同步结果模型
class SyncResultModel extends Equatable {
  final bool success;
  final int uploadedCount;
  final int downloadedCount;
  final String? errorMessage;
  final DateTime? timestamp;

  const SyncResultModel({
    this.success = false,
    this.uploadedCount = 0,
    this.downloadedCount = 0,
    this.errorMessage,
    this.timestamp,
  });

  factory SyncResultModel.success({
    int uploadedCount = 0,
    int downloadedCount = 0,
  }) {
    return SyncResultModel(
      success: true,
      uploadedCount: uploadedCount,
      downloadedCount: downloadedCount,
      timestamp: DateTime.now(),
    );
  }

  factory SyncResultModel.failure(String errorMessage) {
    return SyncResultModel(
      success: false,
      errorMessage: errorMessage,
      timestamp: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    success,
    uploadedCount,
    downloadedCount,
    errorMessage,
    timestamp,
  ];
}
