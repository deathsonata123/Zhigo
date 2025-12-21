import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../models/order.dart';
import '../services/auth_service.dart';
import '../services/restaurant_service.dart';

class RestaurantProvider with ChangeNotifier {
  Restaurant? _restaurant;
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  Restaurant? get restaurant => _restaurant;
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final AuthService _authService = AuthService();
  final RestaurantService _restaurantService = RestaurantService();

  // Load restaurant data
  Future<void> loadRestaurant() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final restaurantId = await _authService.getRestaurantId();
      if (restaurantId != null) {
        _restaurant = await _restaurantService.getRestaurantById(restaurantId);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load orders
  Future<void> loadOrders({String? status}) async {
    if (_restaurant == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _restaurantService.getOrders(_restaurant!.id, status: status);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadRestaurant(),
      loadOrders(),
    ]);
  }
}
