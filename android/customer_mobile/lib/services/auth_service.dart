import '../services/api_service.dart';
import '../config/api_config.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // Sign up
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.authSignup,
        data: {
          'email': email,
          'password': password,
          'name': name,
          'phone': phone,
          'role': 'customer',
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        
        // Save token if provided
        if (data.containsKey('token')) {
          await _apiService.saveAuthToken(data['token']);
        }
        
        return {
          'success': true,
          'data': data,
        };
      }
      
      return {
        'success': false,
        'message': 'Sign up failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Sign in
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.authLogin,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        
        // Save token
        if (data.containsKey('token')) {
          await _apiService.saveAuthToken(data['token']);
        }
        
        return {
          'success': true,
          'data': data,
        };
      }
      
      return {
        'success': false,
        'message': 'Invalid credentials',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _apiService.post(ApiConfig.authLogout);
    } catch (e) {
      // Ignore errors on logout
    } finally {
      await _apiService.clearAuthToken();
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _apiService.getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final response = await _apiService.get(ApiConfig.userProfile);
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
}
