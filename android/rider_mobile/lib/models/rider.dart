class Rider {
  final String id;
  final String userId;
  final String fullName;
  final String phone;
  final String? email;
  final String? zone;
  final String status; // pending, approved, suspended
  final bool isOnline;
  final String? currentOrderId;
  final int totalDeliveries;
  final double totalEarnings;
  final DateTime? createdAt;

  Rider({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    this.email,
    this.zone,
    required this.status,
    required this.isOnline,
    this.currentOrderId,
    required this.totalDeliveries,
    required this.totalEarnings,
    this.createdAt,
  });

  factory Rider.fromJson(Map<String, dynamic> json) {
    return Rider(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      zone: json['zone'] as String?,
      status: json['status'] as String? ?? 'pending',
      isOnline: json['is_online'] as bool? ?? false,
      currentOrderId: json['current_order_id'] as String?,
      totalDeliveries: json['total_deliveries'] as int? ?? 0,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'zone': zone,
      'status': status,
      'is_online': isOnline,
      'current_order_id': currentOrderId,
      'total_deliveries': totalDeliveries,
      'total_earnings': totalEarnings,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Rider copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? phone,
    String? email,
    String? zone,
    String? status,
    bool? isOnline,
    String? currentOrderId,
    int? totalDeliveries,
    double? totalEarnings,
    DateTime? createdAt,
  }) {
    return Rider(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      zone: zone ?? this.zone,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      currentOrderId: currentOrderId ?? this.currentOrderId,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
