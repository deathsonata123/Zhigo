import '../config/api_config.dart';
import '../models/menu_item.dart';
import 'api_service.dart';

class MenuService {
  final ApiService _apiService = ApiService();

  Future<List<MenuItem>> getMyMenuItems(String restaurantId) async {
    final response = await _apiService.get(
      '${ApiConfig.menuItemsEndpoint}?restaurant_id=$restaurantId',
    );
    
    if (response is List) {
      return response.map((json) => MenuItem.fromJson(json)).toList();
    }
    return [];
  }

  Future<MenuItem> createMenuItem(MenuItem item) async {
    final response = await _apiService.post(
      ApiConfig.menuItemsEndpoint,
      item.toJson(),
    );
    return MenuItem.fromJson(response);
  }

  Future<MenuItem> updateMenuItem(MenuItem item) async {
    final response = await _apiService.put(
      '${ApiConfig.menuItemsEndpoint}/${item.id}',
      item.toJson(),
    );
    return MenuItem.fromJson(response);
  }

  Future<void> deleteMenuItem(String id) async {
    await _apiService.delete('${ApiConfig.menuItemsEndpoint}/$id');
  }

  Future<void> toggleAvailability(String id, bool available) async {
    await _apiService.put(
      '${ApiConfig.menuItemsEndpoint}/$id',
      {'available': available},
    );
  }
}
