import '../config/api_config.dart';
import '../models/restaurant.dart';
import '../models/menu_item.dart';
import 'api_service.dart';

class RestaurantService {
  final ApiService _apiService = ApiService();

  Future<List<Restaurant>> getRestaurants() async {
    final response = await _apiService.get(ApiConfig.restaurantsEndpoint, includeAuth: false);
    
    if (response is List) {
      // Filter approved restaurants only
      return response
          .map((json) => Restaurant.fromJson(json))
          .where((restaurant) => restaurant.status == 'approved')
          .toList();
    }
    return [];
  }

  Future<Restaurant?> getRestaurant(String id) async {
    final response = await _apiService.get('${ApiConfig.restaurantsEndpoint}/$id', includeAuth: false);
    return response != null ? Restaurant.fromJson(response) : null;
  }

  Future<List<MenuItem>> getMenuItems(String restaurantId) async {
    final response = await _apiService.get(
      '${ApiConfig.menuItemsEndpoint}?restaurant_id=$restaurantId',
      includeAuth: false,
    );
    
    if (response is List) {
      return response
          .map((json) => MenuItem.fromJson(json))
          .where((item) => item.available)
          .toList();
    }
    return [];
  }

  Future<List<Restaurant>> searchRestaurants(String query) async {
    final restaurants = await getRestaurants();
    return restaurants
        .where((r) => r.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
