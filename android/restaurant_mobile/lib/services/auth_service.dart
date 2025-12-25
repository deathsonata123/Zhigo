import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiService.post(
      '${ApiConstants.auth}/login',
      {
        'email': email,
        'password': password,
      },
    );

    // Handle nested response: { success: true, data: { token, user } }
    final data = response['data'] ?? response;
    final token = data['token'] ?? response['token'];
    final user = data['user'] ?? response['user'];

    if (response['success'] == true && token != null) {
      await _apiService.setAuthToken(token);
      
      // Save user data
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        
        // Save user ID
        final userId = user['id']?.toString() ?? '';
        if (userId.isNotEmpty) {
          await prefs.setString(AppConstants.prefKeyUserId, userId);
        }
        
        // Save full user data as JSON
        await prefs.setString(AppConstants.prefKeyUserData, jsonEncode(user));
        
        // Save restaurant ID if user is a restaurant owner/partner
        final restaurantId = user['restaurant_id']?.toString();
        if (restaurantId != null && restaurantId.isNotEmpty) {
          await prefs.setString(AppConstants.prefKeyRestaurantId, restaurantId);
        }
        
        // Check if user has partner role
        final role = user['role']?.toString();
        if (role != 'partner' && restaurantId == null) {
          throw ApiException('No restaurant associated with this account');
        }
      }
    } else {
      throw ApiException(response['error'] ?? 'Login failed');
    }

    return response;
  }

  // Logout
  Future<void> logout() async {
    await _apiService.clearAuthToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefKeyUserId);
    await prefs.remove(AppConstants.prefKeyRestaurantId);
    await prefs.remove(AppConstants.prefKeyUserData);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.prefKeyAuthToken);
    return token != null && token.isNotEmpty;
  }

  // Get current user ID
  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefKeyUserId);
  }

  // Get current restaurant ID
  Future<String?> getRestaurantId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefKeyRestaurantId);
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(AppConstants.prefKeyUserData);
    if (userData != null) {
      return jsonDecode(userData) as Map<String, dynamic>;
    }
    return null;
  }
}
