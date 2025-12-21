import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/restaurant_service.dart';
import '../utils/constants.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filter orders by status
  List<Order> get pendingOrders => 
      _orders.where((o) => o.status == OrderStatus.pending).toList();
  
  List<Order> get activeOrders => 
      _orders.where((o) => [
        OrderStatus.accepted,
        OrderStatus.preparing,
        OrderStatus.ready,
      ].contains(o.status)).toList();
  
  List<Order> get completedOrders => 
      _orders.where((o) => o.status == OrderStatus.delivered).toList();
  
  List<Order> get cancelledOrders => 
      _orders.where((o) => [
        OrderStatus.rejected,
        OrderStatus.cancelled,
      ].contains(o.status)).toList();

  final RestaurantService _restaurantService = RestaurantService();

  // Load orders for restaurant
  Future<void> loadOrders(String restaurantId, {String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _restaurantService.getOrders(restaurantId, status: status);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Accept order
  Future<bool> acceptOrder(String orderId, int prepTime) async {
    try {
      final updatedOrder = await _restaurantService.acceptOrder(orderId, prepTime);
      _updateOrderInList(updatedOrder);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Reject order
  Future<bool> rejectOrder(String orderId, String reason) async {
    try {
      final updatedOrder = await _restaurantService.rejectOrder(orderId, reason);
      _updateOrderInList(updatedOrder);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Mark as preparing
  Future<bool> markPreparing(String orderId) async {
    try {
      final updatedOrder = await _restaurantService.markOrderPreparing(orderId);
      _updateOrderInList(updatedOrder);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Mark as ready
  Future<bool> markReady(String orderId) async {
    try {
      final updatedOrder = await _restaurantService.markOrderReady(orderId);
      _updateOrderInList(updatedOrder);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Helper to update order in list
  void _updateOrderInList(Order updatedOrder) {
    final index = _orders.indexWhere((o) => o.id == updatedOrder.id);
    if (index != -1) {
      _orders[index] = updatedOrder;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
