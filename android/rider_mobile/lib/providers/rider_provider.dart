import 'package:flutter/material.dart';
import '../models/rider.dart';
import '../models/delivery_order.dart';
import '../services/auth_service.dart';
import '../services/rider_service.dart';

class RiderProvider with ChangeNotifier {
  Rider? _rider;
  DeliveryOrder? _currentOrder;
  List<DeliveryOrder> _orders = [];
  bool _isLoading = false;
  String? _error;

  Rider? get rider => _rider;
  DeliveryOrder? get currentOrder => _currentOrder;
  List<DeliveryOrder> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final AuthService _authService = AuthService();
  final RiderService _riderService = RiderService();

  // Load rider data
  Future<void> loadRiderData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = await _authService.getCurrentUserId();
      if (userId != null) {
        _rider = await _riderService.getRiderByUserId(userId);
        
        // Load current order if exists
        if (_rider!.currentOrderId != null) {
          final orders = await _riderService.getRiderOrders(_rider!.id);
          _currentOrder = orders.firstWhere(
            (o) => o.id == _rider!.currentOrderId,
            orElse: () => orders.first,
          );
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle online status
  Future<bool> toggleOnlineStatus(bool isOnline) async {
    if (_rider == null) return false;

    try {
      _rider = await _riderService.toggleOnlineStatus(_rider!.id, isOnline);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Load orders
  Future<void> loadOrders({String? status}) async {
    if (_rider == null) return;

    try {
      _orders = await _riderService.getRiderOrders(_rider!.id, status: status);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Accept delivery
  Future<bool> acceptDelivery(String orderId) async {
    if (_rider == null) return false;

    try {
      final order = await _riderService.acceptDelivery(orderId, _rider!.id);
      _currentOrder = order;
      
      // Update rider's current order
      await _riderService.updateRider(_rider!.id, {'current_order_id': orderId});
      await loadRiderData();
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update order status
  Future<bool> updateDeliveryStatus(String orderId, String status) async {
    try {
      DeliveryOrder updatedOrder;
      switch (status) {
        case 'at_restaurant':
          updatedOrder = await _riderService.markAtRestaurant(orderId);
          break;
        case 'picked_up':
          updatedOrder = await _riderService.confirmPickup(orderId);
          break;
        case 'delivering':
          updatedOrder = await _riderService.markDelivering(orderId);
          break;
        case 'delivered':
          updatedOrder = await _riderService.completeDelivery(orderId);
          
          // Clear rider's current order
          if (_rider != null) {
            await _riderService.updateRider(_rider!.id, {'current_order_id': null});
          }
          _currentOrder = null;
          break;
        default:
          updatedOrder = await _riderService.updateOrderStatus(orderId, status);
      }

      if (_currentOrder?.id == orderId) {
        _currentOrder = updatedOrder;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
