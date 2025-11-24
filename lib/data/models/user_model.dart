import 'post_model.dart';

enum AccountType { Personal, Business }

class UserModel {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String? profilePicture;
  final String? coverPicture;
  final String? bio;
  final String? website;
  final bool isVerified;
  final AccountType accountType;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final bool isFollowing;
  final bool isFollowingMe;
  final String? location;
  final DateTime createdAt;
  final List<PostModel> posts;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.profilePicture,
    this.coverPicture,
    this.bio,
    this.website,
    this.isVerified = false,
    required this.accountType,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.isFollowing = false,
    this.isFollowingMe = false,
    this.location,
    required this.createdAt,
    this.posts = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      profilePicture: json['avatar'],
      coverPicture: json['coverImage'],
      bio: json['bio'],
      location: json['location'],
      website: json['website'],
      isVerified: json['isVerified'] ?? json['is_verified'] ?? false,
      accountType: _parseAccountType(json['accountType']),
      // Safe integer parsing with default values
      followersCount: _parseInt(json['followersCount'], 0),
      followingCount: _parseInt(json['followingCount'], 0),
      postsCount: _parseInt(json['postsCount'], 0),
      // Safe boolean parsing with default values
      isFollowing: _parseBool(json['isFollowing'], false),
      isFollowingMe: _parseBool(json['isFollowingMe'], false),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      posts: json['posts'] != null
          ? (json['posts'] as List).map((p) => PostModel.fromJson(p)).toList()
          : [],
    );
  }

  // Helper method to safely parse integers
  static int _parseInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    if (value is double) return value.toInt();
    return defaultValue;
  }

  // Helper method to safely parse booleans
  static bool _parseBool(dynamic value, bool defaultValue) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value != 0;
    return defaultValue;
  }

  static AccountType _parseAccountType(dynamic value) {
    if (value == null) return AccountType.Personal;

    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'business' || lower == 'Business') {
        return AccountType.Business;
      }
    }
    return AccountType.Personal;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'profile_picture': profilePicture,
      'cover_picture': coverPicture,
      'bio': bio,
      'website': website,
      'is_verified': isVerified,
      'accountType': accountType == AccountType.Business ? 'Business' : 'Personal',
      'followers_count': followersCount,
      'following_count': followingCount,
      'posts_count': postsCount,
      'is_following': isFollowing,
      'created_at': createdAt.toIso8601String(),
      'posts': posts.map((p) => p.toJson()).toList(),
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? fullName,
    String? profilePicture,
    String? coverPicture,
    String? bio,
    String? website,
    bool? isVerified,
    AccountType? accountType,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    bool? isFollowing,
    bool? isFollowingMe,
    DateTime? createdAt,
    List<PostModel>? posts,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      profilePicture: profilePicture ?? this.profilePicture,
      coverPicture: coverPicture ?? this.coverPicture,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      isVerified: isVerified ?? this.isVerified,
      accountType: accountType ?? this.accountType,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      isFollowing: isFollowing ?? this.isFollowing,
      isFollowingMe: isFollowingMe ?? this.isFollowingMe,
      createdAt: createdAt ?? this.createdAt,
      posts: posts ?? this.posts,
    );
  }
}