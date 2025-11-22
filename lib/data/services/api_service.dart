import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_response.dart';

class ApiService {
  final ApiClient _apiClient = ApiClient();

  void setAccessToken(String? token) => _apiClient.setAccessToken(token);
  void setRefreshToken(String? token) => _apiClient.setRefreshToken(token);

  void setupTokenCallbacks({
    required Future<String?> Function() getRefreshToken,
    required Future<void> Function(String accessToken, String refreshToken) onTokensRefreshed,
    required Future<void> Function() onRefreshFailed,
  }) {
    _apiClient.setTokenCallbacks(
      getRefreshToken: getRefreshToken,
      onTokensRefreshed: onTokensRefreshed,
      onRefreshFailed: onRefreshFailed,
    );
  }

  // ==================== AUTH APIs ====================
  Future<ApiResponse> login(String identifier, String password) async {
    final body = identifier.contains('@')
        ? {'email': identifier, 'password': password}
        : {'username': identifier, 'password': password};
    final response = await _apiClient.post(ApiConstants.login, data: body);
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> register(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiConstants.register, data: data);
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> logout() async {
    final response = await _apiClient.post(ApiConstants.logout);
    return ApiResponse.fromJson(response.data, null);
  }

  // ==================== USER APIs ====================
  Future<ApiResponse> getUserProfile() async {
    final response = await _apiClient.get(ApiConstants.userProfile);
    if (response.data != null && response.data is Map<String, dynamic>) {
      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse(
        success: responseData['success'] ?? false,
        data: responseData['data'],
        message: responseData['message'],
        statusCode: responseData['statusCode'],
      );
    }
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> getUserChannel(String username) async {
    final response = await _apiClient.get('${ApiConstants.getUserChannel}/$username');
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> updateProfile(Map<String, dynamic> data) async {
    final response = await _apiClient.put(ApiConstants.updateProfile, data: data);
    return ApiResponse.fromJson(response.data, null);
  }

  // ==================== FOLLOW APIs ====================
  Future<ApiResponse> followUser(String userId) async {
    final response = await _apiClient.post('${ApiConstants.followUser}/$userId');
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> unfollowUser(String userId) async {
    final response = await _apiClient.post('${ApiConstants.unfollowUser}/$userId');
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> getFollowers(String userId, int page) async {
    final response = await _apiClient.get(
      '${ApiConstants.followers}/$userId',
      queryParameters: {'page': page},
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> getFollowing(String userId, int page) async {
    final response = await _apiClient.get(
      '${ApiConstants.following}/$userId',
      queryParameters: {'page': page},
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> checkFollowStatus(String userId) async {
    final response = await _apiClient.get('${ApiConstants.followStatus}/$userId');
    return ApiResponse.fromJson(response.data, null);
  }

  // ==================== POST APIs ====================
  Future<ApiResponse> getPostFeed(int page, {String? type}) async {
    final queryParams = <String, dynamic>{'page': page};
    if (type != null) queryParams['type'] = type;

    final response = await _apiClient.get(ApiConstants.getFeed, queryParameters: queryParams);

    if (response.data is List) {
      return ApiResponse(success: true, data: response.data, message: 'Success', statusCode: response.statusCode);
    }
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> getUserPosts(String userId, int page, {String? type}) async {
    final queryParams = <String, dynamic>{'page': page};
    if (type != null) queryParams['type'] = type;

    final response = await _apiClient.get('${ApiConstants.allPosts}/$userId', queryParameters: queryParams);
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> getPostById(String postId) async {
    final response = await _apiClient.get('${ApiConstants.userPost}/$postId');
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> createPost(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiConstants.uploadPosts, data: data);
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> likePost(String postId) async {
    try {
      final response = await _apiClient.post('${ApiConstants.likePost}/$postId/like');
      final data = response.data;

      if (data != null && data is Map<String, dynamic>) {
        if (data.containsKey('isLiked') || data.containsKey('likes')) {
          return ApiResponse(success: true, data: data, message: 'Post liked successfully', statusCode: response.statusCode);
        }
        if (data.containsKey('success') && data['success'] == false) {
          return ApiResponse(success: false, message: data['message'] ?? 'Failed to like post', statusCode: response.statusCode);
        }
      }
      return ApiResponse(
        success: response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300,
        data: data,
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse> dislikePost(String postId) async {
    try {
      final response = await _apiClient.post('${ApiConstants.dislikePost}/$postId/dislike');
      final data = response.data;

      if (data != null && data is Map<String, dynamic>) {
        if (data.containsKey('isDisliked') || data.containsKey('dislikes')) {
          return ApiResponse(success: true, data: data, message: 'Post disliked successfully', statusCode: response.statusCode);
        }
        if (data.containsKey('success') && data['success'] == false) {
          return ApiResponse(success: false, message: data['message'] ?? 'Failed to dislike post', statusCode: response.statusCode);
        }
      }
      return ApiResponse(
        success: response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300,
        data: data,
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  // ==================== SEARCH APIs ====================
  Future<ApiResponse> searchUsers(String query, int page) async {
    final response = await _apiClient.get(
      ApiConstants.searchUsers,
      queryParameters: {'q': query, 'page': page},
    );
    return _parseSearchResponse(response);
  }

  Future<ApiResponse> searchPosts(String query, int page, {String? type}) async {
    final queryParams = <String, dynamic>{'q': query, 'page': page};
    if (type != null) queryParams['type'] = type;

    final response = await _apiClient.get(ApiConstants.searchPosts, queryParameters: queryParams);
    return _parseSearchResponse(response);
  }

  Future<ApiResponse> searchAll(String query, int page) async {
    final response = await _apiClient.get(
      ApiConstants.searchAll,
      queryParameters: {'q': query, 'page': page},
    );
    return _parseSearchResponse(response);
  }

  Future<ApiResponse> searchContent(String query, int page) async {
    final response = await _apiClient.get(
      ApiConstants.searchContent,
      queryParameters: {'q': query, 'page': page},
    );
    return _parseSearchResponse(response);
  }

  Future<ApiResponse> getShorts(int page) async {
    final response = await _apiClient.get(ApiConstants.getShorts, queryParameters: {'page': page});
    return _parseSearchResponse(response);
  }

  ApiResponse _parseSearchResponse(Response response) {
    final data = response.data;
    if (data != null && data is Map<String, dynamic>) {
      return ApiResponse(
        success: data['success'] ?? true,
        data: data['data'],
        message: data['message'],
        statusCode: response.statusCode,
      );
    }
    if (data is List) {
      return ApiResponse(success: true, data: data, statusCode: response.statusCode);
    }
    return ApiResponse.fromJson(data, null);
  }

  // ==================== COMMENT APIs ====================
  Future<ApiResponse> getPostComments(String postId, int page) async {
    final response = await _apiClient.get('${ApiConstants.commentPost}/$postId', queryParameters: {'page': page});
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> addComment(String postId, String content) async {
    final response = await _apiClient.post('${ApiConstants.commentPost}/$postId', data: {'content': content});
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> deleteComment(String commentId) async {
    final response = await _apiClient.delete('${ApiConstants.commentPost}/$commentId');
    return ApiResponse.fromJson(response.data, null);
  }

  // ==================== STORY APIs ====================
  Future<ApiResponse> getStories() async {
    final response = await _apiClient.get(ApiConstants.stories);
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> createStory(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiConstants.createStory, data: data);
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> viewStory(String storyId) async {
    final response = await _apiClient.post('${ApiConstants.viewStory}/$storyId');
    return ApiResponse.fromJson(response.data, null);
  }

  // ==================== CHAT APIs ====================
  Future<ApiResponse> getChats() async {
    final response = await _apiClient.get(ApiConstants.chats);
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> getChatHistory(String chatId, int page) async {
    final response = await _apiClient.get('${ApiConstants.getChatHistory}/$chatId', queryParameters: {'page': page});
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> sendMessage(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiConstants.sendMessage, data: data);
    return ApiResponse.fromJson(response.data, null);
  }

  // ==================== MEDIA UPLOAD ====================
  Future<ApiResponse> uploadMedia(File file, {ProgressCallback? onProgress}) async {
    final response = await _apiClient.uploadFile(ApiConstants.uploadMedia, file, onProgress: onProgress);
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> uploadMultipleMedia(List<File> files, {ProgressCallback? onProgress}) async {
    final formData = FormData();
    for (var file in files) {
      formData.files.add(MapEntry('files', await MultipartFile.fromFile(file.path)));
    }
    final response = await _apiClient.post(ApiConstants.uploadMedia, data: formData);
    return ApiResponse.fromJson(response.data, null);
  }
}