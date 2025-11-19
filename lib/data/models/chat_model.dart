import 'package:equatable/equatable.dart';
import 'user_model.dart';

enum MessageType { text, image, video, audio, voice }

enum MessageStatus { sending, sent, delivered, read, failed }

class MessageModel extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String? content;
  final MessageType type;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final MessageStatus status;
  final DateTime createdAt;
  final DateTime? readAt;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    this.content,
    required this.type,
    this.mediaUrl,
    this.thumbnailUrl,
    required this.status,
    required this.createdAt,
    this.readAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? json['_id'] ?? '',
      chatId: json['chat_id'] ?? json['chatId'] ?? '',
      senderId: json['sender_id'] ?? json['senderId'] ?? '',
      receiverId: json['receiver_id'] ?? json['receiverId'] ?? '',
      content: json['content'],
      type: _getMessageType(json['type']),
      mediaUrl: json['media_url'] ?? json['mediaUrl'],
      thumbnailUrl: json['thumbnail_url'] ?? json['thumbnailUrl'],
      status: _getMessageStatus(json['status']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'])
          : json['readAt'] != null
              ? DateTime.parse(json['readAt'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'type': type.toString().split('.').last,
      'media_url': mediaUrl,
      'thumbnail_url': thumbnailUrl,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }

  static MessageType _getMessageType(String? type) {
    switch (type) {
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'audio':
        return MessageType.audio;
      case 'voice':
        return MessageType.voice;
      default:
        return MessageType.text;
    }
  }

  static MessageStatus _getMessageStatus(String? status) {
    switch (status) {
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'failed':
        return MessageStatus.failed;
      default:
        return MessageStatus.sending;
    }
  }

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? type,
    String? mediaUrl,
    String? thumbnailUrl,
    MessageStatus? status,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        chatId,
        senderId,
        receiverId,
        content,
        type,
        mediaUrl,
        thumbnailUrl,
        status,
        createdAt,
        readAt,
      ];
}

class ChatModel extends Equatable {
  final String id;
  final UserModel participant;
  final MessageModel? lastMessage;
  final int unreadCount;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatModel({
    required this.id,
    required this.participant,
    this.lastMessage,
    this.unreadCount = 0,
    this.isOnline = false,
    this.lastSeen,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] ?? json['_id'] ?? '',
      participant: UserModel.fromJson(json['participant'] ?? {}),
      lastMessage: json['last_message'] != null
          ? MessageModel.fromJson(json['last_message'])
          : json['lastMessage'] != null
              ? MessageModel.fromJson(json['lastMessage'])
              : null,
      unreadCount: json['unread_count'] ?? json['unreadCount'] ?? 0,
      isOnline: json['is_online'] ?? json['isOnline'] ?? false,
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'])
          : json['lastSeen'] != null
              ? DateTime.parse(json['lastSeen'])
              : null,
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
      'participant': participant.toJson(),
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ChatModel copyWith({
    String? id,
    UserModel? participant,
    MessageModel? lastMessage,
    int? unreadCount,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participant: participant ?? this.participant,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        participant,
        lastMessage,
        unreadCount,
        isOnline,
        lastSeen,
        createdAt,
        updatedAt,
      ];
}