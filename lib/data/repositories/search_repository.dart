import '../services/api_service.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/search_model.dart';

class SearchRepository {
  final ApiService _apiService;

  SearchRepository(this._apiService);

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

  /// Search posts by title, description, or tags
  /// Optional filterType to filter by post type (video, images, short)
  Future<List<PostModel>> searchPosts(
    String query,
    int page, {
    PostType? filterType,
  }) async {
    if (query.trim().isEmpty) return [];

    final response = await _apiService.searchPosts(
      query,
      page,
      type: filterType?.toApiString(),
    );

    if (response.success && response.data != null) {
      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['data'] ?? []);
      return data.map((json) => PostModel.fromJson(json)).toList();
    }
    throw Exception(response.message ?? 'Failed to search posts');
  }

  /// Search all content (users + posts)
  Future<SearchResultModel> searchAll(String query, int page) async {
    if (query.trim().isEmpty) {
      return SearchResultModel();
    }

    final response = await _apiService.searchAll(query, page);

    if (response.success && response.data != null) {
      return SearchResultModel.fromJson({
        'data': response.data,
        'page': page,
        'hasMore': response.data is Map ? response.data['hasMore'] ?? false : false,
      });
    }
    throw Exception(response.message ?? 'Failed to search content');
  }

  /// Get only shorts
  Future<List<PostModel>> getShorts(int page) async {
    final response = await _apiService.getShorts(page);

    if (response.success && response.data != null) {
      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['data'] ?? []);
      return data.map((json) => PostModel.fromJson(json)).toList();
    }
    throw Exception(response.message ?? 'Failed to load shorts');
  }

  /// Search with specific post type filter
  Future<List<PostModel>> searchByPostType(
    String query,
    int page,
    PostType postType,
  ) async {
    return searchPosts(query, page, filterType: postType);
  }

  /// Get only video posts from search
  Future<List<PostModel>> searchVideos(String query, int page) async {
    return searchPosts(query, page, filterType: PostType.video);
  }

  /// Get only image posts from search
  Future<List<PostModel>> searchImages(String query, int page) async {
    return searchPosts(query, page, filterType: PostType.image);
  }

  /// Get only short posts from search
  Future<List<PostModel>> searchShorts(String query, int page) async {
    return searchPosts(query, page, filterType: PostType.short);
  }
}