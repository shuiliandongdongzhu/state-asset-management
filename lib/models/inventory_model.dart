// 盘点状态枚举
enum InventoryStatus {
  pending,   // 未盘点
  scanned,   // 已盘点
  surplus,   // 盘盈
  deficit,   // 盘亏
}

// 盘点任务状态枚举
enum InventoryTaskStatus {
  pending,   // 待开始
  active,    // 进行中
  completed, // 已完成
  cancelled, // 已取消
}

// 盘点任务模型
class InventoryTaskModel {
  final String id;
  final String taskName;
  final String taskCode;
  final DateTime startDate;
  final DateTime endDate;
  final int status;
  final String? departmentId;
  final String? locationId;
  final String? description;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int syncStatus;
  final DateTime? syncTime;

  InventoryTaskModel({
    required this.id,
    required this.taskName,
    required this.taskCode,
    required this.startDate,
    required this.endDate,
    this.status = 0,
    this.departmentId,
    this.locationId,
    this.description,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 0,
    this.syncTime,
  });

  factory InventoryTaskModel.fromMap(Map<String, dynamic> map) {
    return InventoryTaskModel(
      id: map['id'] as String,
      taskName: map['task_name'] as String,
      taskCode: map['task_code'] as String,
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date'] as int),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['end_date'] as int),
      status: map['status'] as int? ?? 0,
      departmentId: map['department_id'] as String?,
      locationId: map['location_id'] as String?,
      description: map['description'] as String?,
      createdBy: map['created_by'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      syncStatus: map['sync_status'] as int? ?? 0,
      syncTime: map['sync_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['sync_time'] as int)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_name': taskName,
      'task_code': taskCode,
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate.millisecondsSinceEpoch,
      'status': status,
      'department_id': departmentId,
      'location_id': locationId,
      'description': description,
      'created_by': createdBy,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'sync_status': syncStatus,
      'sync_time': syncTime?.millisecondsSinceEpoch,
    };
  }

  InventoryTaskModel copyWith({
    String? id,
    String? taskName,
    String? taskCode,
    DateTime? startDate,
    DateTime? endDate,
    int? status,
    String? departmentId,
    String? locationId,
    String? description,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? syncStatus,
    DateTime? syncTime,
  }) {
    return InventoryTaskModel(
      id: id ?? this.id,
      taskName: taskName ?? this.taskName,
      taskCode: taskCode ?? this.taskCode,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      departmentId: departmentId ?? this.departmentId,
      locationId: locationId ?? this.locationId,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncTime: syncTime ?? this.syncTime,
    );
  }

  String get statusText {
    switch (status) {
      case 0:
        return '待开始';
      case 1:
        return '进行中';
      case 2:
        return '已完成';
      case 3:
        return '已取消';
      default:
        return '未知';
    }
  }

  bool get isActive => status == 1;
  bool get isCompleted => status == 2;
  bool get isPending => status == 0;
}

// 盘点记录模型
class InventoryRecordModel {
  final String id;
  final String taskId;
  final String assetId;
  final int inventoryStatus;
  final DateTime? scanTime;
  final String? scanLocation;
  final String? scanUser;
  final String? notes;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  InventoryRecordModel({
    required this.id,
    required this.taskId,
    required this.assetId,
    this.inventoryStatus = 0,
    this.scanTime,
    this.scanLocation,
    this.scanUser,
    this.notes,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InventoryRecordModel.fromMap(Map<String, dynamic> map) {
    return InventoryRecordModel(
      id: map['id'] as String,
      taskId: map['task_id'] as String,
      assetId: map['asset_id'] as String,
      inventoryStatus: map['inventory_status'] as int? ?? 0,
      scanTime: map['scan_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['scan_time'] as int)
          : null,
      scanLocation: map['scan_location'] as String?,
      scanUser: map['scan_user'] as String?,
      notes: map['notes'] as String?,
      imagePath: map['image_path'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'asset_id': assetId,
      'inventory_status': inventoryStatus,
      'scan_time': scanTime?.millisecondsSinceEpoch,
      'scan_location': scanLocation,
      'scan_user': scanUser,
      'notes': notes,
      'image_path': imagePath,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  InventoryRecordModel copyWith({
    String? id,
    String? taskId,
    String? assetId,
    int? inventoryStatus,
    DateTime? scanTime,
    String? scanLocation,
    String? scanUser,
    String? notes,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryRecordModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      assetId: assetId ?? this.assetId,
      inventoryStatus: inventoryStatus ?? this.inventoryStatus,
      scanTime: scanTime ?? this.scanTime,
      scanLocation: scanLocation ?? this.scanLocation,
      scanUser: scanUser ?? this.scanUser,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get statusText {
    switch (inventoryStatus) {
      case 0:
        return '未盘点';
      case 1:
        return '已盘点';
      case 2:
        return '盘盈';
      case 3:
        return '盘亏';
      default:
        return '未知';
    }
  }

  bool get isScanned => inventoryStatus != 0;
}

// 盘点结果汇总模型
class InventorySummaryModel {
  final String taskId;
  final String taskName;
  final int totalCount;
  final int scannedCount;
  final int surplusCount;
  final int deficitCount;
  final int pendingCount;
  final double progress;

  InventorySummaryModel({
    required this.taskId,
    required this.taskName,
    required this.totalCount,
    required this.scannedCount,
    required this.surplusCount,
    required this.deficitCount,
    required this.pendingCount,
    required this.progress,
  });

  factory InventorySummaryModel.fromStatistics(
    String taskId,
    String taskName,
    Map<String, int> statistics,
  ) {
    final total = statistics['total'] ?? 0;
    final scanned = statistics['scanned'] ?? 0;
    final surplus = statistics['surplus'] ?? 0;
    final deficit = statistics['deficit'] ?? 0;
    final pending = statistics['pending'] ?? 0;
    
    return InventorySummaryModel(
      taskId: taskId,
      taskName: taskName,
      totalCount: total,
      scannedCount: scanned,
      surplusCount: surplus,
      deficitCount: deficit,
      pendingCount: pending,
      progress: total > 0 ? scanned / total : 0.0,
    );
  }
}
