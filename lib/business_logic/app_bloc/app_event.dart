import 'dart:io';
import '../../data/models/post_model.dart';

abstract class AppEvent {}

// ==================== USER EVENTS ====================
class LoadUserProfile extends AppEvent {}

class UpdateUserProfile extends AppEvent {
  final Map<String, dynamic> data;
  UpdateUserProfile(this.data);
}

class FollowUser extends AppEvent {
  final String userId;
  FollowUser(this.userId);
}

class UnfollowUser extends AppEvent {
  final String userId;
  UnfollowUser(this.userId);
}

// ==================== POST EVENTS ====================
class LoadFeed extends AppEvent {
  final bool refresh;
  final PostType? filterType;
  LoadFeed({this.refresh = false, this.filterType});
}

class LoadUserPosts extends AppEvent {
  final String userId;
  final bool refresh;
  final PostType? filterType;
  LoadUserPosts(this.userId, {this.refresh = false, this.filterType});
}

class LoadPostDetails extends AppEvent {
  final String postId;
  LoadPostDetails(this.postId);
}

class CreatePost extends AppEvent {
  final String caption;
  final String? location;
  final List<String> tags;
  final String postType;
  final List<File> mediaFiles;

  CreatePost({
    required this.caption,
    this.location,
    this.tags = const [],
    required this.postType,
    required this.mediaFiles,
  });
}

class LikePost extends AppEvent {
  final String postId;
  final bool currentlyLiked;
  LikePost(this.postId, [this.currentlyLiked = false]);
}

class DislikePost extends AppEvent {
  final String postId;
  DislikePost(this.postId);
}

// ==================== SHORTS EVENTS ====================
class LoadShorts extends AppEvent {
  final bool refresh;
  LoadShorts({this.refresh = false});
}

// ==================== COMMENT EVENTS ====================
class LoadComments extends AppEvent {
  final String postId;
  final bool refresh;
  LoadComments(this.postId, {this.refresh = false});
}

class AddComment extends AppEvent {
  final String postId;
  final String content;
  AddComment(this.postId, this.content);
}

class DeleteComment extends AppEvent {
  final String commentId;
  DeleteComment(this.commentId);
}

// ==================== STORY EVENTS ====================
class LoadStories extends AppEvent {}

class CreateStory extends AppEvent {
  final File mediaFile;
  final String storyType;
  CreateStory(this.mediaFile, this.storyType);
}

class ViewStory extends AppEvent {
  final String storyId;
  ViewStory(this.storyId);
}

// ==================== CHAT EVENTS ====================
class LoadChats extends AppEvent {}

class LoadChatHistory extends AppEvent {
  final String chatId;
  final bool refresh;
  LoadChatHistory(this.chatId, {this.refresh = false});
}

class SendMessage extends AppEvent {
  final String receiverId;
  final String content;
  final String messageType;
  final File? mediaFile;

  SendMessage(
    this.receiverId,
    this.content,
    this.messageType, {
    this.mediaFile,
  });
}

class ReceiveMessage extends AppEvent {
  final Map<String, dynamic> messageData;
  ReceiveMessage(this.messageData);
}

// ==================== SEARCH EVENTS ====================
class SearchUsers extends AppEvent {
  final String query;
  final int page;
  SearchUsers(this.query, {this.page = 1});
}

class SearchPosts extends AppEvent {
  final String query;
  final int page;
  final PostType? filterType;
  SearchPosts(this.query, {this.page = 1, this.filterType});
}

class SearchContent extends AppEvent {
  final String query;
  final int page;
  SearchContent(this.query, {this.page = 1});
}

class ClearSearch extends AppEvent {}

// ==================== REALTIME SEARCH EVENT ====================
class RealtimeSearch extends AppEvent {
  final String query;
  final SearchFilterType filterType;
  RealtimeSearch(this.query, {this.filterType = SearchFilterType.all});
}

enum SearchFilterType { all, users, posts, videos, images, shorts }