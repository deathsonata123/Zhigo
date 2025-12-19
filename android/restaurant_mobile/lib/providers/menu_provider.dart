import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/menu_service.dart';

class MenuProvider with ChangeNotifier {
  final MenuService _service = MenuService();
  
  List<MenuItem> _menuItems = [];
  bool _isLoading = false;
  String? _error;
  String? _restaurantId;

  List<MenuItem> get menuItems => _menuItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Map<String, List<MenuItem>> get menuItemsByCategory {
    final Map<String, List<MenuItem>> grouped = {};
    for (var item in _menuItems) {
      final category = item.category ?? 'Other';
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(item);
    }
    return grouped;
  }

  void setRestaurantId(String id) {
    _restaurantId = id;
    fetchMenuItems();
  }

  Future<void> fetchMenuItems() async {
    if (_restaurantId == null) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _menuItems = await _service.getMyMenuItems(_restaurantId!);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addMenuItem(MenuItem item) async {
    try {
      final newItem = await _service.createMenuItem(item);
      _menuItems.add(newItem);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMenuItem(MenuItem item) async {
    try {
      final updated = await _service.updateMenuItem(item);
      final index = _menuItems.indexWhere((i) => i.id == updated.id);
      if (index >= 0) {
        _menuItems[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMenuItem(String id) async {
    try {
      await _service.deleteMenuItem(id);
      _menuItems.removeWhere((item) => item.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleAvailability(String id, bool available) async {
    try {
      await _service.toggleAvailability(id, available);
      final index = _menuItems.indexWhere((i) => i.id == id);
      if (index >= 0) {
        _menuItems[index] = MenuItem(
          id: _menuItems[index].id,
          restaurantId: _menuItems[index].restaurantId,
          name: _menuItems[index].name,
          description: _menuItems[index].description,
          price: _menuItems[index].price,
          category: _menuItems[index].category,
          imageUrl: _menuItems[index].imageUrl,
          available: available,
          createdAt: _menuItems[index].createdAt,
        );
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
