import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/order_management_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderManagementService _service = OrderManagementService();
  
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  String? _restaurantId;
  Map<String, dynamic> _stats = {};

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get stats => _stats;

  List<Order> get pendingOrders => 
      _orders.where((o) => o.status == 'pending').toList();
  
  List<Order> get preparingOrders => 
      _orders.where((o) => o.status == 'preparing').toList();
  
  List<Order> get deliveredOrders => 
      _orders.where((o) => o.status == 'delivered').toList();

  void setRestaurantId(String id) {
    _restaurantId = id;
    fetchOrders();
    fetchStats();
  }

  Future<void> fetchOrders() async {
    if (_restaurantId == null) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _service.getRestaurantOrders(_restaurantId!);
      _orders.sort((a, b) => (b.createdAt ?? DateTime.now())
          .compareTo(a.createdAt ?? DateTime.now()));
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchStats({String? period}) async {
    if (_restaurantId == null) return;
    
    try {
      _stats = await _service.getOrderStats(_restaurantId!, period: period);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> updateStatus(String orderId, String status) async {
    try {
      final updated = await _service.updateOrderStatus(orderId, status);
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index >= 0) {
        _orders[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
