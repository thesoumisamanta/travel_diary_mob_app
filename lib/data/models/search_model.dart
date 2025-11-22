import 'user_model.dart';
import 'post_model.dart';

/// Enum for search result types
enum SearchResultType { user, post, all }

/// Model for unified search results
class SearchResultModel {
  final List<UserModel> users;
  final List<PostModel> posts;
  final int page;
  final bool hasMore;

  SearchResultModel({
    this.users = const [],
    this.posts = const [],
    this.page = 1,
    this.hasMore = false,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    // Handle nested data structure
    final data = json['data'] ?? json;

    List<UserModel> users = [];
    List<PostModel> posts = [];

    // Parse users
    if (data['users'] != null && data['users'] is List) {
      users = (data['users'] as List)
          .map((u) => UserModel.fromJson(u as Map<String, dynamic>))
          .toList();
    }

    // Parse posts
    if (data['posts'] != null && data['posts'] is List) {
      posts = (data['posts'] as List)
          .map((p) => PostModel.fromJson(p as Map<String, dynamic>))
          .toList();
    }

    return SearchResultModel(
      users: users,
      posts: posts,
      page: json['page'] ?? 1,
      hasMore: json['hasMore'] ?? false,
    );
  }

  /// Check if search results are empty
  bool get isEmpty => users.isEmpty && posts.isEmpty;

  /// Check if search results have any content
  bool get isNotEmpty => users.isNotEmpty || posts.isNotEmpty;

  /// Get total count of results
  int get totalCount => users.length + posts.length;

  /// Copy with method
  SearchResultModel copyWith({
    List<UserModel>? users,
    List<PostModel>? posts,
    int? page,
    bool? hasMore,
  }) {
    return SearchResultModel(
      users: users ?? this.users,
      posts: posts ?? this.posts,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Model for user search results only
class UserSearchResultModel {
  final List<UserModel> users;
  final int page;
  final bool hasMore;

  UserSearchResultModel({
    this.users = const [],
    this.page = 1,
    this.hasMore = false,
  });

  factory UserSearchResultModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    List<UserModel> users = [];
    if (data is List) {
      users = data
          .map((u) => UserModel.fromJson(u as Map<String, dynamic>))
          .toList();
    }

    return UserSearchResultModel(
      users: users,
      page: json['page'] ?? 1,
      hasMore: json['hasMore'] ?? false,
    );
  }

  bool get isEmpty => users.isEmpty;
  bool get isNotEmpty => users.isNotEmpty;
}

/// Model for post search results only
class PostSearchResultModel {
  final List<PostModel> posts;
  final int page;
  final bool hasMore;

  PostSearchResultModel({
    this.posts = const [],
    this.page = 1,
    this.hasMore = false,
  });

  factory PostSearchResultModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    List<PostModel> posts = [];
    if (data is List) {
      posts = data
          .map((p) => PostModel.fromJson(p as Map<String, dynamic>))
          .toList();
    }

    return PostSearchResultModel(
      posts: posts,
      page: json['page'] ?? 1,
      hasMore: json['hasMore'] ?? false,
    );
  }

  bool get isEmpty => posts.isEmpty;
  bool get isNotEmpty => posts.isNotEmpty;

  /// Get posts filtered by type
  List<PostModel> getByType(PostType type) {
    return posts.where((p) => p.type == type).toList();
  }

  /// Get only image posts
  List<PostModel> get imagePosts => getByType(PostType.image);

  /// Get only video posts
  List<PostModel> get videoPosts => getByType(PostType.video);

  /// Get only short posts
  List<PostModel> get shortPosts => getByType(PostType.short);
}