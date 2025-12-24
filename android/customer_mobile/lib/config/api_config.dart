class ApiConfig {
  // Using localhost for development
  // For production, use EC2: http://52.74.236.219:3000
  
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );


  // API Endpoints
  static const String apiPrefix = '/api';
  
  // Auth endpoints
  static String get authLogin => '$apiPrefix/auth/login';
  static String get authSignup => '$apiPrefix/auth/signup';
  static String get authLogout => '$apiPrefix/auth/logout';
  
  // Restaurant endpoints
  static String get restaurants => '$apiPrefix/restaurants';
  static String restaurantDetails(String id) => '$apiPrefix/restaurants/$id';
  static String restaurantMenu(String id) => '$apiPrefix/restaurants/$id/menu';
  
  // Order endpoints
  static String get orders => '$apiPrefix/orders';
  static String orderDetails(String id) => '$apiPrefix/orders/$id';
  
  // User endpoints
  static String get userProfile => '$apiPrefix/users/profile';
}
