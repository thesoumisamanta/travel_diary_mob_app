class VideoModel {
  final String id;
  final String title;
  final String? description;
  final String fileUrl;
  final String? thumbnailUrl;
  final int? duration;
  final int views;
  final int likesCount;
  final int dislikesCount;
  final List<String> tags;
  final bool isPublic;
  final DateTime createdAt;
  final String uploaderId;
  final String? uploaderUsername;
  final String? uploaderAvatar;

  VideoModel({
    required this.id,
    required this.title,
    this.description,
    required this.fileUrl,
    this.thumbnailUrl,
    this.duration,
    this.views = 0,
    this.likesCount = 0,
    this.dislikesCount = 0,
    this.tags = const [],
    this.isPublic = true,
    required this.createdAt,
    required this.uploaderId,
    this.uploaderUsername,
    this.uploaderAvatar,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    final uploader = json['uploader'];
    
    return VideoModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      fileUrl: json['fileUrl'] ?? json['file_url'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? json['thumbnail_url'],
      duration: json['duration']?.toInt(),
      views: json['views'] ?? 0,
      likesCount: (json['likes'] is List) 
          ? (json['likes'] as List).length 
          : json['likesCount'] ?? json['likes_count'] ?? 0,
      dislikesCount: (json['dislikes'] is List)
          ? (json['dislikes'] as List).length
          : json['dislikesCount'] ?? json['dislikes_count'] ?? 0,
      tags: json['tags'] != null 
          ? List<String>.from(json['tags']) 
          : [],
      isPublic: json['isPublic'] ?? json['is_public'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      uploaderId: uploader is Map 
          ? (uploader['_id'] ?? uploader['id'] ?? '') 
          : (json['uploader'] ?? ''),
      uploaderUsername: uploader is Map ? uploader['username'] : null,
      uploaderAvatar: uploader is Map ? uploader['avatar'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'file_url': fileUrl,
      'thumbnail_url': thumbnailUrl,
      'duration': duration,
      'views': views,
      'likes_count': likesCount,
      'dislikes_count': dislikesCount,
      'tags': tags,
      'is_public': isPublic,
      'created_at': createdAt.toIso8601String(),
      'uploader_id': uploaderId,
      'uploader_username': uploaderUsername,
      'uploader_avatar': uploaderAvatar,
    };
  }

  VideoModel copyWith({
    String? id,
    String? title,
    String? description,
    String? fileUrl,
    String? thumbnailUrl,
    int? duration,
    int? views,
    int? likesCount,
    int? dislikesCount,
    List<String>? tags,
    bool? isPublic,
    DateTime? createdAt,
    String? uploaderId,
    String? uploaderUsername,
    String? uploaderAvatar,
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      views: views ?? this.views,
      likesCount: likesCount ?? this.likesCount,
      dislikesCount: dislikesCount ?? this.dislikesCount,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      uploaderId: uploaderId ?? this.uploaderId,
      uploaderUsername: uploaderUsername ?? this.uploaderUsername,
      uploaderAvatar: uploaderAvatar ?? this.uploaderAvatar,
    );
  }
}