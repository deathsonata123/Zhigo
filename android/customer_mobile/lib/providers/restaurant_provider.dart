import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../models/menu_item.dart';
import '../services/restaurant_service.dart';

class RestaurantProvider with ChangeNotifier {
  final RestaurantService _service = RestaurantService();
  
  List<Restaurant> _restaurants = [];
  List<MenuItem> _menuItems = [];
  Restaurant? _selectedRestaurant;
  bool _isLoading = false;
  String? _error;

  List<Restaurant> get restaurants => _restaurants;
  List<MenuItem> get menuItems => _menuItems;
  Restaurant? get selectedRestaurant => _selectedRestaurant;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize with dummy data
  RestaurantProvider() {
    _loadDummyData();
  }

  void _loadDummyData() {
    _restaurants = [
      Restaurant(
        id: '1',
        name: 'Pizza Palace',
        address: '123 Main St, Downtown',
        photoUrl: 'https://picsum.photos/seed/pizza/600/400',
        status: 'approved',
      ),
      Restaurant(
        id: '2',
        name: 'Burger King',
        address: '456 Oak Ave, Midtown',
        photoUrl: 'https://picsum.photos/seed/burger/600/400',
        status: 'approved',
      ),
      Restaurant(
        id: '3',
        name: 'Sushi Supreme',
        address: '789 Pine Rd, Uptown',
        photoUrl: 'https://picsum.photos/seed/sushi/600/400',
        status: 'approved',
      ),
      Restaurant(
        id: '4',
        name: 'Taco Fiesta',
        address: '321 Elm St, West End',
        photoUrl: 'https://picsum.photos/seed/taco/600/400',
        status: 'approved',
      ),
      Restaurant(
        id: '5',
        name: 'Curry House',
        address: '654 Maple Dr, East Side',
        photoUrl: 'https://picsum.photos/seed/curry/600/400',
        status: 'approved',
      ),
    ];

    _menuItems = [
      MenuItem(
        id: '1',
        restaurantId: '1',
        name: 'Margherita Pizza',
        description: 'Classic tomato, mozzarella, and basil',
        price: 12.99,
        category: 'Pizza',
        imageUrl: 'https://picsum.photos/seed/margherita/400/300',
        available: true,
      ),
      MenuItem(
        id: '2',
        restaurantId: '1',
        name: 'Pepperoni Pizza',
        description: 'Loaded with pepperoni and cheese',
        price: 14.99,
        category: 'Pizza',
        imageUrl: 'https://picsum.photos/seed/pepperoni/400/300',
        available: true,
      ),
      MenuItem(
        id: '3',
        restaurantId: '2',
        name: 'Classic Burger',
        description: 'Beef patty, lettuce, tomato, cheese',
        price: 9.99,
        category: 'Burgers',
        imageUrl: 'https://picsum.photos/seed/classicburger/400/300',
        available: true,
      ),
      MenuItem(
        id: '4',
        restaurantId: '3',
        name: 'California Roll',
        description: 'Crab, avocado, cucumber',
        price: 8.99,
        category: 'Sushi',
        imageUrl: 'https://picsum.photos/seed/caliroll/400/300',
        available: true,
      ),
    ];
    notifyListeners();
  }

  Future<void> fetchRestaurants() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try to fetch from backend
      _restaurants = await _service.getRestaurants();
      _error = null;
    } catch (e) {
      // If backend fails, keep dummy data
      _error = 'Using dummy data (backend: ${e.toString()})';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMenuItems(String restaurantId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try to fetch from backend
      _menuItems = await _service.getMenuItems(restaurantId);
      _error = null;
    } catch (e) {
      // If backend fails, filter dummy data
      _menuItems = _menuItems.where((m) => m.restaurantId == restaurantId).toList();
      _error = 'Using dummy menu data';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectRestaurant(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedRestaurant = await _service.getRestaurant(id);
      if (_selectedRestaurant != null) {
        await fetchMenuItems(id);
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  List<Restaurant> searchRestaurants(String query) {
    if (query.isEmpty) return _restaurants;
    return _restaurants
        .where((r) => r.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

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
}
