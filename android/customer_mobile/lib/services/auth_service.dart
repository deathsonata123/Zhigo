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
      // DEBUG: Print the signup URL
      print('🔍 DEBUG: Signup URL = ${ApiConfig.authSignup}');
      print('🔍 DEBUG: Base URL = ${ApiConfig.baseUrl}');
      print('🔍 DEBUG: Full payload = {email: $email, password: ***, fullName: $name, phone: $phone, role: customer}');
      
      final response = await _apiService.post(
        ApiConfig.authSignup,
        data: {
          'email': email,
          'password': password,
          'fullName': name,
          'phone': phone,
          'role': 'customer',
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        
        // Handle new backend response format: {success: true, data: {token, user}}
        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'] as Map<String, dynamic>;
          
          // Save token if provided
          if (data['token'] != null) {
            await _apiService.saveAuthToken(data['token']);
          }
          
          return {
            'success': true,
            'data': data, // Return the whole data object (contains token and user)
          };
        }
        
        // Fallback for old response format
        return {
          'success': true,
          'data': responseData,
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
        final responseData = response.data as Map<String, dynamic>;
        
        // Backend returns: { success: true, data: { token, user } }
        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'] as Map<String, dynamic>;
          
          // Save token from data.token
          if (data['token'] != null) {
            await _apiService.saveAuthToken(data['token']);
          }
          
          return {
            'success': true,
            'data': data, // Contains both token and user
          };
        }
        
        return {
          'success': false,
          'message': responseData['error'] ?? 'Login failed',
        };
      }
      
      return {
        'success': false,
        'message': 'Invalid credentials',
      };
    } catch (e) {
      print('🔴 Sign in error: $e');
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
