import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/menu_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  String? _restaurantId;
  String? _restaurantName;

  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _items.fold(0, (sum, item) => sum + item.total);
  double get deliveryFee => 2.99; // Could be dynamic
  double get total => subtotal + deliveryFee;
  String? get restaurantId => _restaurantId;
  String? get restaurantName => _restaurantName;

  void addItem(MenuItem menuItem, String restaurantId, String restaurantName) {
    // Clear cart if switching restaurants
    if (_restaurantId != null && _restaurantId != restaurantId) {
      clearCart();
    }

    _restaurantId = restaurantId;
    _restaurantName = restaurantName;

    // Check if item already in cart
    final existingIndex = _items.indexWhere((item) => item.menuItemId == menuItem.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(
        menuItemId: menuItem.id,
        name: menuItem.name,
        price: menuItem.price,
        imageUrl: menuItem.imageUrl,
      ));
    }

    notifyListeners();
  }

  void removeItem(String menuItemId) {
    _items.removeWhere((item) => item.menuItemId == menuItemId);
    if (_items.isEmpty) {
      _restaurantId = null;
      _restaurantName = null;
    }
    notifyListeners();
  }

  void updateQuantity(String menuItemId, int quantity) {
    final index = _items.indexWhere((item) => item.menuItemId == menuItemId);
    if (index >= 0) {
      if (quantity <= 0) {
        removeItem(menuItemId);
      } else {
        _items[index].quantity = quantity;
        notifyListeners();
      }
    }
  }

  void clearCart() {
    _items.clear();
    _restaurantId = null;
    _restaurantName = null;
    notifyListeners();
  }

  List<OrderItem> getOrderItems() {
    return _items.map((cartItem) => OrderItem(
      menuItemId: cartItem.menuItemId,
      name: cartItem.name,
      quantity: cartItem.quantity,
      price: cartItem.price,
    )).toList();
  }
}
