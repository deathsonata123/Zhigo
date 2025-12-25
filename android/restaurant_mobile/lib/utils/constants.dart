// API Constants
class ApiConstants {
  // For local development, use localhost
  // For production/testing on device, use your EC2 instance URL
  // Toggle this based on your testing environment
  
  // Local development (emulator can access localhost via 10.0.2.2 on Android)
  // static const String baseUrl = 'http://10.0.2.2:3000';
  
  // EC2 Production URL
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
  static const String appName = 'Zhigo Restaurant';
  static const String prefKeyAuthToken = 'auth_token';
  static const String prefKeyRestaurantId = 'restaurant_id';
  static const String prefKeyUserId = 'user_id';
  static const String prefKeyUserData = 'user_data';
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
