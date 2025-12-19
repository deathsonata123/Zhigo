import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/delivery_service.dart';

class DeliveryProvider with ChangeNotifier {
  final DeliveryService _service = DeliveryService();
  
  List<Order> _deliveries = [];
  bool _isLoading = false;
  String? _error;
  String? _riderId;
  Map<String, dynamic> _earnings = {};

  List<Order> get deliveries => _deliveries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get earnings => _earnings;

  List<Order> get activeDeliveries => 
      _deliveries.where((d) => d.status == 'in_transit' || d.status == 'ready').toList();
  
  List<Order> get completedDeliveries => 
      _deliveries.where((d) => d.status == 'delivered').toList();

  void setRiderId(String id) {
    _riderId = id;
    fetchDeliveries();
    fetchEarnings();
  }

  Future<void> fetchDeliveries() async {
    if (_riderId == null) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _deliveries = await _service.getMyDeliveries(_riderId!);
      _deliveries.sort((a, b) => (b.createdAt ?? DateTime.now())
          .compareTo(a.createdAt ?? DateTime.now()));
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchEarnings({String? period}) async {
    if (_riderId == null) return;
    
    try {
      _earnings = await _service.getEarningsStats(_riderId!, period: period);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> updateStatus(String orderId, String status) async {
    try {
      final updated = await _service.updateDeliveryStatus(orderId, status);
      final index = _deliveries.indexWhere((d) => d.id == orderId);
      if (index >= 0) {
        _deliveries[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> acceptDelivery(String orderId) async {
    if (_riderId == null) return false;
    
    try {
      final updated = await _service.acceptDelivery(orderId, _riderId!);
      _deliveries.add(updated);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
