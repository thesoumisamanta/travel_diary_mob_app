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
    print('🔥🔥🔥 REPOSITORY: getUserPosts called');
    print('   userId: $userId');
    print('   page: $page');
    print('   filterType: $filterType');

    try {
      final response = await _apiService.getUserPosts(
        userId,
        page,
        type: filterType?.toApiString(),
      );

      print('   Response success: ${response.success}');
      print('   Response data type: ${response.data.runtimeType}');
      print('   Response data: ${response.data}'); // ✅ ADD THIS

      if (response.success && response.data != null) {
        // Handle both List and wrapped response
        final List<dynamic> data = response.data is List
            ? response.data as List<dynamic>
            : (response.data['data'] as List<dynamic>? ?? []);

        print('   Number of posts returned: ${data.length}');

        if (data.isEmpty) {
          print('   ⚠️ WARNING: API returned empty array');
          return [];
        }

        final posts = data.map((json) => PostModel.fromJson(json)).toList();
        print('   Posts parsed successfully: ${posts.length}');
        posts.forEach((post) {
          print(
            '      - Post: ${post.id}, type: ${post.type}, author: ${post.author.username}',
          );
        });

        return posts;
      }

      print('   ❌ ERROR: ${response.message}');
      throw Exception(response.message ?? 'Failed to load user posts');
    } catch (e, stackTrace) {
      print('   ❌ EXCEPTION in getUserPosts: $e');
      print('   Stack trace: $stackTrace');
      rethrow;
    }
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

  Future<PostModel> uploadPostWithMedia({
    required List<File> mediaFiles,
    required PostType postType,
    String? title,
    String? caption,
    String? location,
    List<String>? tags,
  }) async {
    try {
      final response = await _apiService.uploadPostWithMedia(
        mediaFiles: mediaFiles,
        postType: postType.toApiString(),
        title: title ?? 'Untitled Post',
        description: caption ?? title ?? 'Untitled Post',
        tags: tags,
        onProgress: (sent, total) {
          print('Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%');
        },
      );

      print(
        'Repository received response: ${response.success}, data: ${response.data}',
      );

      if (response.success && response.data != null) {
        // Parse the post from response
        try {
          final postData = response.data is Map<String, dynamic>
              ? response.data
              : (response.data['data'] ?? response.data);

          return PostModel.fromJson(postData);
        } catch (e) {
          print('Error parsing post model: $e');
          print('Response data: ${response.data}');
          rethrow;
        }
      }

      throw Exception(response.message ?? 'Failed to upload post');
    } catch (e) {
      print('Repository upload error: $e');
      rethrow;
    }
  }

  // Media Upload - Keep for backward compatibility
  Future<String> uploadMedia(File file) async {
    final response = await _apiService.uploadSingleMedia(
      file,
      'video', // Default field name
    );

    if (response.success && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      return data['url'] ?? data['videoUrl'] ?? '';
    }
    throw Exception(response.message ?? 'Failed to upload media');
  }

  Future<List<String>> uploadMultipleMedia(List<File> files) async {
    final response = await _apiService.uploadMultipleImages(files);

    if (response.success && response.data != null) {
      // Backend returns the post object with images array
      final data = response.data as Map<String, dynamic>;
      if (data['images'] != null && data['images'] is List) {
        return (data['images'] as List)
            .map((img) => img['url'] as String)
            .toList();
      }
      // Fallback for direct URL array response
      if (data is List) {
        return (data as List).map((item) => item['url'] as String).toList();
      }
    }
    throw Exception(response.message ?? 'Failed to upload media');
  }
}
