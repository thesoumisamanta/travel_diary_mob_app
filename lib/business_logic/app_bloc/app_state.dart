import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';
import '../../data/models/post_model.dart';
import '../../data/models/comment_model.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/story_model.dart';

class AppState extends Equatable {
  // User State
  final UserModel? currentUser;
  final UserModel? selectedUser;
  final List<UserModel> searchedUsers;
  final bool isLoadingUser;
  final String? userError;

  // Post State
  final List<PostModel> feedPosts;
  final List<PostModel> userPosts;
  final PostModel? selectedPost;
  final List<PostModel> searchedPosts;
  final bool isLoadingPosts;
  final bool hasMorePosts;
  final int currentFeedPage;
  final String? postError;

  // Comment State
  final List<CommentModel> comments;
  final bool isLoadingComments;
  final bool hasMoreComments;
  final int currentCommentsPage;
  final String? commentError;

  // Story State
  final List<StoryGroupModel> stories;
  final bool isLoadingStories;
  final String? storyError;

  // Chat State
  final List<ChatModel> chats;
  final List<MessageModel> messages;
  final bool isLoadingChats;
  final bool isLoadingMessages;
  final String? chatError;

  // Search State
  final bool isSearching;
  final String? searchQuery;
  final String? searchError;

  // Upload State
  final bool isUploading;
  final double uploadProgress;
  final String? uploadError;

  const AppState({
    this.currentUser,
    this.selectedUser,
    this.searchedUsers = const [],
    this.isLoadingUser = false,
    this.userError,
    this.feedPosts = const [],
    this.userPosts = const [],
    this.selectedPost,
    this.searchedPosts = const [],
    this.isLoadingPosts = false,
    this.hasMorePosts = true,
    this.currentFeedPage = 1,
    this.postError,
    this.comments = const [],
    this.isLoadingComments = false,
    this.hasMoreComments = true,
    this.currentCommentsPage = 1,
    this.commentError,
    this.stories = const [],
    this.isLoadingStories = false,
    this.storyError,
    this.chats = const [],
    this.messages = const [],
    this.isLoadingChats = false,
    this.isLoadingMessages = false,
    this.chatError,
    this.isSearching = false,
    this.searchQuery,
    this.searchError,
    this.isUploading = false,
    this.uploadProgress = 0.0,
    this.uploadError,
  });

  AppState copyWith({
    UserModel? currentUser,
    UserModel? selectedUser,
    List<UserModel>? searchedUsers,
    bool? isLoadingUser,
    String? userError,
    List<PostModel>? feedPosts,
    List<PostModel>? userPosts,
    PostModel? selectedPost,
    List<PostModel>? searchedPosts,
    bool? isLoadingPosts,
    bool? hasMorePosts,
    int? currentFeedPage,
    String? postError,
    List<CommentModel>? comments,
    bool? isLoadingComments,
    bool? hasMoreComments,
    int? currentCommentsPage,
    String? commentError,
    List<StoryGroupModel>? stories,
    bool? isLoadingStories,
    String? storyError,
    List<ChatModel>? chats,
    List<MessageModel>? messages,
    bool? isLoadingChats,
    bool? isLoadingMessages,
    String? chatError,
    bool? isSearching,
    String? searchQuery,
    String? searchError,
    bool? isUploading,
    double? uploadProgress,
    String? uploadError,
  }) {
    return AppState(
      currentUser: currentUser ?? this.currentUser,
      selectedUser: selectedUser ?? this.selectedUser,
      searchedUsers: searchedUsers ?? this.searchedUsers,
      isLoadingUser: isLoadingUser ?? this.isLoadingUser,
      userError: userError ?? this.userError,
      feedPosts: feedPosts ?? this.feedPosts,
      userPosts: userPosts ?? this.userPosts,
      selectedPost: selectedPost ?? this.selectedPost,
      searchedPosts: searchedPosts ?? this.searchedPosts,
      isLoadingPosts: isLoadingPosts ?? this.isLoadingPosts,
      hasMorePosts: hasMorePosts ?? this.hasMorePosts,
      currentFeedPage: currentFeedPage ?? this.currentFeedPage,
      postError: postError ?? this.postError,
      comments: comments ?? this.comments,
      isLoadingComments: isLoadingComments ?? this.isLoadingComments,
      hasMoreComments: hasMoreComments ?? this.hasMoreComments,
      currentCommentsPage: currentCommentsPage ?? this.currentCommentsPage,
      commentError: commentError ?? this.commentError,
      stories: stories ?? this.stories,
      isLoadingStories: isLoadingStories ?? this.isLoadingStories,
      storyError: storyError ?? this.storyError,
      chats: chats ?? this.chats,
      messages: messages ?? this.messages,
      isLoadingChats: isLoadingChats ?? this.isLoadingChats,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      chatError: chatError ?? this.chatError,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      searchError: searchError ?? this.searchError,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      uploadError: uploadError ?? this.uploadError,
    );
  }

  @override
  List<Object?> get props => [
        currentUser,
        selectedUser,
        searchedUsers,
        isLoadingUser,
        userError,
        feedPosts,
        userPosts,
        selectedPost,
        searchedPosts,
        isLoadingPosts,
        hasMorePosts,
        currentFeedPage,
        postError,
        comments,
        isLoadingComments,
        hasMoreComments,
        currentCommentsPage,
        commentError,
        stories,
        isLoadingStories,
        storyError,
        chats,
        messages,
        isLoadingChats,
        isLoadingMessages,
        chatError,
        isSearching,
        searchQuery,
        searchError,
        isUploading,
        uploadProgress,
        uploadError,
      ];
}