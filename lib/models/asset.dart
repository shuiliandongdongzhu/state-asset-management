class Asset {
  final int? id;
  final String name;
  final String code;
  final String category;
  final double value;
  final String status;
  final String? location;
  final String? department;
  final DateTime? purchaseDate;
  final DateTime createdAt;

  Asset({
    this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.value,
    this.status = '正常',
    this.location,
    this.department,
    this.purchaseDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'category': category,
      'value': value,
      'status': status,
      'location': location,
      'department': department,
      'purchase_date': purchaseDate?.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Asset.fromMap(Map<String, dynamic> map) {
    return Asset(
      id: map['id'] as int?,
      name: map['name'] as String,
      code: map['code'] as String,
      category: map['category'] as String,
      value: map['value'] as double,
      status: map['status'] as String? ?? '正常',
      location: map['location'] as String?,
      department: map['department'] as String?,
      purchaseDate: map['purchase_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['purchase_date'] as int)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }
}
