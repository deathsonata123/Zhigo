class ApiConfig {
  // API Base URL - EC2 Backend
  static const String baseUrl = 'http://52.74.236.219:3000';
  // Connected to EC2 Express.js backend
  // All API calls will go to this server



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
