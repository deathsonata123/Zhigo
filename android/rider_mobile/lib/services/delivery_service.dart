import '../config/api_config.dart';
import '../models/order.dart';
import 'api_service.dart';

// NO AMPLIFY - Pure HTTP service calling Express.js backend
class DeliveryService {
  final ApiService _apiService = ApiService();

  Future<List<Order>> getMyDeliveries(String riderId) async {
    final response = await _apiService.get(
      '${ApiConfig.ordersEndpoint}?riderId=$riderId',
    );
    
    if (response is List) {
      return response.map((json) => Order.fromJson(json)).toList();
    }
    return [];
  }

  Future<Order> updateDeliveryStatus(String orderId, String status) async {
    final response = await _apiService.put(
      '${ApiConfig.ordersEndpoint}/$orderId',
      {'status': status},
    );
    return Order.fromJson(response);
  }

  Future<Map<String, dynamic>> getEarningsStats(String riderId, {String? period}) async {
    final periodParam = period != null ? '&period=$period' : '';
    final response = await _apiService.get(
      '/api/riders/$riderId/earnings$periodParam',
    );
    return response;
  }

  Future<Order> acceptDelivery(String orderId, String riderId) async {
    final response = await_apiService.put(
      '${ApiConfig.ordersEndpoint}/$orderId',
      {'rider_id': riderId, 'status': 'in_transit'},
    );
    return Order.fromJson(response);
  }
}
