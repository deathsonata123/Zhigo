import '../models/restaurant.dart';
import '../models/order.dart';
import '../models/menu_item.dart';
import '../models/review.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class RestaurantService {
  static final RestaurantService _instance = RestaurantService._internal();
  factory RestaurantService() => _instance;
  RestaurantService._internal();

  final ApiService _apiService = ApiService();

  // Get all restaurants
  Future<List<Restaurant>> getRestaurants() async {
    final response = await _apiService.get(ApiConstants.restaurants);
    final List<dynamic> data = response['data'] ?? [];
    return data.map((json) => Restaurant.fromJson(json)).toList();
  }

  // Get restaurant by ID
  Future<Restaurant> getRestaurantById(String id) async {
    final response = await _apiService.get('${ApiConstants.restaurants}/$id');
    return Restaurant.fromJson(response['data']);
  }

  // Update restaurant
  Future<Restaurant> updateRestaurant(String id, Map<String, dynamic> updates) async {
    final response = await _apiService.put('${ApiConstants.restaurants}/$id', updates);
    return Restaurant.fromJson(response['data']);
  }

  // Get orders for restaurant
  Future<List<Order>> getOrders(String restaurantId, {String? status}) async {
    final queryParams = <String, String>{'restaurantId': restaurantId};
    if (status != null) {
      queryParams['status'] = status;
    }

    final response = await _apiService.get(ApiConstants.orders, queryParams: queryParams);
    final List<dynamic> data = response['data'] ?? [];
    return data.map((json) => Order.fromJson(json)).toList();
  }

  // Update order status
  Future<Order> updateOrderStatus(String orderId, String status, {Map<String, dynamic>? additionalData}) async {
    final body = <String, dynamic>{'status': status};
    if (additionalData != null) {
      body.addAll(additionalData);
    }

    final response = await _apiService.put('${ApiConstants.orders}/$orderId/status', body);
    return Order.fromJson(response['data']);
  }

  // Accept order
  Future<Order> acceptOrder(String orderId, int prepTime) async {
    return updateOrderStatus(
      orderId,
      OrderStatus.accepted,
      additionalData: {'prep_time': prepTime},
    );
  }

  // Reject order
  Future<Order> rejectOrder(String orderId, String reason) async {
    return updateOrderStatus(
      orderId,
      OrderStatus.rejected,
      additionalData: {'rejection_reason': reason},
    );
  }

  // Mark order as preparing
  Future<Order> markOrderPreparing(String orderId) async {
    return updateOrderStatus(orderId, OrderStatus.preparing);
  }

  // Mark order as ready
  Future<Order> markOrderReady(String orderId) async {
    return updateOrderStatus(orderId, OrderStatus.ready);
  }

  // Get menu items (Note: This may need a dedicated endpoint in backend)
  Future<List<MenuItem>> getMenuItems(String restaurantId) async {
    // For now, using restaurant endpoint - may need separate menu-items endpoint
    try {
      final response = await _apiService.get(
        '/api/menu-items',
        queryParams: <String, String>{'restaurantId': restaurantId},
      );
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => MenuItem.fromJson(json)).toList();
    } catch (e) {
      // If menu-items endpoint doesn't exist, return empty list for now
      return [];
    }
  }

  // Get reviews for restaurant
  Future<List<Review>> getReviews(String restaurantId) async {
    final response = await _apiService.get(
      ApiConstants.reviews,
      queryParams: <String, String>{'restaurantId': restaurantId},
    );
    final List<dynamic> data = response['data'] ?? [];
    return data.map((json) => Review.fromJson(json)).toList();
  }

  // Get riders (for assigning to orders)
  Future<List<Map<String,dynamic>>> getRiders({String status = 'approved'}) async {
    final response = await _apiService.get(
      ApiConstants.riders,
      queryParams: <String, String>{'status': status},
    );
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }
}
