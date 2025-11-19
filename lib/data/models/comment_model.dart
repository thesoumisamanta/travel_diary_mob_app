import 'package:equatable/equatable.dart';
import 'user_model.dart';

class CommentModel extends Equatable {
  final String id;
  final String postId;
  final UserModel author;
  final String content;
  final int likesCount;
  final bool isLiked;
  final String? parentCommentId;
  final int repliesCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.author,
    required this.content,
    this.likesCount = 0,
    this.isLiked = false,
    this.parentCommentId,
    this.repliesCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? json['_id'] ?? '',
      postId: json['post_id'] ?? json['postId'] ?? '',
      author: UserModel.fromJson(json['author'] ?? {}),
      content: json['content'] ?? '',
      likesCount: json['likes_count'] ?? json['likesCount'] ?? 0,
      isLiked: json['is_liked'] ?? json['isLiked'] ?? false,
      parentCommentId: json['parent_comment_id'] ?? json['parentCommentId'],
      repliesCount: json['replies_count'] ?? json['repliesCount'] ?? 0,
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
      'post_id': postId,
      'author': author.toJson(),
      'content': content,
      'likes_count': likesCount,
      'is_liked': isLiked,
      'parent_comment_id': parentCommentId,
      'replies_count': repliesCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CommentModel copyWith({
    String? id,
    String? postId,
    UserModel? author,
    String? content,
    int? likesCount,
    bool? isLiked,
    String? parentCommentId,
    int? repliesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      author: author ?? this.author,
      content: content ?? this.content,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      repliesCount: repliesCount ?? this.repliesCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        postId,
        author,
        content,
        likesCount,
        isLiked,
        parentCommentId,
        repliesCount,
        createdAt,
        updatedAt,
      ];
}