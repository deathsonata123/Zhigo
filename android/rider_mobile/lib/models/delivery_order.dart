class DeliveryOrder {
  final String id;
  final String restaurantName;
  final String restaurantAddress;
  final double? restaurantLatitude;
  final double? restaurantLongitude;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final double? customerLatitude;
  final double? customerLongitude;
  final String? noteToRider;
  final String items; // JSON string
  final double total;
  final double tip;
  final String status;
  final String paymentMethod;
  final int? prepTime;
  final DateTime createdAt;
  final DateTime? assignedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;

  DeliveryOrder({
    required this.id,
    required this.restaurantName,
    required this.restaurantAddress,
    this.restaurantLatitude,
    this.restaurantLongitude,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    this.customerLatitude,
    this.customerLongitude,
    this.noteToRider,
    required this.items,
    required this.total,
    required this.tip,
    required this.status,
    required this.paymentMethod,
    this.prepTime,
    required this.createdAt,
    this.assignedAt,
    this.pickedUpAt,
    this.deliveredAt,
  });

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    return DeliveryOrder(
      id: json['id'] as String,
      restaurantName: json['restaurant_name'] as String,
      restaurantAddress: json['restaurant_address'] as String? ?? '',
      restaurantLatitude: (json['restaurant_latitude'] as num?)?.toDouble(),
      restaurantLongitude: (json['restaurant_longitude'] as num?)?.toDouble(),
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String,
      customerAddress: json['customer_address'] as String,
      customerLatitude: (json['customer_latitude'] as num?)?.toDouble(),
      customerLongitude: (json['customer_longitude'] as num?)?.toDouble(),
      noteToRider: json['note_to_rider'] as String?,
      items: json['items'] as String,
      total: (json['total'] as num).toDouble(),
      tip: (json['tip'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String,
      paymentMethod: json['payment_method'] as String,
      prepTime: json['prep_time'] as int?,
      createdAt: DateTime.parse(json['created_at']),
      assignedAt: json['rider_assigned_at'] != null 
          ? DateTime.parse(json['rider_assigned_at']) 
          : null,
      pickedUpAt: json['picked_up_at'] != null 
          ? DateTime.parse(json['picked_up_at']) 
          : null,
      deliveredAt: json['delivered_at'] != null 
          ? DateTime.parse(json['delivered_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_name': restaurantName,
      'restaurant_address': restaurantAddress,
      'restaurant_latitude': restaurantLatitude,
      'restaurant_longitude': restaurantLongitude,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_address': customerAddress,
      'customer_latitude': customerLatitude,
      'customer_longitude': customerLongitude,
      'note_to_rider': noteToRider,
      'items': items,
      'total': total,
      'tip': tip,
      'status': status,
      'payment_method': paymentMethod,
      'prep_time': prepTime,
      'created_at': createdAt.toIso8601String(),
      'rider_assigned_at': assignedAt?.toIso8601String(),
      'picked_up_at': pickedUpAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
    };
  }
}
