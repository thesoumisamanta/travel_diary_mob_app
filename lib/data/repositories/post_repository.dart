import 'dart:io';
import '../services/api_service.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/story_model.dart';

class PostRepository {
  final ApiService _apiService;

  PostRepository(this._apiService);

  // Feed & Posts
  Future<List<PostModel>> getFeed(int page) async {
    try {
      print('🔄 Loading feed, page: $page');
      final response = await _apiService.getVideoFeed(page);

      print('Feed API Response - Success: ${response.success}');
      print('Feed API Response - Data: ${response.data}');

      if (response.success && response.data != null) {
        var feedData = response.data;

        // Check if response.data has a nested 'data' field (same issue as user profile)
        if (feedData is Map<String, dynamic> && feedData.containsKey('data')) {
          feedData = feedData['data'];
        }

        print('Feed data after extraction: $feedData');
        print('Feed data type: ${feedData.runtimeType}');

        if (feedData is List) {
          print('✅ Feed contains ${feedData.length} posts');
          final posts = feedData
              .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
              .toList();
          print('✅ Parsed ${posts.length} posts successfully');
          return posts;
        } else {
          return [];
        }
      } else {
        print('❌ Feed API failed: ${response.message}');
        throw Exception(response.message ?? 'Failed to load feed');
      }
    } catch (e, stackTrace) {
      print('❌ ERROR in getFeed: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<PostModel>> getUserPosts(String userId, int page) async {
    final response = await _apiService.getUserPosts(userId, page);

    if (response.success && response.data != null) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => PostModel.fromJson(json)).toList();
    } else {
      throw Exception(response.message ?? 'Failed to load user posts');
    }
  }

  Future<PostModel> getPostById(String postId) async {
    final response = await _apiService.getPostById(postId);

    if (response.success && response.data != null) {
      return PostModel.fromJson(response.data);
    } else {
      throw Exception(response.message ?? 'Failed to load post');
    }
  }

  Future<PostModel> createPost(Map<String, dynamic> data) async {
    final response = await _apiService.createPost(data);

    if (response.success && response.data != null) {
      return PostModel.fromJson(response.data);
    } else {
      throw Exception(response.message ?? 'Failed to create post');
    }
  }

  Future<PostModel> updatePost(String postId, Map<String, dynamic> data) async {
    final response = await _apiService.updatePost(postId, data);

    if (response.success && response.data != null) {
      return PostModel.fromJson(response.data);
    } else {
      throw Exception(response.message ?? 'Failed to update post');
    }
  }

  Future<void> deletePost(String postId) async {
    final response = await _apiService.deletePost(postId);

    if (!response.success) {
      throw Exception(response.message ?? 'Failed to delete post');
    }
  }

  Future<void> likePost(String postId) async {
    final response = await _apiService.likePost(postId);

    if (!response.success) {
      throw Exception(response.message ?? 'Failed to like post');
    }
  }

  Future<void> unlikePost(String postId) async {
    final response = await _apiService.unlikePost(postId);

    if (!response.success) {
      throw Exception(response.message ?? 'Failed to unlike post');
    }
  }

  // Comments
  Future<List<CommentModel>> getPostComments(String postId, int page) async {
    final response = await _apiService.getPostComments(postId, page);

    if (response.success && response.data != null) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => CommentModel.fromJson(json)).toList();
    } else {
      throw Exception(response.message ?? 'Failed to load comments');
    }
  }

  Future<CommentModel> addComment(String postId, String content) async {
    final response = await _apiService.addComment(postId, content);

    if (response.success && response.data != null) {
      return CommentModel.fromJson(response.data);
    } else {
      throw Exception(response.message ?? 'Failed to add comment');
    }
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
    } else {
      throw Exception(response.message ?? 'Failed to load stories');
    }
  }

  Future<StoryModel> createStory(Map<String, dynamic> data) async {
    final response = await _apiService.createStory(data);

    if (response.success && response.data != null) {
      return StoryModel.fromJson(response.data);
    } else {
      throw Exception(response.message ?? 'Failed to create story');
    }
  }

  Future<void> viewStory(String storyId) async {
    final response = await _apiService.viewStory(storyId);

    if (!response.success) {
      throw Exception(response.message ?? 'Failed to view story');
    }
  }

  // Search
  Future<List<PostModel>> searchPosts(String query, int page) async {
    final response = await _apiService.searchPosts(query, page);

    if (response.success && response.data != null) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => PostModel.fromJson(json)).toList();
    } else {
      throw Exception(response.message ?? 'Failed to search posts');
    }
  }

  // Media Upload
  Future<String> uploadMedia(File file) async {
    final response = await _apiService.uploadMedia(file);

    if (response.success && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      return data['url'] ?? '';
    } else {
      throw Exception(response.message ?? 'Failed to upload media');
    }
  }

  Future<List<String>> uploadMultipleMedia(List<File> files) async {
    final response = await _apiService.uploadMultipleMedia(files);

    if (response.success && response.data != null) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((item) => item['url'] as String).toList();
    } else {
      throw Exception(response.message ?? 'Failed to upload media');
    }
  }
}
