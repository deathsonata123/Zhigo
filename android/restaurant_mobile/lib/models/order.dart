class Order {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String customerAddress;
  final String deliveryZone;
  final String? noteToRider;
  final String? noteToRestaurant;
  final String items; // JSON string
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double vat;
  final double tip;
  final double total;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final String? riderId;
  final String? riderName;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final String? rejectionReason;
  final int? prepTime; // in minutes

  Order({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    required this.customerAddress,
    required this.deliveryZone,
    this.noteToRider,
    this.noteToRestaurant,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.vat,
    required this.tip,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    this.riderId,
    this.riderName,
    required this.createdAt,
    this.acceptedAt,
    this.rejectedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.rejectionReason,
    this.prepTime,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      restaurantName: json['restaurant_name'] as String,
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String,
      customerEmail: json['customer_email'] as String?,
      customerAddress: json['customer_address'] as String,
      deliveryZone: json['delivery_zone'] as String,
      noteToRider: json['note_to_rider'] as String?,
      noteToRestaurant: json['note_to_restaurant'] as String?,
      items: json['items'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      serviceFee: (json['service_fee'] as num).toDouble(),
      vat: (json['vat'] as num).toDouble(),
      tip: (json['tip'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
      paymentStatus: json['payment_status'] as String,
      status: json['status'] as String,
      riderId: json['rider_id'] as String?,
      riderName: json['rider_name'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      acceptedAt: json['accepted_at'] != null 
          ? DateTime.parse(json['accepted_at']) 
          : null,
      rejectedAt: json['rejected_at'] != null 
          ? DateTime.parse(json['rejected_at']) 
          : null,
      pickedUpAt: json['picked_up_at'] != null 
          ? DateTime.parse(json['picked_up_at']) 
          : null,
      deliveredAt: json['delivered_at'] != null 
          ? DateTime.parse(json['delivered_at']) 
          : null,
      rejectionReason: json['rejection_reason'] as String?,
      prepTime: json['prep_time'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'restaurant_name': restaurantName,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'customer_address': customerAddress,
      'delivery_zone': deliveryZone,
      'note_to_rider': noteToRider,
      'note_to_restaurant': noteToRestaurant,
      'items': items,
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'service_fee': serviceFee,
      'vat': vat,
      'tip': tip,
      'total': total,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'status': status,
      'rider_id': riderId,
      'rider_name': riderName,
      'created_at': createdAt.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'rejected_at': rejectedAt?.toIso8601String(),
      'picked_up_at': pickedUpAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'prep_time': prepTime,
    };
  }
}
