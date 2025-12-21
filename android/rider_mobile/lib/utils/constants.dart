// API Constants
class ApiConstants {
  // Base EC2 API URL - Update with actual EC2 instance URL
  static const String baseUrl = 'http://localhost:3000';
  
  // API Endpoints
  static const String riders = '/api/riders';
  static const String orders = '/api/orders';
  static const String auth = '/api/auth';
  
  // Request timeout
  static const Duration timeout = Duration(seconds: 30);
}

// App Constants
class AppConstants {
  static const String appName = 'Rider App';
  static const String prefKeyAuthToken = 'auth_token';
  static const String prefKeyRiderId = 'rider_id';
  static const String prefKeyUserId = 'user_id';
}

// Order Status Constants
class OrderStatus {
  static const String assigned = 'assigned';
  static const String atRestaurant = 'at_restaurant';
  static const String pickedUp = 'picked_up';
  static const String delivering = 'delivering';
  static const String delivered = 'delivered';
}

// Rider Status Constants
class RiderStatus {
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String suspended = 'suspended';
}
