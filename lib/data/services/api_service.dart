import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_response.dart';

class ApiService {
  final ApiClient _apiClient = ApiClient();

  void setAccessToken(String? token) {
    _apiClient.setAccessToken(token);
  }

  // Auth APIs
  Future<ApiResponse> login(String identifier, String password) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      data: {'identifier': identifier, 'password': password},
    );
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

  // User APIs
  Future<ApiResponse> getUserProfile() async {
    final response = await _apiClient.get(ApiConstants.userProfile);
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> updateProfile(Map<String, dynamic> data) async {
    final response = await _apiClient.put(
      ApiConstants.updateProfile,
      data: data,
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> followUser(String userId) async {
    final response = await _apiClient.post(
      '${ApiConstants.followUser}/$userId',
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> unfollowUser(String userId) async {
    final response = await _apiClient.post(
      '${ApiConstants.unfollowUser}/$userId',
    );
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

  // Post APIs
  Future<ApiResponse> getFeed(int page) async {
    final response = await _apiClient.get(
      ApiConstants.feed,
      queryParameters: {'page': page},
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> getUserPosts(String userId, int page) async {
    final response = await _apiClient.get(
      '${ApiConstants.posts}/user/$userId',
      queryParameters: {'page': page},
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> getPostById(String postId) async {
    final response = await _apiClient.get('${ApiConstants.posts}/$postId');
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> createPost(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiConstants.createPost, data: data);
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> updatePost(
    String postId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.put(
      '${ApiConstants.updatePost}/$postId',
      data: data,
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> deletePost(String postId) async {
    final response = await _apiClient.delete(
      '${ApiConstants.deletePost}/$postId',
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> likePost(String postId) async {
    final response = await _apiClient.post('${ApiConstants.likePost}/$postId');
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> unlikePost(String postId) async {
    final response = await _apiClient.post(
      '${ApiConstants.unlikePost}/$postId',
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> getPostComments(String postId, int page) async {
    final response = await _apiClient.get(
      '${ApiConstants.commentPost}/$postId',
      queryParameters: {'page': page},
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> addComment(String postId, String content) async {
    final response = await _apiClient.post(
      '${ApiConstants.commentPost}/$postId',
      data: {'content': content},
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> deleteComment(String commentId) async {
    final response = await _apiClient.delete(
      '${ApiConstants.commentPost}/$commentId',
    );
    return ApiResponse.fromJson(response.data, null);
  }

  // Story APIs
  Future<ApiResponse> getStories() async {
    final response = await _apiClient.get(ApiConstants.stories);
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> createStory(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiConstants.createStory,
      data: data,
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> viewStory(String storyId) async {
    final response = await _apiClient.post(
      '${ApiConstants.viewStory}/$storyId',
    );
    return ApiResponse.fromJson(response.data, null);
  }

  // Chat APIs
  Future<ApiResponse> getChats() async {
    final response = await _apiClient.get(ApiConstants.chats);
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> getChatHistory(String chatId, int page) async {
    final response = await _apiClient.get(
      '${ApiConstants.getChatHistory}/$chatId',
      queryParameters: {'page': page},
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> sendMessage(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiConstants.sendMessage,
      data: data,
    );
    return ApiResponse.fromJson(response.data, null);
  }

  // Search APIs
  Future<ApiResponse> searchUsers(String query, int page) async {
    final response = await _apiClient.get(
      ApiConstants.searchUsers,
      queryParameters: {'query': query, 'page': page},
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> searchPosts(String query, int page) async {
    final response = await _apiClient.get(
      ApiConstants.searchPosts,
      queryParameters: {'query': query, 'page': page},
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> searchContent(String query, int page) async {
    final response = await _apiClient.get(
      ApiConstants.searchContent,
      queryParameters: {'query': query, 'page': page},
    );
    return ApiResponse.fromJson(response.data, null);
  }

  // Media Upload
  Future<ApiResponse> uploadMedia(
    File file, {
    ProgressCallback? onProgress,
  }) async {
    final response = await _apiClient.uploadFile(
      ApiConstants.uploadMedia,
      file,
      onProgress: onProgress,
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> uploadMultipleMedia(
    List<File> files, {
    ProgressCallback? onProgress,
  }) async {
    final formData = FormData();
    for (var file in files) {
      formData.files.add(
        MapEntry('files', await MultipartFile.fromFile(file.path)),
      );
    }

    final response = await _apiClient.post(
      ApiConstants.uploadMedia,
      data: formData,
    );
    return ApiResponse.fromJson(response.data, null);
  }
}
