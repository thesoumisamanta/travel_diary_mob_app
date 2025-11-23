import 'package:equatable/equatable.dart';
import 'user_model.dart';

class CommentModel extends Equatable {
  final String id;
  final UserModel author;
  final String content;
  final String? parentId;
  final int likesCount;
  final int dislikesCount;
  final int replyCount;
  final bool isLiked;
  final bool isDisliked;
  final bool isEdited;
  final DateTime? editedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CommentModel({
    required this.id,
    required this.author,
    required this.content,
    this.parentId,
    this.likesCount = 0,
    this.dislikesCount = 0,
    this.replyCount = 0,
    this.isLiked = false,
    this.isDisliked = false,
    this.isEdited = false,
    this.editedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['_id'] ?? json['id'] ?? '',
      author: UserModel.fromJson(json['author'] ?? {}),
      content: json['content'] ?? '',
      parentId: json['parent'],
      likesCount: json['likesCount'] ?? 
          (json['likes'] is List ? (json['likes'] as List).length : 0),
      dislikesCount: json['dislikesCount'] ?? 
          (json['dislikes'] is List ? (json['dislikes'] as List).length : 0),
      replyCount: json['replyCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      isDisliked: json['isDisliked'] ?? false,
      isEdited: json['isEdited'] ?? false,
      editedAt: json['editedAt'] != null 
          ? DateTime.tryParse(json['editedAt'].toString()) 
          : null,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author.toJson(),
      'content': content,
      'parent': parentId,
      'likesCount': likesCount,
      'dislikesCount': dislikesCount,
      'replyCount': replyCount,
      'isLiked': isLiked,
      'isDisliked': isDisliked,
      'isEdited': isEdited,
      'editedAt': editedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  CommentModel copyWith({
    String? id,
    UserModel? author,
    String? content,
    String? parentId,
    int? likesCount,
    int? dislikesCount,
    int? replyCount,
    bool? isLiked,
    bool? isDisliked,
    bool? isEdited,
    DateTime? editedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      parentId: parentId ?? this.parentId,
      likesCount: likesCount ?? this.likesCount,
      dislikesCount: dislikesCount ?? this.dislikesCount,
      replyCount: replyCount ?? this.replyCount,
      isLiked: isLiked ?? this.isLiked,
      isDisliked: isDisliked ?? this.isDisliked,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, author, content, parentId, likesCount, dislikesCount, 
    replyCount, isLiked, isDisliked, isEdited, editedAt, createdAt, updatedAt
  ];
}