import '../services/api_service.dart';
import '../models/user_model.dart';
import 'storage_repository.dart';

class AuthRepository {
  final ApiService _apiService;
  final StorageRepository _storageRepository;

  AuthRepository(this._apiService, this._storageRepository) {
    _setupTokenRefresh();
  }

  void _setupTokenRefresh() {
    _apiService.setupTokenCallbacks(
      getRefreshToken: () async {
        return await _storageRepository.getRefreshToken();
      },
      onTokensRefreshed: (accessToken, refreshToken) async {
        await _storageRepository.saveAccessToken(accessToken);
        await _storageRepository.saveRefreshToken(refreshToken);
        _apiService.setAccessToken(accessToken);
        _apiService.setRefreshToken(refreshToken);
      },
      onRefreshFailed: () async {
        await _storageRepository.clearSessionOnly();
        _apiService.setAccessToken(null);
        _apiService.setRefreshToken(null);
      },
    );
  }

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
      _apiService.setRefreshToken(refreshToken);

      return user;
    } else {
      throw Exception(response.message ?? 'Login failed');
    }
  }

  Future<UserModel> register(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.register(data);

      print('Register response: ${response.toString()}');
      print('Register response.data: ${response.data}');
      print('Register response.success: ${response.success}');

      if (response.success && response.data != null) {
        final responseData = response.data;
        
        // Handle different response structures
        Map<String, dynamic>? userData;
        String? accessToken;
        String? refreshToken;

        // Case 1: response.data is the user object directly
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('user')) {
            // Case 2: response.data has a 'user' field
            userData = responseData['user'] as Map<String, dynamic>?;
            accessToken = responseData['access_token'] ?? 
                         responseData['accessToken'];
            refreshToken = responseData['refresh_token'] ?? 
                          responseData['refreshToken'];
          } else if (responseData.containsKey('data')) {
            // Case 3: response.data has a nested 'data' field
            final nestedData = responseData['data'] as Map<String, dynamic>?;
            if (nestedData != null) {
              userData = nestedData['user'] as Map<String, dynamic>?;
              accessToken = nestedData['access_token'] ?? 
                           nestedData['accessToken'] ??
                           responseData['access_token'] ?? 
                           responseData['accessToken'];
              refreshToken = nestedData['refresh_token'] ?? 
                            nestedData['refreshToken'] ??
                            responseData['refresh_token'] ?? 
                            responseData['refreshToken'];
            }
          } else if (responseData.containsKey('_id') || 
                     responseData.containsKey('username')) {
            // Case 4: response.data IS the user object
            userData = responseData;
            // Tokens might be at root level or missing
            accessToken = responseData['access_token'] ?? 
                         responseData['accessToken'];
            refreshToken = responseData['refresh_token'] ?? 
                          responseData['refreshToken'];
          }
        }

        if (userData == null) {
          print('Failed to extract user data from response');
          throw Exception('Invalid response format: user data not found');
        }

        print('Extracted userData: $userData');

        // Parse user with error handling
        UserModel user;
        try {
          user = UserModel.fromJson(userData);
        } catch (e) {
          print('Error parsing UserModel: $e');
          print('Problematic userData: $userData');
          rethrow;
        }

        // Save tokens if available
        if (accessToken != null && refreshToken != null) {
          await _storageRepository.saveAccessToken(accessToken);
          await _storageRepository.saveRefreshToken(refreshToken);
          await _storageRepository.saveUserId(user.id);

          _apiService.setAccessToken(accessToken);
          _apiService.setRefreshToken(refreshToken);
          
          print('Registration successful with tokens');
        } else {
          print('Warning: Tokens not found in registration response');
          // Registration successful but no tokens - user needs to login
          // Don't throw error, just return the user
        }

        return user;
      } else {
        throw Exception(response.message ?? 'Registration failed');
      }
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      // Ignore API error and proceed with local logout
    } finally {
      await _storageRepository.clearSessionOnly();
      _apiService.setAccessToken(null);
      _apiService.setRefreshToken(null);
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await _storageRepository.getAccessToken();
    final refreshToken = await _storageRepository.getRefreshToken();
    
    if (token != null) {
      _apiService.setAccessToken(token);
      _apiService.setRefreshToken(refreshToken);
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