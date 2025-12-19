class ApiConfig {
  // API Base URL - switch between development and production
  static const String baseUrl = bool.fromEnvironment('dart.vm.product')
      ? 'https://your-ec2-domain.com'  // TODO: Replace with your EC2 domain
      : 'http://10.0.2.2:3000';  // Android emulator localhost

  // API Endpoints
  static const String restaurantsEndpoint = '/api/restaurants';
  static const String menuItemsEndpoint = '/api/menu-items';
  static const String ordersEndpoint = '/api/orders';
  static const String usersEndpoint = '/api/users';
  static const String addressesEndpoint = '/api/addresses';
  static const String reviewsEndpoint = '/api/reviews';
  static const String authEndpoint = '/api/auth';
  static const String storageUploadEndpoint = '/api/storage/upload-url';
  static const String storageDownloadEndpoint = '/api/storage/download-url';

  // Storage
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  
  // Map
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY'; // TODO: Add your API key
}
