import '../services/api_service.dart';
import '../models/user_model.dart';

class UserRepository {
  final ApiService _apiService;

  UserRepository(this._apiService);

  /// Get current user profile
  Future<UserModel> getUserProfile() async {
    final response = await _apiService.getUserProfile();

    if (response.success && response.data != null) {
      return UserModel.fromJson(response.data);
    }
    throw Exception(response.message ?? 'Failed to load user profile');
  }

  /// Get user channel by username
  Future<UserModel> getUserChannel(String username) async {
    final response = await _apiService.getUserChannel(username);

    if (response.success && response.data != null) {
      return UserModel.fromJson(response.data);
    }
    throw Exception(response.message ?? 'Failed to load user channel');
  }

  /// Update user profile
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _apiService.updateProfile(data);

    if (response.success && response.data != null) {
      return UserModel.fromJson(response.data);
    }
    throw Exception(response.message ?? 'Failed to update profile');
  }

  /// Follow a user
  Future<void> followUser(String userId) async {
    final response = await _apiService.followUser(userId);

    if (!response.success) {
      throw Exception(response.message ?? 'Failed to follow user');
    }
  }

  /// Unfollow a user
  Future<void> unfollowUser(String userId) async {
    final response = await _apiService.unfollowUser(userId);

    if (!response.success) {
      throw Exception(response.message ?? 'Failed to unfollow user');
    }
  }

  /// Get followers of a user
  Future<List<UserModel>> getFollowers(String userId, int page) async {
    final response = await _apiService.getFollowers(userId, page);

    if (response.success && response.data != null) {
      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['data'] ?? []);
      return data.map((json) => UserModel.fromJson(json)).toList();
    }
    throw Exception(response.message ?? 'Failed to load followers');
  }

  /// Get following of a user
  Future<List<UserModel>> getFollowing(String userId, int page) async {
    final response = await _apiService.getFollowing(userId, page);

    if (response.success && response.data != null) {
      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['data'] ?? []);
      return data.map((json) => UserModel.fromJson(json)).toList();
    }
    throw Exception(response.message ?? 'Failed to load following');
  }

  /// Check if current user follows target user
  Future<bool> checkFollowStatus(String userId) async {
    final response = await _apiService.checkFollowStatus(userId);

    if (response.success && response.data != null) {
      return response.data['isFollowing'] ?? false;
    }
    throw Exception(response.message ?? 'Failed to check follow status');
  }

  /// Search users by username or fullName
  Future<List<UserModel>> searchUsers(String query, int page) async {
    if (query.trim().isEmpty) return [];

    final response = await _apiService.searchUsers(query, page);

    if (response.success && response.data != null) {
      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['data'] ?? []);
      return data.map((json) => UserModel.fromJson(json)).toList();
    }
    throw Exception(response.message ?? 'Failed to search users');
  }
}