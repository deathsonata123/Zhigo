class DeliveryRequest {
  final String id;
  final String orderId;
  final String restaurantName;
  final String restaurantAddress;
  final String customerName;
  final String customerAddress;
  final double orderTotal;
  final String? noteToRider;
  final double? restaurantLat;
  final double? restaurantLng;
  final double? customerLat;
  final double? customerLng;
  final DateTime createdAt;

  DeliveryRequest({
    required this.id,
    required this.orderId,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.customerName,
    required this.customerAddress,
    required this.orderTotal,
    this.noteToRider,
    this.restaurantLat,
    this.restaurantLng,
    this.customerLat,
    this.customerLng,
    required this.createdAt,
  });

  factory DeliveryRequest.fromJson(Map<String, dynamic> json) {
    return DeliveryRequest(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? json['order_id'] ?? '',
      restaurantName: json['restaurantName'] ?? json['restaurant_name'] ?? '',
      restaurantAddress: json['restaurantAddress'] ?? json['restaurant_address'] ?? '',
      customerName: json['customerName'] ?? json['customer_name'] ?? '',
      customerAddress: json['customerAddress'] ?? json['customer_address'] ?? '',
      orderTotal: (json['orderTotal'] ?? json['order_total'] ?? 0).toDouble(),
      noteToRider: json['noteToRider'] ?? json['note_to_rider'],
      restaurantLat: json['restaurantLatitude']?.toDouble(),
      restaurantLng: json['restaurantLongitude']?.toDouble(),
      customerLat: json['customerLatitude']?.toDouble(),
      customerLng: json['customerLongitude']?.toDouble(),
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt']) 
        : DateTime.now(),
    );
  }
}
