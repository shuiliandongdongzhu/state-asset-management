// 资产状态枚举
enum AssetStatus {
  normal,      // 正常
  inUse,       // 使用中
  maintenance, // 维修中
  scrapped,    // 已报废
  idle,        // 闲置
}

// 资产分类模型
class AssetCategoryModel {
  final String id;
  final String name;
  final String code;
  final String? parentId;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  AssetCategoryModel({
    required this.id,
    required this.name,
    required this.code,
    this.parentId,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssetCategoryModel.fromMap(Map<String, dynamic> map) {
    return AssetCategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      code: map['code'] as String,
      parentId: map['parent_id'] as String?,
      description: map['description'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'parent_id': parentId,
      'description': description,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }
}

// 部门模型
class DepartmentModel {
  final String id;
  final String name;
  final String code;
  final String? parentId;
  final String? manager;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  DepartmentModel({
    required this.id,
    required this.name,
    required this.code,
    this.parentId,
    this.manager,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DepartmentModel.fromMap(Map<String, dynamic> map) {
    return DepartmentModel(
      id: map['id'] as String,
      name: map['name'] as String,
      code: map['code'] as String,
      parentId: map['parent_id'] as String?,
      manager: map['manager'] as String?,
      description: map['description'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'parent_id': parentId,
      'manager': manager,
      'description': description,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }
}

// 位置模型
class LocationModel {
  final String id;
  final String name;
  final String code;
  final String? parentId;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  LocationModel({
    required this.id,
    required this.name,
    required this.code,
    this.parentId,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      id: map['id'] as String,
      name: map['name'] as String,
      code: map['code'] as String,
      parentId: map['parent_id'] as String?,
      description: map['description'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'parent_id': parentId,
      'description': description,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }
}

// 资产模型
class AssetModel {
  final String id;
  final String assetCode;
  final String assetName;
  final String? categoryId;
  final String? categoryName;
  final String? departmentId;
  final String? departmentName;
  final String? locationId;
  final String? locationName;
  final DateTime? purchaseDate;
  final double? purchasePrice;
  final double? currentValue;
  final int status;
  final String? responsiblePerson;
  final String? description;
  final String? imagePath;
  final String? barcode;
  final String? rfid;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int syncStatus;
  final DateTime? syncTime;

  AssetModel({
    required this.id,
    required this.assetCode,
    required this.assetName,
    this.categoryId,
    this.categoryName,
    this.departmentId,
    this.departmentName,
    this.locationId,
    this.locationName,
    this.purchaseDate,
    this.purchasePrice,
    this.currentValue,
    this.status = 0,
    this.responsiblePerson,
    this.description,
    this.imagePath,
    this.barcode,
    this.rfid,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 0,
    this.syncTime,
  });

  factory AssetModel.fromMap(Map<String, dynamic> map) {
    return AssetModel(
      id: map['id'] as String,
      assetCode: map['asset_code'] as String,
      assetName: map['asset_name'] as String,
      categoryId: map['category_id'] as String?,
      categoryName: map['category_name'] as String?,
      departmentId: map['department_id'] as String?,
      departmentName: map['department_name'] as String?,
      locationId: map['location_id'] as String?,
      locationName: map['location_name'] as String?,
      purchaseDate: map['purchase_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['purchase_date'] as int)
          : null,
      purchasePrice: map['purchase_price'] as double?,
      currentValue: map['current_value'] as double?,
      status: map['status'] as int? ?? 0,
      responsiblePerson: map['responsible_person'] as String?,
      description: map['description'] as String?,
      imagePath: map['image_path'] as String?,
      barcode: map['barcode'] as String?,
      rfid: map['rfid'] as String?,
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
      'asset_code': assetCode,
      'asset_name': assetName,
      'category_id': categoryId,
      'category_name': categoryName,
      'department_id': departmentId,
      'department_name': departmentName,
      'location_id': locationId,
      'location_name': locationName,
      'purchase_date': purchaseDate?.millisecondsSinceEpoch,
      'purchase_price': purchasePrice,
      'current_value': currentValue,
      'status': status,
      'responsible_person': responsiblePerson,
      'description': description,
      'image_path': imagePath,
      'barcode': barcode,
      'rfid': rfid,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'sync_status': syncStatus,
      'sync_time': syncTime?.millisecondsSinceEpoch,
    };
  }

  AssetModel copyWith({
    String? id,
    String? assetCode,
    String? assetName,
    String? categoryId,
    String? categoryName,
    String? departmentId,
    String? departmentName,
    String? locationId,
    String? locationName,
    DateTime? purchaseDate,
    double? purchasePrice,
    double? currentValue,
    int? status,
    String? responsiblePerson,
    String? description,
    String? imagePath,
    String? barcode,
    String? rfid,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? syncStatus,
    DateTime? syncTime,
  }) {
    return AssetModel(
      id: id ?? this.id,
      assetCode: assetCode ?? this.assetCode,
      assetName: assetName ?? this.assetName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      currentValue: currentValue ?? this.currentValue,
      status: status ?? this.status,
      responsiblePerson: responsiblePerson ?? this.responsiblePerson,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      barcode: barcode ?? this.barcode,
      rfid: rfid ?? this.rfid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncTime: syncTime ?? this.syncTime,
    );
  }

  String get statusText {
    switch (status) {
      case 0:
        return '正常';
      case 1:
        return '使用中';
      case 2:
        return '维修中';
      case 3:
        return '已报废';
      case 4:
        return '闲置';
      default:
        return '未知';
    }
  }
}
