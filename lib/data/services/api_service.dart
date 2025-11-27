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
    required Future<void> Function(String accessToken, String refreshToken)
    onTokensRefreshed,
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
    try {
      final response = await _apiClient.post(ApiConstants.register, data: data);
      print('Raw register response: ${response.data}');

      // Return the response as-is for better debugging
      if (response.data is Map<String, dynamic>) {
        return ApiResponse.fromJson(response.data, null);
      } else {
        return ApiResponse(
          success: true,
          data: response.data,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('Register API error: $e');
      rethrow;
    }
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
    final response = await _apiClient.get(
      '${ApiConstants.getUserChannel}/$username',
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> updateProfile(Map<String, dynamic> data) async {
    final response = await _apiClient.put(
      ApiConstants.updateProfile,
      data: data,
    );
    return ApiResponse.fromJson(response.data, null);
  }

  // ==================== FOLLOW APIs ====================
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

  Future<ApiResponse> checkFollowStatus(String userId) async {
    final response = await _apiClient.get(
      '${ApiConstants.followStatus}/$userId',
    );
    return ApiResponse.fromJson(response.data, null);
  }

  // ==================== POST APIs ====================
  Future<ApiResponse> getPostFeed(int page, {String? type}) async {
    final queryParams = <String, dynamic>{'page': page};
    if (type != null) queryParams['type'] = type;

    final response = await _apiClient.get(
      ApiConstants.getFeed,
      queryParameters: queryParams,
    );

    if (response.data is List) {
      return ApiResponse(
        success: true,
        data: response.data,
        message: 'Success',
        statusCode: response.statusCode,
      );
    }
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> getUserPosts(
  String userId,
  int page, {
  String? type,
}) async {
  final queryParams = <String, dynamic>{'page': page};
  if (type != null) queryParams['type'] = type;

  print('API_SERVICE: Calling getUserPosts endpoint');
  print('   Endpoint: ${ApiConstants.allPosts}/$userId');
  print('   Query params: $queryParams');

  try {
    final response = await _apiClient.get(
      '${ApiConstants.allPosts}/$userId',
      queryParameters: queryParams,
    );

    print('API_SERVICE: Response received');
    print('   Status code: ${response.statusCode}');
    print('   Response data type: ${response.data.runtimeType}');
    print('   Response data: ${response.data}');

    // Handle direct array response
    if (response.data is List) {
      return ApiResponse(
        success: true,
        data: response.data,
        message: 'Success',
        statusCode: response.statusCode,
      );
    }

    // Handle wrapped response
    return ApiResponse.fromJson(response.data, null);
  } catch (e, stackTrace) {
    print('API_SERVICE: Error in getUserPosts');
    print('   Error: $e');
    print('   Stack trace: $stackTrace');
    rethrow;
  }
}

  Future<ApiResponse> getPostById(String postId) async {
    final response = await _apiClient.get('${ApiConstants.userPost}/$postId');
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> createPost(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiConstants.uploadPosts,
      data: data,
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> likePost(String postId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.likePost}/$postId/like',
      );
      final data = response.data;

      if (data != null && data is Map<String, dynamic>) {
        if (data.containsKey('isLiked') || data.containsKey('likes')) {
          return ApiResponse(
            success: true,
            data: data,
            message: 'Post liked successfully',
            statusCode: response.statusCode,
          );
        }
        if (data.containsKey('success') && data['success'] == false) {
          return ApiResponse(
            success: false,
            message: data['message'] ?? 'Failed to like post',
            statusCode: response.statusCode,
          );
        }
      }
      return ApiResponse(
        success:
            response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! < 300,
        data: data,
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse> dislikePost(String postId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.dislikePost}/$postId/dislike',
      );
      final data = response.data;

      if (data != null && data is Map<String, dynamic>) {
        if (data.containsKey('isDisliked') || data.containsKey('dislikes')) {
          return ApiResponse(
            success: true,
            data: data,
            message: 'Post disliked successfully',
            statusCode: response.statusCode,
          );
        }
        if (data.containsKey('success') && data['success'] == false) {
          return ApiResponse(
            success: false,
            message: data['message'] ?? 'Failed to dislike post',
            statusCode: response.statusCode,
          );
        }
      }
      return ApiResponse(
        success:
            response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! < 300,
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

  Future<ApiResponse> searchPosts(
    String query,
    int page, {
    String? type,
  }) async {
    final queryParams = <String, dynamic>{'q': query, 'page': page};
    if (type != null) queryParams['type'] = type;

    final response = await _apiClient.get(
      ApiConstants.searchPosts,
      queryParameters: queryParams,
    );
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
    final response = await _apiClient.get(
      ApiConstants.getShorts,
      queryParameters: {
        'page': page,
        'type': 'short', // Filter by short type
      },
    );
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
      return ApiResponse(
        success: true,
        data: data,
        statusCode: response.statusCode,
      );
    }
    return ApiResponse.fromJson(data, null);
  }

  // ==================== COMMENT APIs ====================
  // ==================== COMMENT APIs ====================
  Future<ApiResponse> getPostComments(String postId, int page) async {
    final response = await _apiClient.get(
      '${ApiConstants.commentPost}/$postId',
      queryParameters: {'page': page, 'limit': 20},
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> getCommentReplies(String commentId, int page) async {
    final response = await _apiClient.get(
      '${ApiConstants.commentPost}/$commentId/replies',
      queryParameters: {'page': page, 'limit': 10},
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> addComment(
    String postId,
    String content, {
    String? parentId,
  }) async {
    final data = {
      'content': content,
      if (parentId != null) 'parentId': parentId,
    };

    final response = await _apiClient.post(
      '${ApiConstants.commentPost}/$postId',
      data: data,
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> likeComment(String commentId) async {
    final response = await _apiClient.post(
      '${ApiConstants.commentPost}/$commentId/like',
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> dislikeComment(String commentId) async {
    final response = await _apiClient.post(
      '${ApiConstants.commentPost}/$commentId/dislike',
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> updateComment(String commentId, String content) async {
    final response = await _apiClient.put(
      '${ApiConstants.commentPost}/$commentId',
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

  // ==================== STORY APIs ====================
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

  // ==================== CHAT APIs ====================
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

  // ==================== MEDIA UPLOAD ====================
  Future<ApiResponse> uploadSingleMedia(
    File file,
    String fieldName, {
    ProgressCallback? onProgress,
  }) async {
    final formData = FormData();
    formData.files.add(
      MapEntry(
        fieldName,
        await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      ),
    );

    final response = await _apiClient.post(
      ApiConstants.uploadPosts,
      data: formData,
      onSendProgress: onProgress,
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> uploadMultipleImages(
    List<File> files, {
    ProgressCallback? onProgress,
  }) async {
    final formData = FormData();
    for (var file in files) {
      formData.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        ),
      );
    }

    final response = await _apiClient.post(
      ApiConstants.uploadPosts,
      data: formData,
      onSendProgress: onProgress,
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> uploadPostWithMedia({
    required List<File> mediaFiles,
    required String postType,
    String? title,
    String? description,
    List<String>? tags,
    ProgressCallback? onProgress,
  }) async {
    try {
      final formData = FormData();

      // Add media files based on post type
      if (postType == 'video' || postType == 'short') {
        // Single video file
        formData.files.add(
          MapEntry(
            postType, // 'video' or 'short'
            await MultipartFile.fromFile(
              mediaFiles.first.path,
              filename: mediaFiles.first.path.split('/').last,
            ),
          ),
        );
      } else if (postType == 'images') {
        // Multiple image files
        for (var file in mediaFiles) {
          formData.files.add(
            MapEntry(
              'images',
              await MultipartFile.fromFile(
                file.path,
                filename: file.path.split('/').last,
              ),
            ),
          );
        }
      }

      // Add form fields
      if (title != null && title.isNotEmpty) {
        formData.fields.add(MapEntry('title', title));
      }
      if (description != null && description.isNotEmpty) {
        formData.fields.add(MapEntry('description', description));
      }
      if (tags != null && tags.isNotEmpty) {
        formData.fields.add(MapEntry('tags', tags.join(',')));
      }
      formData.fields.add(MapEntry('postType', postType));

      final response = await _apiClient.post(
        ApiConstants.uploadPosts,
        data: formData,
        onSendProgress: onProgress,
      );

      // Handle the response - backend returns the post object directly
      final responseData = response.data;

      print('Upload response: $responseData');

      // Check if response is successful based on status code
      if (response.statusCode == 201 || response.statusCode == 200) {
        // Backend returns post object directly, not wrapped
        if (responseData is Map<String, dynamic>) {
          return ApiResponse(
            success: true,
            data: responseData,
            message: 'Post uploaded successfully',
            statusCode: response.statusCode,
          );
        }
      }

      // Handle wrapped response (if backend format changes)
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('success')) {
          return ApiResponse.fromJson(responseData, null);
        }
      }

      throw Exception('Invalid response format');
    } catch (e) {
      print('Upload error in api_service: $e');
      rethrow;
    }
  }
}
