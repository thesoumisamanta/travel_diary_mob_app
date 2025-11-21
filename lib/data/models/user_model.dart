
import 'post_model.dart';

enum AccountType { personal, business }

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
      email: json['email'] ?? 'no-email@placeholder.com',
      fullName: json['fullName'] ?? json['full_name'] ?? '',
      profilePicture: json['avatar'] ?? json['profile_picture'],
      coverPicture: json['coverImage'] ?? json['cover_picture'],
      bio: json['bio'],
      location: json['location'],
      website: json['website'],
      isVerified: json['isVerified'] ?? json['is_verified'] ?? false,
      accountType: _parseAccountType(
        json['accountType'] ?? json['account_type'],
      ),
      followersCount: json['followersCount'] ?? json['followers_count'] ?? 0,
      followingCount: json['followingCount'] ?? json['following_count'] ?? 0,
      postsCount: json['postsCount'] ?? json['posts_count'] ?? 0,
      isFollowing: json['isFollowing'] ?? json['is_following'] ?? false,
      isFollowingMe: json['isFollowingMe'] ?? json['is_following_me'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      posts: json['posts'] != null
          ? (json['posts'] as List).map((p) => PostModel.fromJson(p)).toList()
          : [],
      
    );
  }

  static AccountType _parseAccountType(dynamic value) {
    if (value == null) return AccountType.personal;

    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'business' || lower == 'Business') {
        return AccountType.business;
      }
    }
    return AccountType.personal;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'profile_picture': profilePicture,
      'cover_picture': coverPicture,
      'bio': bio,
      'website': website,
      'is_verified': isVerified,
      'account_type': accountType == AccountType.business
          ? 'Business'
          : 'Personal',
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
      createdAt: createdAt ?? this.createdAt,
      posts: posts ?? this.posts,
    );
  }
}
