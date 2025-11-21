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
      final response = await _apiService.getPostFeed(page);

      if (response.success && response.data != null) {
        var feedData = response.data;

        if (feedData is Map<String, dynamic> && feedData.containsKey('data')) {
          feedData = feedData['data'];
        }

        if (feedData is List) {
          final posts = feedData
              .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
              .toList();
          return posts;
        } else {
          return [];
        }
      } else {
        throw Exception(response.message ?? 'Failed to load feed');
      }
    } catch (e) {
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

  // Future<PostModel> updatePost(String postId, Map<String, dynamic> data) async {
  //   final response = await _apiService.updatePost(postId, data);

  //   if (response.success && response.data != null) {
  //     return PostModel.fromJson(response.data);
  //   } else {
  //     throw Exception(response.message ?? 'Failed to update post');
  //   }
  // }

  // Future<void> deletePost(String postId) async {
  //   final response = await _apiService.deletePost(postId);

  //   if (!response.success) {
  //     throw Exception(response.message ?? 'Failed to delete post');
  //   }
  // }

  Future<Map<String, dynamic>> likePost(String postId) async {
    try {
      final response = await _apiService.likePost(postId);

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to like post');
      }

      // ✅ Return the updated like/dislike state from backend
      // Backend returns: { likes, dislikes, isLiked, isDisliked }
      if (response.data != null && response.data is Map<String, dynamic>) {
        return {
          'likesCount': response.data['likes'] ?? 0,
          'dislikesCount': response.data['dislikes'] ?? 0,
          'isLiked': response.data['isLiked'] ?? false,
          'isDisliked': response.data['isDisliked'] ?? false,
        };
      }

      // Fallback
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

      // ✅ Return the updated like/dislike state from backend
      if (response.data != null && response.data is Map<String, dynamic>) {
        return {
          'likesCount': response.data['likes'] ?? 0,
          'dislikesCount': response.data['dislikes'] ?? 0,
          'isLiked': response.data['isLiked'] ?? false,
          'isDisliked': response.data['isDisliked'] ?? false,
        };
      }

      // Fallback
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
