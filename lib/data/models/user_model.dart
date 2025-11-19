import 'package:equatable/equatable.dart';

enum AccountType { personal, business }

class UserModel extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? fullName;
  final String? bio;
  final String? profilePicture;
  final String? coverPicture;
  final AccountType accountType;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final bool isFollowing;
  final bool isFollowingMe;
  final bool isVerified;
  final String? website;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.bio,
    this.profilePicture,
    this.coverPicture,
    required this.accountType,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.isFollowing = false,
    this.isFollowingMe = false,
    this.isVerified = false,
    this.website,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['fullName'],
      bio: json['bio'],
      profilePicture: json['profile_picture'] ?? json['profilePicture'],
      coverPicture: json['cover_picture'] ?? json['coverPicture'],
      accountType: json['account_type'] == 'business' ||
              json['accountType'] == 'business'
          ? AccountType.business
          : AccountType.personal,
      followersCount: json['followers_count'] ?? json['followersCount'] ?? 0,
      followingCount: json['following_count'] ?? json['followingCount'] ?? 0,
      postsCount: json['posts_count'] ?? json['postsCount'] ?? 0,
      isFollowing: json['is_following'] ?? json['isFollowing'] ?? false,
      isFollowingMe: json['is_following_me'] ?? json['isFollowingMe'] ?? false,
      isVerified: json['is_verified'] ?? json['isVerified'] ?? false,
      website: json['website'],
      location: json['location'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'bio': bio,
      'profile_picture': profilePicture,
      'cover_picture': coverPicture,
      'account_type': accountType == AccountType.business ? 'business' : 'personal',
      'followers_count': followersCount,
      'following_count': followingCount,
      'posts_count': postsCount,
      'is_following': isFollowing,
      'is_following_me': isFollowingMe,
      'is_verified': isVerified,
      'website': website,
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? fullName,
    String? bio,
    String? profilePicture,
    String? coverPicture,
    AccountType? accountType,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    bool? isFollowing,
    bool? isFollowingMe,
    bool? isVerified,
    String? website,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      bio: bio ?? this.bio,
      profilePicture: profilePicture ?? this.profilePicture,
      coverPicture: coverPicture ?? this.coverPicture,
      accountType: accountType ?? this.accountType,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      isFollowing: isFollowing ?? this.isFollowing,
      isFollowingMe: isFollowingMe ?? this.isFollowingMe,
      isVerified: isVerified ?? this.isVerified,
      website: website ?? this.website,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        fullName,
        bio,
        profilePicture,
        coverPicture,
        accountType,
        followersCount,
        followingCount,
        postsCount,
        isFollowing,
        isFollowingMe,
        isVerified,
        website,
        location,
        createdAt,
        updatedAt,
      ];
}