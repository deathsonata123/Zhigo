import '../config/api_config.dart';
import '../models/order.dart';
import 'api_service.dart';

class OrderManagementService {
  final ApiService _apiService = ApiService();

  Future<List<Order>> getRestaurantOrders(String restaurantId) async {
    final response = await _apiService.get(
      '${ApiConfig.ordersEndpoint}?restaurantId=$restaurantId',
    );
    
    if (response is List) {
      return response.map((json) => Order.fromJson(json)).toList();
    }
    return [];
  }

  Future<Order> updateOrderStatus(String orderId, String status) async {
    final response = await _apiService.put(
      '${ApiConfig.ordersEndpoint}/$orderId',
      {'status': status},
    );
    return Order.fromJson(response);
  }

  Future<Map<String, dynamic>> getOrderStats(String restaurantId, {String? period}) async {
    final periodParam = period != null ? '&period=$period' : '';
    final response = await _apiService.get(
      '${ApiConfig.ordersEndpoint}/stats?restaurantId=$restaurantId$periodParam',
    );
    return response;
  }
}
