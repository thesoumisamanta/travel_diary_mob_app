import '../services/api_service.dart';
import '../models/user_model.dart';
import 'storage_repository.dart';

class AuthRepository {
  final ApiService _apiService;
  final StorageRepository _storageRepository;

  AuthRepository(this._apiService, this._storageRepository);

  Future<UserModel> login(String email, String password) async {
    final response = await _apiService.login(email, password);

    if (response.success && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(data['user']);
      final accessToken = data['access_token'] ?? data['accessToken'];
      final refreshToken = data['refresh_token'] ?? data['refreshToken'];

      await _storageRepository.saveAccessToken(accessToken);
      await _storageRepository.saveRefreshToken(refreshToken);
      await _storageRepository.saveUserId(user.id);

      _apiService.setAccessToken(accessToken);

      return user;
    } else {
      throw Exception(response.message ?? 'Login failed');
    }
  }

  Future<UserModel> register(Map<String, dynamic> data) async {
    final response = await _apiService.register(data);

    if (response.success && response.data != null) {
      final responseData = response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(responseData['user']);
      final accessToken =
          responseData['access_token'] ?? responseData['accessToken'];
      final refreshToken =
          responseData['refresh_token'] ?? responseData['refreshToken'];

      // Save tokens and user info
      await _storageRepository.saveAccessToken(accessToken);
      await _storageRepository.saveRefreshToken(refreshToken);
      await _storageRepository.saveUserId(user.id);

      // Set token in API service
      _apiService.setAccessToken(accessToken);

      return user;
    } else {
      throw Exception(response.message ?? 'Registration failed');
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      // Ignore API error and proceed with local logout
    } finally {
      // Clear only session data, keep remember-me data intact
      await _storageRepository.clearSessionOnly();
      _apiService.setAccessToken(null);
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await _storageRepository.getAccessToken();
    if (token != null) {
      _apiService.setAccessToken(token);
      return true;
    }
    return false;
  }

  Future<UserModel> getUserProfile() async {
    final response = await _apiService.getUserProfile();
    if (response.success && response.data != null) {
      final user = UserModel.fromJson(response.data as Map<String, dynamic>);
      return user;
    } else {
      throw Exception(response.message ?? 'Failed to fetch user profile');
    }
  }
}