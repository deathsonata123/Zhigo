import 'package:flutter/foundation.dart';
import '../services/restaurant_service.dart';

class RestaurantProvider with ChangeNotifier {
  final RestaurantService _restaurantService = RestaurantService();
  
  List<Map<String, dynamic>> _restaurants = [];
  Map<String, dynamic>? _selectedRestaurant;
  List<Map<String, dynamic>> _menu = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get restaurants => _restaurants;
  Map<String, dynamic>? get selectedRestaurant => _selectedRestaurant;
  List<Map<String, dynamic>> get menu => _menu;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRestaurants() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _restaurants = await _restaurantService.getRestaurants();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRestaurantDetails(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedRestaurant = await _restaurantService.getRestaurantDetails(id);
      _menu = await _restaurantService.getRestaurantMenu(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedRestaurant() {
    _selectedRestaurant = null;
    _menu = [];
    notifyListeners();
  }
}
