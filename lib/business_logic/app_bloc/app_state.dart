import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';
import '../../data/models/post_model.dart';
import '../../data/models/comment_model.dart';
import '../../data/models/story_model.dart';
import '../../data/models/chat_model.dart';

class AppState extends Equatable {
  // User State
  final UserModel? currentUser;
  final UserModel? selectedUser;
  final bool isLoadingUser;
  final String? userError;

  // Post State
  final List<PostModel> feedPosts;
  final List<PostModel> userPosts;
  final PostModel? selectedPost;
  final bool isLoadingPosts;
  final bool hasMorePosts;
  final int currentFeedPage;
  final String? postError;

  // Shorts State
  final List<PostModel> shorts;
  final bool isLoadingShorts;
  final bool hasMoreShorts;
  final int currentShortsPage;
  final String? shortsError;

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
  final List<UserModel> searchedUsers;
  final List<PostModel> searchedPosts;
  final String? searchQuery;
  final bool isSearching;
  final String? searchError;
  final bool hasMoreSearchResults;
  final int currentSearchPage;

  // Upload State
  final bool isUploading;
  final double uploadProgress;
  final String? uploadError;

  const AppState({
    // User
    this.currentUser,
    this.selectedUser,
    this.isLoadingUser = false,
    this.userError,
    // Posts
    this.feedPosts = const [],
    this.userPosts = const [],
    this.selectedPost,
    this.isLoadingPosts = false,
    this.hasMorePosts = true,
    this.currentFeedPage = 1,
    this.postError,
    // Shorts
    this.shorts = const [],
    this.isLoadingShorts = false,
    this.hasMoreShorts = true,
    this.currentShortsPage = 1,
    this.shortsError,
    // Comments
    this.comments = const [],
    this.isLoadingComments = false,
    this.hasMoreComments = true,
    this.currentCommentsPage = 1,
    this.commentError,
    // Stories
    this.stories = const [],
    this.isLoadingStories = false,
    this.storyError,
    // Chats
    this.chats = const [],
    this.messages = const [],
    this.isLoadingChats = false,
    this.isLoadingMessages = false,
    this.chatError,
    // Search
    this.searchedUsers = const [],
    this.searchedPosts = const [],
    this.searchQuery,
    this.isSearching = false,
    this.searchError,
    this.hasMoreSearchResults = false,
    this.currentSearchPage = 1,
    // Upload
    this.isUploading = false,
    this.uploadProgress = 0.0,
    this.uploadError,
  });

  // Helper getters for filtered posts
  List<PostModel> get imagePosts => feedPosts.where((p) => p.isImagePost).toList();
  List<PostModel> get videoPosts => feedPosts.where((p) => p.isVideoPost).toList();
  List<PostModel> get shortPosts => feedPosts.where((p) => p.isShortPost).toList();

  // Helper getters for searched filtered posts
  List<PostModel> get searchedImagePosts => searchedPosts.where((p) => p.isImagePost).toList();
  List<PostModel> get searchedVideoPosts => searchedPosts.where((p) => p.isVideoPost).toList();
  List<PostModel> get searchedShortPosts => searchedPosts.where((p) => p.isShortPost).toList();

  AppState copyWith({
    UserModel? currentUser,
    UserModel? selectedUser,
    bool? isLoadingUser,
    String? userError,
    List<PostModel>? feedPosts,
    List<PostModel>? userPosts,
    PostModel? selectedPost,
    bool? isLoadingPosts,
    bool? hasMorePosts,
    int? currentFeedPage,
    String? postError,
    List<PostModel>? shorts,
    bool? isLoadingShorts,
    bool? hasMoreShorts,
    int? currentShortsPage,
    String? shortsError,
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
    List<UserModel>? searchedUsers,
    List<PostModel>? searchedPosts,
    String? searchQuery,
    bool? isSearching,
    String? searchError,
    bool? hasMoreSearchResults,
    int? currentSearchPage,
    bool? isUploading,
    double? uploadProgress,
    String? uploadError,
  }) {
    return AppState(
      currentUser: currentUser ?? this.currentUser,
      selectedUser: selectedUser ?? this.selectedUser,
      isLoadingUser: isLoadingUser ?? this.isLoadingUser,
      userError: userError,
      feedPosts: feedPosts ?? this.feedPosts,
      userPosts: userPosts ?? this.userPosts,
      selectedPost: selectedPost ?? this.selectedPost,
      isLoadingPosts: isLoadingPosts ?? this.isLoadingPosts,
      hasMorePosts: hasMorePosts ?? this.hasMorePosts,
      currentFeedPage: currentFeedPage ?? this.currentFeedPage,
      postError: postError,
      shorts: shorts ?? this.shorts,
      isLoadingShorts: isLoadingShorts ?? this.isLoadingShorts,
      hasMoreShorts: hasMoreShorts ?? this.hasMoreShorts,
      currentShortsPage: currentShortsPage ?? this.currentShortsPage,
      shortsError: shortsError,
      comments: comments ?? this.comments,
      isLoadingComments: isLoadingComments ?? this.isLoadingComments,
      hasMoreComments: hasMoreComments ?? this.hasMoreComments,
      currentCommentsPage: currentCommentsPage ?? this.currentCommentsPage,
      commentError: commentError,
      stories: stories ?? this.stories,
      isLoadingStories: isLoadingStories ?? this.isLoadingStories,
      storyError: storyError,
      chats: chats ?? this.chats,
      messages: messages ?? this.messages,
      isLoadingChats: isLoadingChats ?? this.isLoadingChats,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      chatError: chatError,
      searchedUsers: searchedUsers ?? this.searchedUsers,
      searchedPosts: searchedPosts ?? this.searchedPosts,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
      searchError: searchError,
      hasMoreSearchResults: hasMoreSearchResults ?? this.hasMoreSearchResults,
      currentSearchPage: currentSearchPage ?? this.currentSearchPage,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      uploadError: uploadError,
    );
  }

  @override
  List<Object?> get props => [
    currentUser, selectedUser, isLoadingUser, userError,
    feedPosts, userPosts, selectedPost, isLoadingPosts, hasMorePosts, currentFeedPage, postError,
    shorts, isLoadingShorts, hasMoreShorts, currentShortsPage, shortsError,
    comments, isLoadingComments, hasMoreComments, currentCommentsPage, commentError,
    stories, isLoadingStories, storyError,
    chats, messages, isLoadingChats, isLoadingMessages, chatError,
    searchedUsers, searchedPosts, searchQuery, isSearching, searchError, hasMoreSearchResults, currentSearchPage,
    isUploading, uploadProgress, uploadError,
  ];
}