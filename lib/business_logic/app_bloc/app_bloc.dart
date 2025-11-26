import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_diary_mob_app/data/models/comment_model.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/post_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/post_repository.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/search_repository.dart';
import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final UserRepository userRepository;
  final PostRepository postRepository;
  final ChatRepository chatRepository;
  final SearchRepository searchRepository;

  AppBloc({
    required this.userRepository,
    required this.postRepository,
    required this.chatRepository,
    required this.searchRepository,
  }) : super(const AppState()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<FollowUser>(_onFollowUser);
    on<UnfollowUser>(_onUnfollowUser);
    on<LoadFeed>(_onLoadFeed);
    on<LoadUserPosts>(_onLoadUserPosts);
    on<LoadPostDetails>(_onLoadPostDetails);
    on<CreatePost>(_onCreatePost);
    on<LikePost>(_onLikePost);
    on<DislikePost>(_onDislikePost);
    on<LoadShorts>(_onLoadShorts);
    on<LoadComments>(_onLoadComments);
    on<AddComment>(_onAddComment);
    on<DeleteComment>(_onDeleteComment);
    on<LikeComment>(_onLikeComment);
    on<DislikeComment>(_onDislikeComment);
    on<LoadCommentReplies>(_onLoadCommentReplies);
    on<LoadStories>(_onLoadStories);
    on<CreateStory>(_onCreateStory);
    on<ViewStory>(_onViewStory);
    on<LoadChats>(_onLoadChats);
    on<LoadChatHistory>(_onLoadChatHistory);
    on<SendMessage>(_onSendMessage);
    on<ReceiveMessage>(_onReceiveMessage);
    on<SearchUsers>(_onSearchUsers);
    on<SearchPosts>(_onSearchPosts);
    on<SearchContent>(_onSearchContent);
    on<ClearSearch>(_onClearSearch);
    on<RealtimeSearch>(_onRealtimeSearch);
  }

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
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingUser: false, userError: e.toString()));
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
        filterType: event.filterType,
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
      final posts = await postRepository.getUserPosts(
        event.userId,
        1,
        filterType: event.filterType,
      );
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
    // Determine post type
    PostType postType;
    if (event.postType == 'short') {
      postType = PostType.short;
    } else if (event.postType == 'video') {
      postType = PostType.video;
    } else {
      postType = PostType.image;
    }

    print('BLoC: Uploading ${event.mediaFiles.length} files as ${event.postType}');
    print('BLoC: Caption: ${event.caption}');
    print('BLoC: Tags: ${event.tags}');

    // Upload post with media directly
    final post = await postRepository.uploadPostWithMedia(
      mediaFiles: event.mediaFiles,
      postType: postType,
      title: event.caption.isNotEmpty ? event.caption : 'Untitled Post',
      caption: event.caption.isNotEmpty ? event.caption : null,
      location: event.location,
      tags: event.tags,
    );

    print('BLoC: Post created successfully: ${post.id}');

    emit(
      state.copyWith(
        feedPosts: [post, ...state.feedPosts],
        isUploading: false,
        uploadProgress: 1.0,
      ),
    );
  } catch (e, stackTrace) {
    print('BLoC: Create post error: $e');
    print('Stack trace: $stackTrace');
    emit(state.copyWith(
      isUploading: false, 
      uploadError: 'Failed to upload post: ${e.toString()}',
    ));
  }
}

  Future<void> _onLoadShorts(LoadShorts event, Emitter<AppState> emit) async {
    if (event.refresh) {
      emit(
        state.copyWith(
          isLoadingShorts: true,
          currentShortsPage: 1,
          shortsError: null,
        ),
      );
    } else if (!state.hasMoreShorts || state.isLoadingShorts) {
      return;
    } else {
      emit(state.copyWith(isLoadingShorts: true, shortsError: null));
    }

    try {
      final shorts = await postRepository.getShorts(
        event.refresh ? 1 : state.currentShortsPage,
      );
      emit(
        state.copyWith(
          shorts: event.refresh ? shorts : [...state.shorts, ...shorts],
          isLoadingShorts: false,
          hasMoreShorts: shorts.isNotEmpty,
          currentShortsPage: event.refresh ? 2 : state.currentShortsPage + 1,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingShorts: false, shortsError: e.toString()));
    }
  }

  Future<void> _onLikePost(LikePost event, Emitter<AppState> emit) async {
    final originalFeedPosts = List<PostModel>.from(state.feedPosts);
    final originalShorts = List<PostModel>.from(state.shorts);
    final originalSelectedPost = state.selectedPost;

    // Find post in feed or shorts
    final currentPost = state.feedPosts.firstWhere(
      (p) => p.id == event.postId,
      orElse: () => state.shorts.firstWhere(
        (p) => p.id == event.postId,
        orElse: () => state.selectedPost!,
      ),
    );

    final wasLiked = currentPost.isLiked;
    final wasDisliked = currentPost.isDisliked;

    // Update feed posts optimistically
    final optimisticFeedPosts = state.feedPosts.map((post) {
      if (post.id == event.postId) {
        if (wasLiked) {
          return post.copyWith(isLiked: false, likesCount: post.likesCount - 1);
        } else {
          return post.copyWith(
            isLiked: true,
            isDisliked: false,
            likesCount: post.likesCount + 1,
            dislikesCount: wasDisliked
                ? post.dislikesCount - 1
                : post.dislikesCount,
          );
        }
      }
      return post;
    }).toList();

    // Update shorts optimistically
    final optimisticShorts = state.shorts.map((post) {
      if (post.id == event.postId) {
        if (wasLiked) {
          return post.copyWith(isLiked: false, likesCount: post.likesCount - 1);
        } else {
          return post.copyWith(
            isLiked: true,
            isDisliked: false,
            likesCount: post.likesCount + 1,
            dislikesCount: wasDisliked
                ? post.dislikesCount - 1
                : post.dislikesCount,
          );
        }
      }
      return post;
    }).toList();

    emit(
      state.copyWith(feedPosts: optimisticFeedPosts, shorts: optimisticShorts),
    );

    try {
      final backendData = await postRepository.likePost(event.postId);

      // Confirm with backend data
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

      final confirmedShorts = state.shorts.map((post) {
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

      emit(
        state.copyWith(feedPosts: confirmedFeedPosts, shorts: confirmedShorts),
      );
    } catch (e) {
      emit(
        state.copyWith(
          feedPosts: originalFeedPosts,
          shorts: originalShorts,
          selectedPost: originalSelectedPost,
          postError: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDislikePost(DislikePost event, Emitter<AppState> emit) async {
    final originalFeedPosts = List<PostModel>.from(state.feedPosts);
    final originalShorts = List<PostModel>.from(state.shorts);

    // Find post in feed or shorts
    final currentPost = state.feedPosts.firstWhere(
      (p) => p.id == event.postId,
      orElse: () => state.shorts.firstWhere(
        (p) => p.id == event.postId,
        orElse: () => state.selectedPost!,
      ),
    );

    final wasLiked = currentPost.isLiked;
    final wasDisliked = currentPost.isDisliked;

    // Update feed posts optimistically
    final optimisticFeedPosts = state.feedPosts.map((post) {
      if (post.id == event.postId) {
        if (wasDisliked) {
          return post.copyWith(
            isDisliked: false,
            dislikesCount: post.dislikesCount - 1,
          );
        } else {
          return post.copyWith(
            isDisliked: true,
            isLiked: false,
            dislikesCount: post.dislikesCount + 1,
            likesCount: wasLiked ? post.likesCount - 1 : post.likesCount,
          );
        }
      }
      return post;
    }).toList();

    // Update shorts optimistically
    final optimisticShorts = state.shorts.map((post) {
      if (post.id == event.postId) {
        if (wasDisliked) {
          return post.copyWith(
            isDisliked: false,
            dislikesCount: post.dislikesCount - 1,
          );
        } else {
          return post.copyWith(
            isDisliked: true,
            isLiked: false,
            dislikesCount: post.dislikesCount + 1,
            likesCount: wasLiked ? post.likesCount - 1 : post.likesCount,
          );
        }
      }
      return post;
    }).toList();

    emit(
      state.copyWith(feedPosts: optimisticFeedPosts, shorts: optimisticShorts),
    );

    try {
      final backendData = await postRepository.dislikePost(event.postId);

      // Confirm with backend data
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

      final confirmedShorts = state.shorts.map((post) {
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

      emit(
        state.copyWith(feedPosts: confirmedFeedPosts, shorts: confirmedShorts),
      );
    } catch (e) {
      emit(
        state.copyWith(
          feedPosts: originalFeedPosts,
          shorts: originalShorts,
          postError: e.toString(),
        ),
      );
    }
  }

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

  // Replace the _onAddComment method in app_bloc.dart with this version

  Future<void> _onAddComment(AddComment event, Emitter<AppState> emit) async {
    try {
      final comment = await postRepository.addComment(
        event.postId,
        event.content,
        parentId: event.parentId,
      );

      if (event.parentId == null) {
        // It's a top-level comment
        emit(state.copyWith(comments: [comment, ...state.comments]));

        // Update comment count in feedPosts
        final updatedFeedPosts = state.feedPosts.map((post) {
          if (post.id == event.postId) {
            return post.copyWith(commentsCount: post.commentsCount + 1);
          }
          return post;
        }).toList();

        // Update comment count in selectedPost if it matches
        final updatedSelectedPost = state.selectedPost?.id == event.postId
            ? state.selectedPost?.copyWith(
                commentsCount: (state.selectedPost?.commentsCount ?? 0) + 1,
              )
            : state.selectedPost;

        emit(
          state.copyWith(
            feedPosts: updatedFeedPosts,
            selectedPost: updatedSelectedPost,
          ),
        );
      } else {
        // It's a reply (to a comment or another reply)
        final updatedReplies = Map<String, List<CommentModel>>.from(
          state.replies,
        );

        // Find which root comment this reply belongs to
        String? rootCommentId;

        // Check if the parent is a main comment
        final isParentMainComment = state.comments.any(
          (c) => c.id == event.parentId,
        );

        if (isParentMainComment) {
          // Parent is a main comment, this is a direct reply
          rootCommentId = event.parentId;
        } else {
          // Parent is a reply, find its root comment
          for (var entry in state.replies.entries) {
            if (entry.value.any((r) => r.id == event.parentId)) {
              rootCommentId = entry.key;
              break;
            }
          }
        }

        if (rootCommentId != null) {
          // Add the new reply to the root comment's replies list
          final currentReplies = updatedReplies[rootCommentId] ?? [];
          updatedReplies[rootCommentId] = [...currentReplies, comment];

          // Update the root comment's reply count in the main comments list
          final updatedComments = state.comments.map((c) {
            if (c.id == rootCommentId) {
              return c.copyWith(replyCount: c.replyCount + 1);
            }
            return c;
          }).toList();

          emit(
            state.copyWith(replies: updatedReplies, comments: updatedComments),
          );
        }
      }
    } catch (e) {
      emit(state.copyWith(commentError: e.toString()));
    }
  }

  // Replace the _onDeleteComment method in app_bloc.dart with this version

  Future<void> _onDeleteComment(
    DeleteComment event,
    Emitter<AppState> emit,
  ) async {
    try {
      // Find the comment being deleted
      CommentModel? deletedComment;
      String? rootCommentId;
      bool isMainComment = false;
      int totalRepliesCount = 0;

      // Check if it's a main comment
      try {
        deletedComment = state.comments.firstWhere(
          (c) => c.id == event.commentId,
        );
        isMainComment = true;
        totalRepliesCount = deletedComment.replyCount;
      } catch (e) {
        // Not a main comment, search in replies
        for (var entry in state.replies.entries) {
          try {
            deletedComment = entry.value.firstWhere(
              (r) => r.id == event.commentId,
            );
            rootCommentId = entry.key;

            // Count how many replies this comment has (for nested deletes)
            final repliesUnderThis = entry.value
                .where((r) => r.parentId == event.commentId)
                .length;
            totalRepliesCount = repliesUnderThis;
            break;
          } catch (_) {}
        }
      }

      // Call backend to delete
      await postRepository.deleteComment(event.commentId);

      if (isMainComment) {
        // Remove from main comments list
        final updatedComments = state.comments
            .where((c) => c.id != event.commentId)
            .toList();

        // Remove all its replies from replies map
        final updatedReplies = Map<String, List<CommentModel>>.from(
          state.replies,
        );
        updatedReplies.remove(event.commentId);

        // Update comment count in posts (decrease by 1 + all its replies)
        final updatedFeedPosts = state.feedPosts.map((post) {
          // You might need to track which post this comment belongs to
          // For now, we'll just return the post as-is
          return post;
        }).toList();

        emit(
          state.copyWith(
            comments: updatedComments,
            replies: updatedReplies,
            feedPosts: updatedFeedPosts,
          ),
        );
      } else if (rootCommentId != null) {
        // Remove from replies list
        final updatedReplies = Map<String, List<CommentModel>>.from(
          state.replies,
        );
        updatedReplies[rootCommentId] = updatedReplies[rootCommentId]!
            .where((r) => r.id != event.commentId)
            .toList();

        // Also remove any nested replies under this comment
        updatedReplies[rootCommentId] = updatedReplies[rootCommentId]!
            .where((r) => r.parentId != event.commentId)
            .toList();

        // Update the root comment's reply count (decrease by 1 + nested replies)
        final updatedComments = state.comments.map((c) {
          if (c.id == rootCommentId) {
            return c.copyWith(
              replyCount: (c.replyCount - 1 - totalRepliesCount)
                  .clamp(0, double.infinity)
                  .toInt(),
            );
          }
          return c;
        }).toList();

        emit(
          state.copyWith(replies: updatedReplies, comments: updatedComments),
        );
      }
    } catch (e) {
      emit(state.copyWith(commentError: e.toString()));
    }
  }

  Future<void> _onLikeComment(LikeComment event, Emitter<AppState> emit) async {
    try {
      final backendData = await postRepository.likeComment(event.commentId);

      // Update in main comments
      final updatedComments = state.comments.map((comment) {
        if (comment.id == event.commentId) {
          return comment.copyWith(
            isLiked: backendData['isLiked'],
            isDisliked: backendData['isDisliked'],
            likesCount: backendData['likesCount'],
            dislikesCount: backendData['dislikesCount'],
          );
        }
        return comment;
      }).toList();

      // Update in replies
      final updatedReplies = Map<String, List<CommentModel>>.from(
        state.replies,
      );
      for (var key in updatedReplies.keys) {
        updatedReplies[key] = updatedReplies[key]!.map((reply) {
          if (reply.id == event.commentId) {
            return reply.copyWith(
              isLiked: backendData['isLiked'],
              isDisliked: backendData['isDisliked'],
              likesCount: backendData['likesCount'],
              dislikesCount: backendData['dislikesCount'],
            );
          }
          return reply;
        }).toList();
      }

      emit(state.copyWith(comments: updatedComments, replies: updatedReplies));
    } catch (e) {
      emit(state.copyWith(commentError: e.toString()));
    }
  }

  Future<void> _onDislikeComment(
    DislikeComment event,
    Emitter<AppState> emit,
  ) async {
    try {
      final backendData = await postRepository.dislikeComment(event.commentId);

      // Update in main comments
      final updatedComments = state.comments.map((comment) {
        if (comment.id == event.commentId) {
          return comment.copyWith(
            isLiked: backendData['isLiked'],
            isDisliked: backendData['isDisliked'],
            likesCount: backendData['likesCount'],
            dislikesCount: backendData['dislikesCount'],
          );
        }
        return comment;
      }).toList();

      // Update in replies
      final updatedReplies = Map<String, List<CommentModel>>.from(
        state.replies,
      );
      for (var key in updatedReplies.keys) {
        updatedReplies[key] = updatedReplies[key]!.map((reply) {
          if (reply.id == event.commentId) {
            return reply.copyWith(
              isLiked: backendData['isLiked'],
              isDisliked: backendData['isDisliked'],
              likesCount: backendData['likesCount'],
              dislikesCount: backendData['dislikesCount'],
            );
          }
          return reply;
        }).toList();
      }

      emit(state.copyWith(comments: updatedComments, replies: updatedReplies));
    } catch (e) {
      emit(state.copyWith(commentError: e.toString()));
    }
  }

  // Replace the _onLoadCommentReplies method in app_bloc.dart with this version

  Future<void> _onLoadCommentReplies(
    LoadCommentReplies event,
    Emitter<AppState> emit,
  ) async {
    if (event.refresh) {
      emit(
        state.copyWith(
          isLoadingReplies: true,
          currentRepliesPage: 1,
          repliesError: null,
        ),
      );
    } else if (state.isLoadingReplies) {
      return;
    } else {
      emit(state.copyWith(isLoadingReplies: true, repliesError: null));
    }

    try {
      final page = event.refresh ? 1 : state.currentRepliesPage;
      final replies = await postRepository.getCommentReplies(
        event.commentId,
        page,
      );

      final currentReplies = state.replies[event.commentId] ?? [];
      final updatedReplies = Map<String, List<CommentModel>>.from(
        state.replies,
      );

      // If refreshing, replace all replies, otherwise append
      updatedReplies[event.commentId] = event.refresh
          ? replies
          : [...currentReplies, ...replies];

      emit(
        state.copyWith(
          replies: updatedReplies,
          isLoadingReplies: false,
          currentRepliesPage: event.refresh ? 2 : state.currentRepliesPage + 1,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingReplies: false, repliesError: e.toString()));
    }
  }

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
      await postRepository.createStory({
        'media_url': mediaUrl,
        'type': event.storyType,
      });
      emit(state.copyWith(isUploading: false));
      add(LoadStories());
    } catch (e) {
      emit(state.copyWith(isUploading: false, uploadError: e.toString()));
    }
  }

  Future<void> _onViewStory(ViewStory event, Emitter<AppState> emit) async {
    try {
      await postRepository.viewStory(event.storyId);
    } catch (_) {}
  }

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
    } catch (_) {}
  }

  Future<void> _onSearchUsers(SearchUsers event, Emitter<AppState> emit) async {
    emit(
      state.copyWith(
        isSearching: true,
        searchQuery: event.query,
        searchError: null,
      ),
    );
    try {
      final users = await searchRepository.searchUsers(event.query, event.page);
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
      final posts = await searchRepository.searchPosts(
        event.query,
        event.page,
        filterType: event.filterType,
      );
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
      final result = await searchRepository.searchAll(event.query, event.page);
      emit(
        state.copyWith(
          searchedUsers: result.users,
          searchedPosts: result.posts,
          isSearching: false,
          hasMoreSearchResults: result.hasMore,
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

  Future<void> _onRealtimeSearch(
    RealtimeSearch event,
    Emitter<AppState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(
        state.copyWith(
          searchedUsers: [],
          searchedPosts: [],
          searchQuery: null,
          isSearching: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isSearching: true,
        searchQuery: event.query,
        searchError: null,
      ),
    );

    try {
      switch (event.filterType) {
        case SearchFilterType.users:
          final users = await searchRepository.searchUsers(event.query, 1);
          emit(
            state.copyWith(
              searchedUsers: users,
              searchedPosts: [],
              isSearching: false,
            ),
          );
          break;
        case SearchFilterType.videos:
          final posts = await searchRepository.searchVideos(event.query, 1);
          emit(
            state.copyWith(
              searchedPosts: posts,
              searchedUsers: [],
              isSearching: false,
            ),
          );
          break;
        case SearchFilterType.images:
          final posts = await searchRepository.searchImages(event.query, 1);
          emit(
            state.copyWith(
              searchedPosts: posts,
              searchedUsers: [],
              isSearching: false,
            ),
          );
          break;
        case SearchFilterType.shorts:
          final posts = await searchRepository.searchShorts(event.query, 1);
          emit(
            state.copyWith(
              searchedPosts: posts,
              searchedUsers: [],
              isSearching: false,
            ),
          );
          break;
        case SearchFilterType.posts:
          final posts = await searchRepository.searchPosts(event.query, 1);
          emit(
            state.copyWith(
              searchedPosts: posts,
              searchedUsers: [],
              isSearching: false,
            ),
          );
          break;
        case SearchFilterType.all:
          final result = await searchRepository.searchAll(event.query, 1);
          emit(
            state.copyWith(
              searchedUsers: result.users,
              searchedPosts: result.posts,
              isSearching: false,
            ),
          );
          break;
      }
    } catch (e) {
      emit(state.copyWith(isSearching: false, searchError: e.toString()));
    }
  }
}
