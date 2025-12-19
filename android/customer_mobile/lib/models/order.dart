class CartItem {
  final String menuItemId;
  final String name;
  final double price;
  final String? imageUrl;
  int quantity;

  CartItem({
    required this.menuItemId,
    required this.name,
    required this.price,
    this.imageUrl,
    this.quantity = 1,
  });

  double get total => price * quantity;
}

class Order {
  final String? id;
  final String customerId;
  final String restaurantId;
  final List<OrderItem> items;
  final String? addressId;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String status;
  final String? paymentMethod;
  final DateTime? createdAt;

  Order({
    this.id,
    required this.customerId,
    required this.restaurantId,
    required this.items,
    this.addressId,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    this.status = 'pending',
    this.paymentMethod,
    this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString(),
      customerId: json['customer_id'].toString(),
      restaurantId: json['restaurant_id'].toString(),
      items: (json['items'] as List?)?.map((i) => OrderItem.fromJson(i)).toList() ?? [],
      addressId: json['address_id']?.toString(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'customer_id': customerId,
    'restaurant_id': restaurantId,
    'items': items.map((item) => item.toJson()).toList(),
    if (addressId != null) 'address_id': addressId,
    'subtotal': subtotal,
    'delivery_fee': deliveryFee,
    'total': total,
    'status': status,
    if (paymentMethod != null) 'payment_method': paymentMethod,
  };
}

class OrderItem {
  final String menuItemId;
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      menuItemId: json['menu_item_id'].toString(),
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'menu_item_id': menuItemId,
    'name': name,
    'quantity': quantity,
    'price': price,
  };
}
