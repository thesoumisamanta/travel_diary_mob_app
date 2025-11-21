import 'package:equatable/equatable.dart';
import 'user_model.dart';

enum PostType { image, video, short }

class MediaItem {
  final String url;
  final String? thumbnail;
  final PostType type;
  final double? duration; // For videos

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
      'type': type == PostType.image
          ? 'image'
          : type == PostType.video
          ? 'video'
          : 'short',
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
      case 'images': // ✅ Handle both singular and plural
        return PostType.image;
      default:
        return PostType.image;
    }
  }
}

class PostModel extends Equatable {
  final String id;
  final UserModel author;
  final String? caption;
  final List<MediaItem> media;
  final PostType type;
  final String? location;
  final List<String> tags;
  final int likesCount;
  final int dislikesCount;
  final int commentsCount;
  final int sharesCount;
  final bool isLiked;
  final bool isDisliked;
  final bool isSaved;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostModel({
    required this.id,
    required this.author,
    this.caption,
    required this.media,
    required this.type,
    this.location,
    this.tags = const [],
    this.likesCount = 0,
    this.dislikesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.isLiked = false,
    this.isDisliked = false,
    this.isSaved = false,
    required this.createdAt,
    required this.updatedAt,
  });



  factory PostModel.fromJson(Map<String, dynamic> json) {


    final post = PostModel(
      id: json['_id'] ?? json['id'] ?? '',
      author: UserModel.fromJson(json['uploader'] ?? json['author'] ?? {}),
      caption: json['description'] ?? json['caption'],
      media: _buildMediaFromBackend(json),
      type: MediaItem._getPostType(json['postType'] ?? json['type']),
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
      isSaved: json['is_saved'] ?? json['isSaved'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );



    return post;
  }

  static List<MediaItem> _buildMediaFromBackend(Map<String, dynamic> json) {
    final postType = (json['postType'] ?? json['type'])
        ?.toString()
        .toLowerCase();

    if (postType == 'video' && json['videoUrl'] != null) {
      return [
        MediaItem(
          url: json['videoUrl'],
          thumbnail: json['thumbnailUrl'],
          type: PostType.video,
          duration: json['duration']?.toDouble(),
        ),
      ];
    }
    else if ((postType == 'images' || postType == 'image') &&
        json['images'] != null) {

      return (json['images'] as List<dynamic>)
          .map((img) {
            // Backend images array contains objects with 'url' and 'caption'
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
    else if (json['media'] != null && json['media'] is List) {
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
      'media': media.map((e) => e.toJson()).toList(),
      'type': type == PostType.image
          ? 'image'
          : type == PostType.video
          ? 'video'
          : 'short',
      'location': location,
      'tags': tags,
      'likes_count': likesCount,
      'dislikes_count': dislikesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
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
    List<MediaItem>? media,
    PostType? type,
    String? location,
    List<String>? tags,
    int? likesCount,
    int? dislikesCount,
    int? commentsCount,
    int? sharesCount,
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
      media: media ?? this.media,
      type: type ?? this.type,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      likesCount: likesCount ?? this.likesCount,
      dislikesCount: dislikesCount ?? this.dislikesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
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
    media,
    type,
    location,
    tags,
    likesCount,
    dislikesCount,
    commentsCount,
    sharesCount,
    isLiked,
    isDisliked,
    isSaved,
    createdAt,
    updatedAt,
  ];
}
