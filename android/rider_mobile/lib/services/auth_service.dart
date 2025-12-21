import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiService.post(
      '${ApiConstants.auth}/login',
      {
        'email': email,
        'password': password,
      },
    );

    if (response['success'] == true && response['token'] != null) {
      await _apiService.setAuthToken(response['token']);
      
      if (response['user'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.prefKeyUserId, response['user']['id']);
        
        if (response['user']['rider_id'] != null) {
          await prefs.setString(
            AppConstants.prefKeyRiderId,
            response['user']['rider_id'],
          );
        }
      }
    }

    return response;
  }

  Future<void> logout() async {
    await _apiService.clearAuthToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefKeyUserId);
    await prefs.remove(AppConstants.prefKeyRiderId);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.prefKeyAuthToken);
    return token != null && token.isNotEmpty;
  }

  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefKeyUserId);
  }

  Future<String?> getRiderId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefKeyRiderId);
  }
}
