import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _user;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get user => _user;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    
    _isAuthenticated = await _authService.isAuthenticated();
    
    if (_isAuthenticated) {
      final response = await _authService.getUserProfile();
      // Handle potential nested data structure from backend
      if (response != null) {
        if (response.containsKey('data')) {
          _user = response['data'] as Map<String, dynamic>;
        } else {
          _user = response;
        }
      }
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.signIn(
        email: email,
        password: password,
      );

      print('🔍 SignIn result: $result');

      if (result['success'] == true) {
        _isAuthenticated = true;
        // Extract user from result.data.user
        final data = result['data'] as Map<String, dynamic>;
        _user = data['user'] ?? data;
        
        print('🔍 User data stored: $_user');
        print('🔍 fullName: ${_user?['fullName']}');
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );

      print('🔍 Signup result: $result');

      if (result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        
        // Token is already saved in AuthService
        
        // Set user data
        _isAuthenticated = true;
        // Correctly extract the user object which is inside result['data']['user']
        _user = data['user']; 
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? result['error'] ?? 'Sign up failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('🔴 Signup error: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }
}
