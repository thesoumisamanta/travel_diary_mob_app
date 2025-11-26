import 'package:equatable/equatable.dart';
import 'user_model.dart';

enum PostType { image, video, short }

class MediaItem {
  final String url;
  final String? thumbnail;
  final PostType type;
  final double? duration;

  MediaItem({
    required this.url,
    this.thumbnail,
    required this.type,
    this.duration,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      url: json['url'] ?? '',
      thumbnail: json['thumbnail'],
      type: _getPostType(json['type']),
      duration: json['duration']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'thumbnail': thumbnail,
      'type': type.toApiString(),
      'duration': duration,
    };
  }

  static PostType _getPostType(String? type) {
    switch (type?.toLowerCase()) {
      case 'video':
        return PostType.video;
      case 'short':
        return PostType.short;
      case 'image':
      case 'images':
        return PostType.image;
      default:
        return PostType.image;
    }
  }
}

// Extension for PostType to easily convert to API string
extension PostTypeExtension on PostType {
  String toApiString() {
    switch (this) {
      case PostType.video:
        return 'video';
      case PostType.short:
        return 'short';
      case PostType.image:
        return 'images';
    }
  }

  String get displayName {
    switch (this) {
      case PostType.video:
        return 'Video';
      case PostType.short:
        return 'Short';
      case PostType.image:
        return 'Image';
    }
  }

  bool get isVideo => this == PostType.video;
  bool get isShort => this == PostType.short;
  bool get isImage => this == PostType.image;
}

class PostModel extends Equatable {
  final String id;
  final UserModel author;
  final String? caption;
  final String? title;
  final List<MediaItem> media;
  final PostType type;
  final String? location;
  final List<String> tags;
  final int likesCount;
  final int dislikesCount;
  final int commentsCount;
  final int sharesCount;
  final int viewsCount;
  final bool isLiked;
  final bool isDisliked;
  final bool isSaved;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostModel({
    required this.id,
    required this.author,
    this.caption,
    this.title,
    required this.media,
    required this.type,
    this.location,
    this.tags = const [],
    this.likesCount = 0,
    this.dislikesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.viewsCount = 0,
    this.isLiked = false,
    this.isDisliked = false,
    this.isSaved = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper getters for easy type checking
  bool get isVideoPost => type == PostType.video;
  bool get isShortPost => type == PostType.short;
  bool get isImagePost => type == PostType.image;

  // Get primary media URL (first item)
  String? get primaryMediaUrl => media.isNotEmpty ? media.first.url : null;

  // Get thumbnail URL for videos/shorts
  String? get thumbnailUrl {
    if (media.isNotEmpty) {
      return media.first.thumbnail ?? media.first.url;
    }
    return null;
  }

  // Get duration for videos/shorts
  double? get duration {
    if (media.isNotEmpty && (isVideoPost || isShortPost)) {
      return media.first.duration;
    }
    return null;
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final postType = _parsePostType(json['postType'] ?? json['type']);

    // 🔥 CRITICAL: Handle uploader as both String ID or UserModel object
    UserModel author;
    final uploaderData = json['uploader'] ?? json['author'];

    if (uploaderData is Map<String, dynamic>) {
      // Backend returned full user object (after populate)
      author = UserModel.fromJson(uploaderData);
    } else if (uploaderData is String) {
      // Backend returned only ID - create minimal UserModel
      author = UserModel(
        id: uploaderData,
        username: 'Loading...',
        email: '',
        fullName: 'Loading...',
        accountType: AccountType.Personal,
        createdAt: DateTime.now(),
      );
    } else {
      // Fallback
      author = UserModel.fromJson({});
    }

    return PostModel(
      id: json['_id'] ?? json['id'] ?? '',
      author: author,
      caption: json['description'] ?? json['caption'],
      title: json['title'],
      media: _buildMediaFromBackend(json, postType),
      type: postType,
      location: json['location'],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      likesCount:
          json['likesCount'] ??
          (json['likes'] is List ? (json['likes'] as List).length : 0),
      dislikesCount:
          json['dislikesCount'] ??
          (json['dislikes'] is List ? (json['dislikes'] as List).length : 0),
      isLiked: json['isLiked'] ?? false,
      isDisliked: json['isDisliked'] ?? false,
      commentsCount: json['comments_count'] ?? json['commentsCount'] ?? 0,
      sharesCount: json['shares_count'] ?? json['sharesCount'] ?? 0,
      viewsCount: json['views'] ?? json['viewsCount'] ?? 0,
      isSaved: json['is_saved'] ?? json['isSaved'] ?? false,
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDateTime(json['updatedAt'] ?? json['updated_at']),
    );
  }

  static PostType _parsePostType(String? type) {
    switch (type?.toLowerCase()) {
      case 'video':
        return PostType.video;
      case 'short':
        return PostType.short;
      case 'image':
      case 'images':
        return PostType.image;
      default:
        return PostType.image;
    }
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  static List<MediaItem> _buildMediaFromBackend(
    Map<String, dynamic> json,
    PostType type,
  ) {
    // Handle video or short type
    if ((type == PostType.video || type == PostType.short) &&
        json['videoUrl'] != null) {
      return [
        MediaItem(
          url: json['videoUrl'],
          thumbnail: json['thumbnailUrl'],
          type: type,
          duration: json['duration']?.toDouble(),
        ),
      ];
    }

    // Handle images type
    if (type == PostType.image && json['images'] != null) {
      return (json['images'] as List<dynamic>)
          .map((img) {
            final imageUrl = img is Map ? (img['url'] ?? '') : img.toString();
            return MediaItem(
              url: imageUrl,
              thumbnail: null,
              type: PostType.image,
            );
          })
          .where((item) => item.url.isNotEmpty)
          .toList();
    }

    // Fallback: handle 'media' array if present
    if (json['media'] != null && json['media'] is List) {
      return (json['media'] as List<dynamic>)
          .map((e) => MediaItem.fromJson(e))
          .toList();
    }

    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author.toJson(),
      'caption': caption,
      'title': title,
      'media': media.map((e) => e.toJson()).toList(),
      'type': type.toApiString(),
      'location': location,
      'tags': tags,
      'likes_count': likesCount,
      'dislikes_count': dislikesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'views_count': viewsCount,
      'is_liked': isLiked,
      'is_disliked': isDisliked,
      'is_saved': isSaved,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PostModel copyWith({
    String? id,
    UserModel? author,
    String? caption,
    String? title,
    List<MediaItem>? media,
    PostType? type,
    String? location,
    List<String>? tags,
    int? likesCount,
    int? dislikesCount,
    int? commentsCount,
    int? sharesCount,
    int? viewsCount,
    bool? isLiked,
    bool? isDisliked,
    bool? isSaved,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      author: author ?? this.author,
      caption: caption ?? this.caption,
      title: title ?? this.title,
      media: media ?? this.media,
      type: type ?? this.type,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      likesCount: likesCount ?? this.likesCount,
      dislikesCount: dislikesCount ?? this.dislikesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      isLiked: isLiked ?? this.isLiked,
      isDisliked: isDisliked ?? this.isDisliked,
      isSaved: isSaved ?? this.isSaved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    author,
    caption,
    title,
    media,
    type,
    location,
    tags,
    likesCount,
    dislikesCount,
    commentsCount,
    sharesCount,
    viewsCount,
    isLiked,
    isDisliked,
    isSaved,
    createdAt,
    updatedAt,
  ];
}
