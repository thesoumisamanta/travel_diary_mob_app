import 'package:equatable/equatable.dart';
import 'user_model.dart';

enum StoryType { image, video }

class StoryModel extends Equatable {
  final String id;
  final UserModel author;
  final String mediaUrl;
  final String? thumbnailUrl;
  final StoryType type;
  final double? duration;
  final int viewsCount;
  final bool isViewed;
  final DateTime createdAt;
  final DateTime expiresAt;

  const StoryModel({
    required this.id,
    required this.author,
    required this.mediaUrl,
    this.thumbnailUrl,
    required this.type,
    this.duration,
    this.viewsCount = 0,
    this.isViewed = false,
    required this.createdAt,
    required this.expiresAt,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] ?? json['_id'] ?? '',
      author: UserModel.fromJson(json['author'] ?? {}),
      mediaUrl: json['media_url'] ?? json['mediaUrl'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? json['thumbnailUrl'],
      type: json['type'] == 'video' ? StoryType.video : StoryType.image,
      duration: json['duration']?.toDouble(),
      viewsCount: json['views_count'] ?? json['viewsCount'] ?? 0,
      isViewed: json['is_viewed'] ?? json['isViewed'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : json['expiresAt'] != null
              ? DateTime.parse(json['expiresAt'])
              : DateTime.now().add(const Duration(hours: 24)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author.toJson(),
      'media_url': mediaUrl,
      'thumbnail_url': thumbnailUrl,
      'type': type == StoryType.video ? 'video' : 'image',
      'duration': duration,
      'views_count': viewsCount,
      'is_viewed': isViewed,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  StoryModel copyWith({
    String? id,
    UserModel? author,
    String? mediaUrl,
    String? thumbnailUrl,
    StoryType? type,
    double? duration,
    int? viewsCount,
    bool? isViewed,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return StoryModel(
      id: id ?? this.id,
      author: author ?? this.author,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      viewsCount: viewsCount ?? this.viewsCount,
      isViewed: isViewed ?? this.isViewed,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        author,
        mediaUrl,
        thumbnailUrl,
        type,
        duration,
        viewsCount,
        isViewed,
        createdAt,
        expiresAt,
      ];
}

class StoryGroupModel extends Equatable {
  final UserModel user;
  final List<StoryModel> stories;
  final bool hasUnviewedStories;

  const StoryGroupModel({
    required this.user,
    required this.stories,
    required this.hasUnviewedStories,
  });

  factory StoryGroupModel.fromJson(Map<String, dynamic> json) {
    return StoryGroupModel(
      user: UserModel.fromJson(json['user'] ?? {}),
      stories: (json['stories'] as List<dynamic>?)
              ?.map((e) => StoryModel.fromJson(e))
              .toList() ??
          [],
      hasUnviewedStories:
          json['has_unviewed_stories'] ?? json['hasUnviewedStories'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'stories': stories.map((e) => e.toJson()).toList(),
      'has_unviewed_stories': hasUnviewedStories,
    };
  }

  @override
  List<Object?> get props => [user, stories, hasUnviewedStories];
}