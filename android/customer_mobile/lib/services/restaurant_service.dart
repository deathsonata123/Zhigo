import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class RestaurantService {
  final ApiService _apiService = ApiService();

  // Get all restaurants
  Future<List<Map<String, dynamic>>> getRestaurants() async {
    try {
      final response = await _apiService.get(ApiConfig.restaurants);
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }
      
      return [];
    } catch (e) {
      debugPrint('Error fetching restaurants: $e');
      return [];
    }
  }

  // Get restaurant details
  Future<Map<String, dynamic>?> getRestaurantDetails(String id) async {
    try {
      final response = await _apiService.get(ApiConfig.restaurantDetails(id));
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      debugPrint('Error fetching restaurant details: $e');
      return null;
    }
  }

  // Get restaurant menu
  Future<List<Map<String, dynamic>>> getRestaurantMenu(String id) async {
    try {
      final response = await _apiService.get(ApiConfig.restaurantMenu(id));
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }
      
      return [];
    } catch (e) {
      debugPrint('Error fetching restaurant menu: $e');
      return [];
    }
  }
}
