class Review {
  final String id;
  final String restaurantId;
  final String userName;
  final int rating;
  final String comment;
  final String orderType;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.restaurantId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.orderType,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      userName: json['user_name'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String? ?? '',
      orderType: json['order_type'] as String? ?? 'delivery',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'user_name': userName,
      'rating': rating,
      'comment': comment,
      'order_type': orderType,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
