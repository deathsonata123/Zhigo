import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    final response = await _apiService.post(
      '${ApiConfig.authEndpoint}/login',
      {'email': email, 'password': password},
      includeAuth: false,
    );

    if (response['accessToken'] != null) {
      await _apiService.saveToken(response['accessToken']);
    }

    return {
      'user': response['user'] != null ? User.fromJson(response['user']) : null,
      'token': response['accessToken'],
    };
  }

  Future<Map<String, dynamic>> signUp(String email, String password, String name) async {
    final response = await _apiService.post(
      '${ApiConfig.authEndpoint}/signup',
      {
        'email': email,
        'password': password,
        'name': name,
        'role': 'customer',
      },
      includeAuth: false,
    );

    if (response['accessToken'] != null) {
      await _apiService.saveToken(response['accessToken']);
    }

    return {
      'user': response['user'] != null ? User.fromJson(response['user']) : null,
      'token': response['accessToken'],
    };
  }

  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiService.get('${ApiConfig.authEndpoint}/me');
      return response != null ? User.fromJson(response) : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _apiService.removeToken();
  }

  Future<bool> isAuthenticated() async {
    final token = await _apiService.getToken();
    return token != null;
  }
}
