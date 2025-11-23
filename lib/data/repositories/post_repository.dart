import 'dart:io';
import '../services/api_service.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/story_model.dart';

class PostRepository {
  final ApiService _apiService;

  PostRepository(this._apiService);

  // Feed & Posts
  Future<List<PostModel>> getFeed(int page, {PostType? filterType}) async {
    try {
      final response = await _apiService.getPostFeed(
        page,
        type: filterType?.toApiString(),
      );

      if (response.success && response.data != null) {
        var feedData = response.data;

        if (feedData is Map<String, dynamic> && feedData.containsKey('data')) {
          feedData = feedData['data'];
        }

        if (feedData is List) {
          return feedData
              .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        return [];
      }
      throw Exception(response.message ?? 'Failed to load feed');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PostModel>> getUserPosts(
    String userId,
    int page, {
    PostType? filterType,
  }) async {
    final response = await _apiService.getUserPosts(
      userId,
      page,
      type: filterType?.toApiString(),
    );

    if (response.success && response.data != null) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => PostModel.fromJson(json)).toList();
    }
    throw Exception(response.message ?? 'Failed to load user posts');
  }

  Future<PostModel> getPostById(String postId) async {
    final response = await _apiService.getPostById(postId);

    if (response.success && response.data != null) {
      return PostModel.fromJson(response.data);
    }
    throw Exception(response.message ?? 'Failed to load post');
  }

  Future<PostModel> createPost(Map<String, dynamic> data) async {
    final response = await _apiService.createPost(data);

    if (response.success && response.data != null) {
      return PostModel.fromJson(response.data);
    }
    throw Exception(response.message ?? 'Failed to create post');
  }

  Future<Map<String, dynamic>> likePost(String postId) async {
    try {
      final response = await _apiService.likePost(postId);

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to like post');
      }

      if (response.data != null && response.data is Map<String, dynamic>) {
        return {
          'likesCount': response.data['likes'] ?? 0,
          'dislikesCount': response.data['dislikes'] ?? 0,
          'isLiked': response.data['isLiked'] ?? false,
          'isDisliked': response.data['isDisliked'] ?? false,
        };
      }

      return {
        'likesCount': 0,
        'dislikesCount': 0,
        'isLiked': false,
        'isDisliked': false,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> dislikePost(String postId) async {
    try {
      final response = await _apiService.dislikePost(postId);

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to dislike post');
      }

      if (response.data != null && response.data is Map<String, dynamic>) {
        return {
          'likesCount': response.data['likes'] ?? 0,
          'dislikesCount': response.data['dislikes'] ?? 0,
          'isLiked': response.data['isLiked'] ?? false,
          'isDisliked': response.data['isDisliked'] ?? false,
        };
      }

      return {
        'likesCount': 0,
        'dislikesCount': 0,
        'isLiked': false,
        'isDisliked': false,
      };
    } catch (e) {
      rethrow;
    }
  }

  // Search Posts
  Future<List<PostModel>> searchPosts(
    String query,
    int page, {
    PostType? filterType,
  }) async {
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

  // Get Shorts
  // Get Shorts
  Future<List<PostModel>> getShorts(int page) async {
    final response = await _apiService.getShorts(
      page,
    ); // Call getShorts, not searchShorts

    if (response.success && response.data != null) {
      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['data'] ?? []);
      return data.map((json) => PostModel.fromJson(json)).toList();
    }
    throw Exception(response.message ?? 'Failed to load shorts');
  }

  // Comments
  // Comments
  Future<List<CommentModel>> getPostComments(String postId, int page) async {
    final response = await _apiService.getPostComments(postId, page);

    if (response.success && response.data != null) {
      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['data'] ?? response.data);
      return data.map((json) => CommentModel.fromJson(json)).toList();
    }
    throw Exception(response.message ?? 'Failed to load comments');
  }

  Future<List<CommentModel>> getCommentReplies(
    String commentId,
    int page,
  ) async {
    final response = await _apiService.getCommentReplies(commentId, page);

    if (response.success && response.data != null) {
      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['data'] ?? response.data);
      return data.map((json) => CommentModel.fromJson(json)).toList();
    }
    throw Exception(response.message ?? 'Failed to load replies');
  }

  Future<CommentModel> addComment(
    String postId,
    String content, {
    String? parentId,
  }) async {
    final response = await _apiService.addComment(
      postId,
      content,
      parentId: parentId,
    );

    if (response.success && response.data != null) {
      final data = response.data is Map ? response.data : response.data['data'];
      return CommentModel.fromJson(data);
    }
    throw Exception(response.message ?? 'Failed to add comment');
  }

  Future<Map<String, dynamic>> likeComment(String commentId) async {
    final response = await _apiService.likeComment(commentId);

    if (response.success && response.data != null) {
      final data = response.data is Map ? response.data : response.data['data'];
      return {
        'likesCount': data['likes'] ?? 0,
        'dislikesCount': data['dislikes'] ?? 0,
        'isLiked': data['isLiked'] ?? false,
        'isDisliked': data['isDisliked'] ?? false,
      };
    }
    throw Exception(response.message ?? 'Failed to like comment');
  }

  Future<Map<String, dynamic>> dislikeComment(String commentId) async {
    final response = await _apiService.dislikeComment(commentId);

    if (response.success && response.data != null) {
      final data = response.data is Map ? response.data : response.data['data'];
      return {
        'likesCount': data['likes'] ?? 0,
        'dislikesCount': data['dislikes'] ?? 0,
        'isLiked': data['isLiked'] ?? false,
        'isDisliked': data['isDisliked'] ?? false,
      };
    }
    throw Exception(response.message ?? 'Failed to dislike comment');
  }

  Future<void> deleteComment(String commentId) async {
    final response = await _apiService.deleteComment(commentId);
    if (!response.success) {
      throw Exception(response.message ?? 'Failed to delete comment');
    }
  }

  // Stories
  Future<List<StoryGroupModel>> getStories() async {
    final response = await _apiService.getStories();

    if (response.success && response.data != null) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => StoryGroupModel.fromJson(json)).toList();
    }
    throw Exception(response.message ?? 'Failed to load stories');
  }

  Future<StoryModel> createStory(Map<String, dynamic> data) async {
    final response = await _apiService.createStory(data);

    if (response.success && response.data != null) {
      return StoryModel.fromJson(response.data);
    }
    throw Exception(response.message ?? 'Failed to create story');
  }

  Future<void> viewStory(String storyId) async {
    final response = await _apiService.viewStory(storyId);
    if (!response.success) {
      throw Exception(response.message ?? 'Failed to view story');
    }
  }

  // Media Upload
  Future<String> uploadMedia(File file) async {
    final response = await _apiService.uploadMedia(file);

    if (response.success && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      return data['url'] ?? '';
    }
    throw Exception(response.message ?? 'Failed to upload media');
  }

  Future<List<String>> uploadMultipleMedia(List<File> files) async {
    final response = await _apiService.uploadMultipleMedia(files);

    if (response.success && response.data != null) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((item) => item['url'] as String).toList();
    }
    throw Exception(response.message ?? 'Failed to upload media');
  }
}
