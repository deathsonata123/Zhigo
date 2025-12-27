import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class RestaurantService {
  final ApiService _apiService = ApiService();

  // Get all restaurants
  Future<List<Map<String, dynamic>>> getRestaurants() async {
    try {
      debugPrint('🔄 Fetching restaurants from: ${ApiConfig.baseUrl}${ApiConfig.restaurants}');
      final response = await _apiService.get(ApiConfig.restaurants);
      
      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response data type: ${response.data.runtimeType}');
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // Handle nested response: { success: true, data: [...] }
        List<dynamic> restaurants;
        if (responseData is Map && responseData['data'] != null) {
          restaurants = responseData['data'] as List;
          debugPrint('📦 Found ${restaurants.length} restaurants in nested data');
        } else if (responseData is List) {
          restaurants = responseData;
          debugPrint('📦 Found ${restaurants.length} restaurants in list');
        } else {
          debugPrint('⚠️ Unknown response format: $responseData');
          return [];
        }
        
        // Show ALL restaurants for now (debug mode)
        // TODO: Filter by status == 'approved' for production
        debugPrint('✅ Returning ${restaurants.length} restaurants');
        for (var r in restaurants) {
          debugPrint('  - ${r['name']} (status: ${r['status']})');
        }
        
        return List<Map<String, dynamic>>.from(restaurants);
      }
      
      return [];
    } catch (e) {
      debugPrint('❌ Error fetching restaurants: $e');
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
