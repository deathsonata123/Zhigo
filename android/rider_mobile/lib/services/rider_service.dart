import '../models/rider.dart';
import '../models/delivery_order.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class RiderService {
  static final RiderService _instance = RiderService._internal();
  factory RiderService() => _instance;
  RiderService._internal();

  final ApiService _apiService = ApiService();

  // Get rider by user ID
  Future<Rider> getRiderByUserId(String userId) async {
    final response = await _apiService.get(
      ApiConstants.riders,
      queryParams: <String, String>{'userId': userId},
    );
    final List<dynamic> data = response['data'] ?? [];
    if (data.isEmpty) {
      throw NotFoundException('Rider profile not found');
    }
    return Rider.fromJson(data[0]);
  }

  // Update rider
  Future<Rider> updateRider(String id, Map<String, dynamic> updates) async {
    final response = await _apiService.put('${ApiConstants.riders}/$id', updates);
    return Rider.fromJson(response['data']);
  }

  // Toggle online status
  Future<Rider> toggleOnlineStatus(String riderId, bool isOnline) async {
    return updateRider(riderId, {'is_online': isOnline});
  }

  // Get rider's orders
  Future<List<DeliveryOrder>> getRiderOrders(String riderId, {String? status}) async {
    final queryParams = <String, String>{'riderId': riderId};
    if (status != null) {
      queryParams['status'] = status;
    }

    final response = await _apiService.get(ApiConstants.orders, queryParams: queryParams);
    final List<dynamic> data = response['data'] ?? [];
    return data.map((json) => DeliveryOrder.fromJson(json)).toList();
  }

  // Update order status
  Future<DeliveryOrder> updateOrderStatus(String orderId, String status, {Map<String, dynamic>? additionalData}) async {
    final body = <String, dynamic>{'status': status};
    if (additionalData != null) {
      body.addAll(additionalData);
    }

    final response = await _apiService.put('${ApiConstants.orders}/$orderId/status', body);
    return DeliveryOrder.fromJson(response['data']);
  }

  // Accept delivery
  Future<DeliveryOrder> acceptDelivery(String orderId, String riderId) async {
    final body = <String, dynamic>{
      'status': OrderStatus.assigned,
      'rider_id': riderId,
      'rider_assigned_at': DateTime.now().toIso8601String(),
    };

    final response = await _apiService.put('${ApiConstants.orders}/$orderId/status', body);
    return DeliveryOrder.fromJson(response['data']);
  }

  // Mark at restaurant
  Future<DeliveryOrder> markAtRestaurant(String orderId) async {
    return updateOrderStatus(orderId, OrderStatus.atRestaurant);
  }

  // Confirm pickup
  Future<DeliveryOrder> confirmPickup(String orderId) async {
    return updateOrderStatus(
      orderId,
      OrderStatus.pickedUp,
      additionalData: {'picked_up_at': DateTime.now().toIso8601String()},
    );
  }

  // Mark delivering
  Future<DeliveryOrder> markDelivering(String orderId) async {
    return updateOrderStatus(orderId, OrderStatus.delivering);
  }

  // Complete delivery
  Future<DeliveryOrder> completeDelivery(String orderId) async {
    return updateOrderStatus(
      orderId,
      OrderStatus.delivered,
      additionalData: {'delivered_at': DateTime.now().toIso8601String()},
    );
  }

  // Get earnings
  Future<Map<String, dynamic>> getEarnings(String riderId, {String period = 'week'}) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.riders}/$riderId/earnings',
        queryParams: <String, String>{'period': period},
      );
      return response['data'] ?? {};
    } catch (e) {
      // Return empty if endpoint doesn't exist
      return {};
    }
  }
}
