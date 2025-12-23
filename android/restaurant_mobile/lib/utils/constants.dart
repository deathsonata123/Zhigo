// API Constants
class ApiConstants {
  // Base EC2 API URL - Update this with your actual EC2 instance URL
  static const String baseUrl = 'http://52.74.236.219:3000';
  
  // API Endpoints
  static const String restaurants = '/api/restaurants';
  static const String orders = '/api/orders';
  static const String riders = '/api/riders';
  static const String reviews = '/api/reviews';
  static const String auth = '/api/auth';
  static const String storage = '/api/storage';
  
  // Request timeout
  static const Duration timeout = Duration(seconds: 30);
}

// App Constants
class AppConstants {
  static const String appName = 'Restaurant Dashboard';
  static const String prefKeyAuthToken = 'auth_token';
  static const String prefKeyRestaurantId = 'restaurant_id';
  static const String prefKeyUserId = 'user_id';
}

// Order Status Constants
class OrderStatus {
  static const String pending = 'pending';
  static const String accepted = 'accepted';
  static const String rejected = 'rejected';
  static const String preparing = 'preparing';
  static const String ready = 'ready';
  static const String pickedUp = 'picked_up';
  static const String delivered = 'delivered';
  static const String cancelled = 'cancelled';
}
