import '../services/api_service.dart';
import '../models/user_model.dart';

class UserRepository {
  final ApiService _apiService;

  UserRepository(this._apiService);

  Future<UserModel> getUserProfile() async {
    try {
      final response = await _apiService.getUserProfile();


      if (response.success && response.data != null) {
        var userData = response.data;

        // Check if response.data has a nested 'data' field
        if (userData is Map<String, dynamic> && userData.containsKey('data')) {
          userData = userData['data'];
        }


        final user = UserModel.fromJson(userData as Map<String, dynamic>);
        return user;
      } else {
        throw Exception(response.message ?? 'Failed to load user profile');
      }
    } catch (e) {

      rethrow;
    }
  }

  Future<UserModel> getUserChannel(String username) async {
    final response = await _apiService.getUserChannel(username);

    if (response.success && response.data != null) {
      final userData = response.data as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } else {
      throw Exception(response.message ?? 'Failed to load user channel');
    }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _apiService.updateProfile(data);

    if (response.success && response.data != null) {
      return UserModel.fromJson(response.data);
    } else {
      throw Exception(response.message ?? 'Failed to update profile');
    }
  }

  Future<void> followUser(String userId) async {
    final response = await _apiService.followUser(userId);

    if (!response.success) {
      throw Exception(response.message ?? 'Failed to follow user');
    }
  }

  Future<void> unfollowUser(String userId) async {
    final response = await _apiService.unfollowUser(userId);

    if (!response.success) {
      throw Exception(response.message ?? 'Failed to unfollow user');
    }
  }

  Future<bool> checkFollowStatus(String userId) async {
    final response = await _apiService.checkFollowStatus(userId);

    if (response.success && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      return data['isFollowing'] ?? false;
    } else {
      return false;
    }
  }

  Future<List<UserModel>> getFollowers(String userId, int page) async {
    final response = await _apiService.getFollowers(userId, page);

    if (response.success && response.data != null) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => UserModel.fromJson(json)).toList();
    } else {
      throw Exception(response.message ?? 'Failed to load followers');
    }
  }

  Future<List<UserModel>> getFollowing(String userId, int page) async {
    final response = await _apiService.getFollowing(userId, page);

    if (response.success && response.data != null) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => UserModel.fromJson(json)).toList();
    } else {
      throw Exception(response.message ?? 'Failed to load following');
    }
  }

  Future<List<UserModel>> searchUsers(String query, int page) async {
    final response = await _apiService.searchUsers(query, page);

    if (response.success && response.data != null) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => UserModel.fromJson(json)).toList();
    } else {
      throw Exception(response.message ?? 'Failed to search users');
    }
  }
}
