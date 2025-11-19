import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

// User Events
class LoadUserProfile extends AppEvent {
  final String userId;

  const LoadUserProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateUserProfile extends AppEvent {
  final Map<String, dynamic> data;

  const UpdateUserProfile(this.data);

  @override
  List<Object?> get props => [data];
}

class FollowUser extends AppEvent {
  final String userId;

  const FollowUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UnfollowUser extends AppEvent {
  final String userId;

  const UnfollowUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

// Post Events
class LoadFeed extends AppEvent {
  final bool refresh;

  const LoadFeed({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class LoadUserPosts extends AppEvent {
  final String userId;
  final bool refresh;

  const LoadUserPosts(this.userId, {this.refresh = false});

  @override
  List<Object?> get props => [userId, refresh];
}

class LoadPostDetails extends AppEvent {
  final String postId;

  const LoadPostDetails(this.postId);

  @override
  List<Object?> get props => [postId];
}

class CreatePost extends AppEvent {
  final List<File> mediaFiles;
  final String? caption;
  final String? location;
  final List<String> tags;
  final String postType;

  const CreatePost({
    required this.mediaFiles,
    this.caption,
    this.location,
    this.tags = const [],
    required this.postType,
  });

  @override
  List<Object?> get props => [mediaFiles, caption, location, tags, postType];
}

class DeletePost extends AppEvent {
  final String postId;

  const DeletePost(this.postId);

  @override
  List<Object?> get props => [postId];
}

class LikePost extends AppEvent {
  final String postId;
  final bool isLiked;

  const LikePost(this.postId, this.isLiked);

  @override
  List<Object?> get props => [postId, isLiked];
}

// Comment Events
class LoadComments extends AppEvent {
  final String postId;
  final bool refresh;

  const LoadComments(this.postId, {this.refresh = false});

  @override
  List<Object?> get props => [postId, refresh];
}

class AddComment extends AppEvent {
  final String postId;
  final String content;

  const AddComment(this.postId, this.content);

  @override
  List<Object?> get props => [postId, content];
}

class DeleteComment extends AppEvent {
  final String commentId;

  const DeleteComment(this.commentId);

  @override
  List<Object?> get props => [commentId];
}

// Story Events
class LoadStories extends AppEvent {}

class CreateStory extends AppEvent {
  final File mediaFile;
  final String storyType;

  const CreateStory(this.mediaFile, this.storyType);

  @override
  List<Object?> get props => [mediaFile, storyType];
}

class ViewStory extends AppEvent {
  final String storyId;

  const ViewStory(this.storyId);

  @override
  List<Object?> get props => [storyId];
}

// Chat Events
class LoadChats extends AppEvent {}

class LoadChatHistory extends AppEvent {
  final String chatId;
  final bool refresh;

  const LoadChatHistory(this.chatId, {this.refresh = false});

  @override
  List<Object?> get props => [chatId, refresh];
}

class SendMessage extends AppEvent {
  final String receiverId;
  final String? content;
  final File? mediaFile;
  final String messageType;

  const SendMessage({
    required this.receiverId,
    this.content,
    this.mediaFile,
    required this.messageType,
  });

  @override
  List<Object?> get props => [receiverId, content, mediaFile, messageType];
}

class ReceiveMessage extends AppEvent {
  final Map<String, dynamic> messageData;

  const ReceiveMessage(this.messageData);

  @override
  List<Object?> get props => [messageData];
}

// Search Events
class SearchUsers extends AppEvent {
  final String query;

  const SearchUsers(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchPosts extends AppEvent {
  final String query;

  const SearchPosts(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchContent extends AppEvent {
  final String query;

  const SearchContent(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearch extends AppEvent {}