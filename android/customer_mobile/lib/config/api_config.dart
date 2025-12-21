class ApiConfig {
  // EC2 Backend - Using HTTP (no SSL configured)
  // EC2 IP: 52.74.236.219
  
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://52.74.236.219:3000',
  );

  static const String awsRegion = String.fromEnvironment(
    'AWS_REGION',
    defaultValue: 'us-east-1',
  );

  static const String cognitoUserPoolId = String.fromEnvironment(
    'COGNITO_USER_POOL_ID',
    defaultValue: '',
  );

  static const String cognitoClientId = String.fromEnvironment(
    'COGNITO_CLIENT_ID',
    defaultValue: '',
  );

  // API Endpoints
  static const String apiPrefix = '/api';
  
  // Auth endpoints
  static String get authLogin => '$baseUrl$apiPrefix/auth/login';
  static String get authSignup => '$baseUrl$apiPrefix/auth/signup';
  static String get authLogout => '$baseUrl$apiPrefix/auth/logout';
  
  // Restaurant endpoints
  static String get restaurants => '$baseUrl$apiPrefix/restaurants';
  static String restaurantDetails(String id) => '$baseUrl$apiPrefix/restaurants/$id';
  static String restaurantMenu(String id) => '$baseUrl$apiPrefix/restaurants/$id/menu';
  
  // Order endpoints
  static String get orders => '$baseUrl$apiPrefix/orders';
  static String orderDetails(String id) => '$baseUrl$apiPrefix/orders/$id';
  
  // User endpoints
  static String get userProfile => '$baseUrl$apiPrefix/user/profile';
}
