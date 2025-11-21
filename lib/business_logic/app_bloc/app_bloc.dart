import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_diary_mob_app/data/models/chat_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/post_repository.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/models/post_model.dart';
import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final UserRepository userRepository;
  final PostRepository postRepository;
  final ChatRepository chatRepository;

  AppBloc({
    required this.userRepository,
    required this.postRepository,
    required this.chatRepository,
  }) : super(const AppState()) {
    // User Events
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<FollowUser>(_onFollowUser);
    on<UnfollowUser>(_onUnfollowUser);

    // Post Events
    on<LoadFeed>(_onLoadFeed);
    on<LoadUserPosts>(_onLoadUserPosts);
    on<LoadPostDetails>(_onLoadPostDetails);
    on<CreatePost>(_onCreatePost);
    // on<DeletePost>(_onDeletePost);
    on<LikePost>(_onLikePost);
    on<DislikePost>(_onDislikePost);

    // Comment Events
    on<LoadComments>(_onLoadComments);
    on<AddComment>(_onAddComment);
    on<DeleteComment>(_onDeleteComment);

    // Story Events
    on<LoadStories>(_onLoadStories);
    on<CreateStory>(_onCreateStory);
    on<ViewStory>(_onViewStory);

    // Chat Events
    on<LoadChats>(_onLoadChats);
    on<LoadChatHistory>(_onLoadChatHistory);
    on<SendMessage>(_onSendMessage);
    on<ReceiveMessage>(_onReceiveMessage);

    // Search Events
    on<SearchUsers>(_onSearchUsers);
    on<SearchPosts>(_onSearchPosts);
    on<SearchContent>(_onSearchContent);
    on<ClearSearch>(_onClearSearch);
  }

  // User Event Handlers
  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<AppState> emit,
  ) async {
    emit(state.copyWith(isLoadingUser: true, userError: null));

    try {
      final user = await userRepository.getUserProfile();

      emit(
        state.copyWith(
          selectedUser: user,
          currentUser: user,
          isLoadingUser: false,
          userError: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingUser: false,
          userError: e.toString(),
          currentUser: null,
          selectedUser: null,
        ),
      );
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<AppState> emit,
  ) async {
    emit(state.copyWith(isLoadingUser: true, userError: null));
    try {
      final user = await userRepository.updateProfile(event.data);
      emit(state.copyWith(currentUser: user, isLoadingUser: false));
    } catch (e) {
      emit(state.copyWith(isLoadingUser: false, userError: e.toString()));
    }
  }

  Future<void> _onFollowUser(FollowUser event, Emitter<AppState> emit) async {
    try {
      await userRepository.followUser(event.userId);
      if (state.selectedUser?.id == event.userId) {
        emit(
          state.copyWith(
            selectedUser: state.selectedUser?.copyWith(
              isFollowing: true,
              followersCount: (state.selectedUser?.followersCount ?? 0) + 1,
            ),
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(userError: e.toString()));
    }
  }

  Future<void> _onUnfollowUser(
    UnfollowUser event,
    Emitter<AppState> emit,
  ) async {
    try {
      await userRepository.unfollowUser(event.userId);
      if (state.selectedUser?.id == event.userId) {
        emit(
          state.copyWith(
            selectedUser: state.selectedUser?.copyWith(
              isFollowing: false,
              followersCount: (state.selectedUser?.followersCount ?? 1) - 1,
            ),
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(userError: e.toString()));
    }
  }

  // Post Event Handlers
  Future<void> _onLoadFeed(LoadFeed event, Emitter<AppState> emit) async {
    if (event.refresh) {
      emit(
        state.copyWith(
          isLoadingPosts: true,
          currentFeedPage: 1,
          postError: null,
        ),
      );
    } else if (!state.hasMorePosts || state.isLoadingPosts) {
      return;
    } else {
      emit(state.copyWith(isLoadingPosts: true, postError: null));
    }

    try {
      final posts = await postRepository.getFeed(
        event.refresh ? 1 : state.currentFeedPage,
      );

      emit(
        state.copyWith(
          feedPosts: event.refresh ? posts : [...state.feedPosts, ...posts],
          isLoadingPosts: false,
          hasMorePosts: posts.isNotEmpty,
          currentFeedPage: event.refresh ? 2 : state.currentFeedPage + 1,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingPosts: false, postError: e.toString()));
    }
  }

  Future<void> _onLoadUserPosts(
    LoadUserPosts event,
    Emitter<AppState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoadingPosts: true,
        postError: null,
        userPosts: event.refresh ? [] : state.userPosts,
      ),
    );

    try {
      final posts = await postRepository.getUserPosts(event.userId, 1);
      emit(state.copyWith(userPosts: posts, isLoadingPosts: false));
    } catch (e) {
      emit(state.copyWith(isLoadingPosts: false, postError: e.toString()));
    }
  }

  Future<void> _onLoadPostDetails(
    LoadPostDetails event,
    Emitter<AppState> emit,
  ) async {
    emit(state.copyWith(isLoadingPosts: true, postError: null));
    try {
      final post = await postRepository.getPostById(event.postId);
      emit(state.copyWith(selectedPost: post, isLoadingPosts: false));
    } catch (e) {
      emit(state.copyWith(isLoadingPosts: false, postError: e.toString()));
    }
  }

  Future<void> _onCreatePost(CreatePost event, Emitter<AppState> emit) async {
    emit(
      state.copyWith(isUploading: true, uploadProgress: 0.0, uploadError: null),
    );

    try {
      // Upload media files
      final mediaUrls = await postRepository.uploadMultipleMedia(
        event.mediaFiles,
      );

      // Create post data
      final postData = {
        'caption': event.caption,
        'location': event.location,
        'tags': event.tags,
        'type': event.postType,
        'media': mediaUrls
            .map((url) => {'url': url, 'type': event.postType})
            .toList(),
      };

      final post = await postRepository.createPost(postData);

      emit(
        state.copyWith(
          feedPosts: [post, ...state.feedPosts],
          isUploading: false,
          uploadProgress: 1.0,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isUploading: false, uploadError: e.toString()));
    }
  }

  // Future<void> _onDeletePost(DeletePost event, Emitter<AppState> emit) async {
  //   try {
  //     await postRepository.deletePost(event.postId);

  //     emit(
  //       state.copyWith(
  //         feedPosts: state.feedPosts
  //             .where((p) => p.id != event.postId)
  //             .toList(),
  //         userPosts: state.userPosts
  //             .where((p) => p.id != event.postId)
  //             .toList(),
  //       ),
  //     );
  //   } catch (e) {
  //     emit(state.copyWith(postError: e.toString()));
  //   }
  // }

  // ✅ FIXED: Only showing the corrected _onLikePost and _onDislikePost methods
  // Replace these methods in your app_bloc.dart

  Future<void> _onLikePost(LikePost event, Emitter<AppState> emit) async {
    // Store original state for rollback
    final originalFeedPosts = List<PostModel>.from(state.feedPosts);
    final originalSelectedPost = state.selectedPost;

    // Find current post
    final currentPost = state.feedPosts.firstWhere(
      (p) => p.id == event.postId,
      orElse: () => state.selectedPost!,
    );

    final wasLiked = currentPost.isLiked;
    final wasDisliked = currentPost.isDisliked;

    // ✅ FIXED: Correct optimistic update logic
    final optimisticFeedPosts = state.feedPosts.map((post) {
      if (post.id == event.postId) {
        if (wasLiked) {
          // User is UNLIKING (removing like)
          return post.copyWith(isLiked: false, likesCount: post.likesCount - 1);
        } else {
          // User is LIKING
          return post.copyWith(
            isLiked: true,
            isDisliked: false, // Remove dislike if present
            likesCount: post.likesCount + 1,
            dislikesCount: wasDisliked
                ? post.dislikesCount - 1
                : post.dislikesCount,
          );
        }
      }
      return post;
    }).toList();

    PostModel? optimisticSelectedPost = state.selectedPost;
    if (state.selectedPost?.id == event.postId) {
      if (wasLiked) {
        optimisticSelectedPost = state.selectedPost?.copyWith(
          isLiked: false,
          likesCount: (state.selectedPost?.likesCount ?? 1) - 1,
        );
      } else {
        optimisticSelectedPost = state.selectedPost?.copyWith(
          isLiked: true,
          isDisliked: false,
          likesCount: (state.selectedPost?.likesCount ?? 0) + 1,
          dislikesCount: wasDisliked
              ? (state.selectedPost?.dislikesCount ?? 1) - 1
              : (state.selectedPost?.dislikesCount ?? 0),
        );
      }
    }

    // Apply optimistic update
    emit(
      state.copyWith(
        feedPosts: optimisticFeedPosts,
        selectedPost: optimisticSelectedPost,
      ),
    );

    try {
      // Call backend
      final backendData = await postRepository.likePost(event.postId);

      // ✅ Confirm with backend data
      final confirmedFeedPosts = state.feedPosts.map((post) {
        if (post.id == event.postId) {
          return post.copyWith(
            isLiked: backendData['isLiked'] ?? false,
            isDisliked: backendData['isDisliked'] ?? false,
            likesCount: backendData['likesCount'] ?? 0,
            dislikesCount: backendData['dislikesCount'] ?? 0,
          );
        }
        return post;
      }).toList();

      PostModel? confirmedSelectedPost = state.selectedPost;
      if (state.selectedPost?.id == event.postId) {
        confirmedSelectedPost = state.selectedPost?.copyWith(
          isLiked: backendData['isLiked'] ?? false,
          isDisliked: backendData['isDisliked'] ?? false,
          likesCount: backendData['likesCount'] ?? 0,
          dislikesCount: backendData['dislikesCount'] ?? 0,
        );
      }

      emit(
        state.copyWith(
          feedPosts: confirmedFeedPosts,
          selectedPost: confirmedSelectedPost,
        ),
      );
    } catch (e) {
      // Rollback on error
      emit(
        state.copyWith(
          feedPosts: originalFeedPosts,
          selectedPost: originalSelectedPost,
          postError: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDislikePost(DislikePost event, Emitter<AppState> emit) async {
    // Store original state for rollback
    final originalFeedPosts = List<PostModel>.from(state.feedPosts);
    final originalSelectedPost = state.selectedPost;

    // Find current post
    final currentPost = state.feedPosts.firstWhere(
      (p) => p.id == event.postId,
      orElse: () => state.selectedPost!,
    );

    final wasLiked = currentPost.isLiked;
    final wasDisliked = currentPost.isDisliked;

    // ✅ FIXED: Correct optimistic update logic
    final optimisticFeedPosts = state.feedPosts.map((post) {
      if (post.id == event.postId) {
        if (wasDisliked) {
          // User is REMOVING dislike
          return post.copyWith(
            isDisliked: false,
            dislikesCount: post.dislikesCount - 1,
          );
        } else {
          // User is DISLIKING
          return post.copyWith(
            isDisliked: true,
            isLiked: false, // Remove like if present
            dislikesCount: post.dislikesCount + 1,
            likesCount: wasLiked ? post.likesCount - 1 : post.likesCount,
          );
        }
      }
      return post;
    }).toList();

    PostModel? optimisticSelectedPost = state.selectedPost;
    if (state.selectedPost?.id == event.postId) {
      if (wasDisliked) {
        optimisticSelectedPost = state.selectedPost?.copyWith(
          isDisliked: false,
          dislikesCount: (state.selectedPost?.dislikesCount ?? 1) - 1,
        );
      } else {
        optimisticSelectedPost = state.selectedPost?.copyWith(
          isDisliked: true,
          isLiked: false,
          dislikesCount: (state.selectedPost?.dislikesCount ?? 0) + 1,
          likesCount: wasLiked
              ? (state.selectedPost?.likesCount ?? 1) - 1
              : (state.selectedPost?.likesCount ?? 0),
        );
      }
    }

    // Apply optimistic update
    emit(
      state.copyWith(
        feedPosts: optimisticFeedPosts,
        selectedPost: optimisticSelectedPost,
      ),
    );

    try {
      // Call backend
      final backendData = await postRepository.dislikePost(event.postId);

      // ✅ Confirm with backend data
      final confirmedFeedPosts = state.feedPosts.map((post) {
        if (post.id == event.postId) {
          return post.copyWith(
            isLiked: backendData['isLiked'] ?? false,
            isDisliked: backendData['isDisliked'] ?? false,
            likesCount: backendData['likesCount'] ?? 0,
            dislikesCount: backendData['dislikesCount'] ?? 0,
          );
        }
        return post;
      }).toList();

      PostModel? confirmedSelectedPost = state.selectedPost;
      if (state.selectedPost?.id == event.postId) {
        confirmedSelectedPost = state.selectedPost?.copyWith(
          isLiked: backendData['isLiked'] ?? false,
          isDisliked: backendData['isDisliked'] ?? false,
          likesCount: backendData['likesCount'] ?? 0,
          dislikesCount: backendData['dislikesCount'] ?? 0,
        );
      }

      emit(
        state.copyWith(
          feedPosts: confirmedFeedPosts,
          selectedPost: confirmedSelectedPost,
        ),
      );
    } catch (e) {
      // Rollback on error
      emit(
        state.copyWith(
          feedPosts: originalFeedPosts,
          selectedPost: originalSelectedPost,
          postError: e.toString(),
        ),
      );
    }
  }

  // Comment Event Handlers
  Future<void> _onLoadComments(
    LoadComments event,
    Emitter<AppState> emit,
  ) async {
    if (event.refresh) {
      emit(
        state.copyWith(
          isLoadingComments: true,
          currentCommentsPage: 1,
          commentError: null,
          comments: [],
        ),
      );
    } else if (!state.hasMoreComments || state.isLoadingComments) {
      return;
    } else {
      emit(state.copyWith(isLoadingComments: true, commentError: null));
    }

    try {
      final comments = await postRepository.getPostComments(
        event.postId,
        event.refresh ? 1 : state.currentCommentsPage,
      );

      emit(
        state.copyWith(
          comments: event.refresh ? comments : [...state.comments, ...comments],
          isLoadingComments: false,
          hasMoreComments: comments.isNotEmpty,
          currentCommentsPage: event.refresh
              ? 2
              : state.currentCommentsPage + 1,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(isLoadingComments: false, commentError: e.toString()),
      );
    }
  }

  Future<void> _onAddComment(AddComment event, Emitter<AppState> emit) async {
    try {
      final comment = await postRepository.addComment(
        event.postId,
        event.content,
      );

      emit(state.copyWith(comments: [comment, ...state.comments]));

      // Update post comment count
      if (state.selectedPost?.id == event.postId) {
        emit(
          state.copyWith(
            selectedPost: state.selectedPost?.copyWith(
              commentsCount: (state.selectedPost?.commentsCount ?? 0) + 1,
            ),
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(commentError: e.toString()));
    }
  }

  Future<void> _onDeleteComment(
    DeleteComment event,
    Emitter<AppState> emit,
  ) async {
    try {
      await postRepository.deleteComment(event.commentId);

      emit(
        state.copyWith(
          comments: state.comments
              .where((c) => c.id != event.commentId)
              .toList(),
        ),
      );
    } catch (e) {
      emit(state.copyWith(commentError: e.toString()));
    }
  }

  // Story Event Handlers
  Future<void> _onLoadStories(LoadStories event, Emitter<AppState> emit) async {
    emit(state.copyWith(isLoadingStories: true, storyError: null));
    try {
      final stories = await postRepository.getStories();
      emit(state.copyWith(stories: stories, isLoadingStories: false));
    } catch (e) {
      emit(state.copyWith(isLoadingStories: false, storyError: e.toString()));
    }
  }

  Future<void> _onCreateStory(CreateStory event, Emitter<AppState> emit) async {
    emit(state.copyWith(isUploading: true, uploadError: null));

    try {
      final mediaUrl = await postRepository.uploadMedia(event.mediaFile);

      final storyData = {'media_url': mediaUrl, 'type': event.storyType};

      await postRepository.createStory(storyData);

      emit(state.copyWith(isUploading: false));

      // Reload stories
      add(LoadStories());
    } catch (e) {
      emit(state.copyWith(isUploading: false, uploadError: e.toString()));
    }
  }

  Future<void> _onViewStory(ViewStory event, Emitter<AppState> emit) async {
    try {
      await postRepository.viewStory(event.storyId);
    } catch (e) {
      // Silent fail
    }
  }

  // Chat Event Handlers
  Future<void> _onLoadChats(LoadChats event, Emitter<AppState> emit) async {
    emit(state.copyWith(isLoadingChats: true, chatError: null));
    try {
      final chats = await chatRepository.getChats();
      emit(state.copyWith(chats: chats, isLoadingChats: false));
    } catch (e) {
      emit(state.copyWith(isLoadingChats: false, chatError: e.toString()));
    }
  }

  Future<void> _onLoadChatHistory(
    LoadChatHistory event,
    Emitter<AppState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoadingMessages: true,
        chatError: null,
        messages: event.refresh ? [] : state.messages,
      ),
    );

    try {
      final messages = await chatRepository.getChatHistory(event.chatId, 1);
      emit(
        state.copyWith(
          messages: messages.reversed.toList(),
          isLoadingMessages: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingMessages: false, chatError: e.toString()));
    }
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<AppState> emit) async {
    try {
      String? mediaUrl;
      if (event.mediaFile != null) {
        mediaUrl = await postRepository.uploadMedia(event.mediaFile!);
      }

      final messageData = {
        'receiver_id': event.receiverId,
        'content': event.content,
        'media_url': mediaUrl,
        'type': event.messageType,
      };

      final message = await chatRepository.sendMessage(messageData);

      emit(state.copyWith(messages: [...state.messages, message]));
    } catch (e) {
      emit(state.copyWith(chatError: e.toString()));
    }
  }

  Future<void> _onReceiveMessage(
    ReceiveMessage event,
    Emitter<AppState> emit,
  ) async {
    try {
      final message = MessageModel.fromJson(event.messageData);
      emit(state.copyWith(messages: [...state.messages, message]));
    } catch (e) {
      // Silent fail
    }
  }

  // Search Event Handlers
  Future<void> _onSearchUsers(SearchUsers event, Emitter<AppState> emit) async {
    emit(
      state.copyWith(
        isSearching: true,
        searchQuery: event.query,
        searchError: null,
      ),
    );

    try {
      final users = await userRepository.searchUsers(event.query, 1);
      emit(state.copyWith(searchedUsers: users, isSearching: false));
    } catch (e) {
      emit(state.copyWith(isSearching: false, searchError: e.toString()));
    }
  }

  Future<void> _onSearchPosts(SearchPosts event, Emitter<AppState> emit) async {
    emit(
      state.copyWith(
        isSearching: true,
        searchQuery: event.query,
        searchError: null,
      ),
    );

    try {
      final posts = await postRepository.searchPosts(event.query, 1);
      emit(state.copyWith(searchedPosts: posts, isSearching: false));
    } catch (e) {
      emit(state.copyWith(isSearching: false, searchError: e.toString()));
    }
  }

  Future<void> _onSearchContent(
    SearchContent event,
    Emitter<AppState> emit,
  ) async {
    emit(
      state.copyWith(
        isSearching: true,
        searchQuery: event.query,
        searchError: null,
      ),
    );

    try {
      final users = await userRepository.searchUsers(event.query, 1);
      final posts = await postRepository.searchPosts(event.query, 1);

      emit(
        state.copyWith(
          searchedUsers: users,
          searchedPosts: posts,
          isSearching: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isSearching: false, searchError: e.toString()));
    }
  }

  Future<void> _onClearSearch(ClearSearch event, Emitter<AppState> emit) async {
    emit(
      state.copyWith(
        searchedUsers: [],
        searchedPosts: [],
        searchQuery: null,
        searchError: null,
      ),
    );
  }
}
