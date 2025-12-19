import '../config/api_config.dart';
import '../models/order.dart';
import 'api_service.dart';

class OrderService {
  final ApiService _apiService = ApiService();

  Future<Order> createOrder(Order order) async {
    final response = await _apiService.post(
      ApiConfig.ordersEndpoint,
      order.toJson(),
    );
    return Order.fromJson(response);
  }

  Future<List<Order>> getMyOrders() async {
    final response = await _apiService.get('${ApiConfig.ordersEndpoint}/my-orders');
    
    if (response is List) {
      return response.map((json) => Order.fromJson(json)).toList();
    }
    return [];
  }

  Future<Order?> getOrder(String id) async {
    final response = await _apiService.get('${ApiConfig.ordersEndpoint}/$id');
    return response != null ? Order.fromJson(response) : null;
  }
}
