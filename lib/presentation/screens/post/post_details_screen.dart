import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:travel_diary_mob_app/presentation/screens/post/widgets/comment_item.dart';
import '../../../business_logic/app_bloc/app_bloc.dart';
import '../../../business_logic/app_bloc/app_event.dart';
import '../../../business_logic/app_bloc/app_state.dart';
import '../../../data/models/post_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _commentController;
  final FocusNode _commentFocusNode = FocusNode();
  int _currentMediaIndex = 0;
  
  // Reply state
  String? _replyingToCommentId;
  String? _replyingToUsername;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _commentController = TextEditingController();
    context.read<AppBloc>().add(LoadPostDetails(widget.post.id));
    context.read<AppBloc>().add(LoadComments(widget.post.id, refresh: true));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _handleReply(String commentId, String username) {
    setState(() {
      _replyingToCommentId = commentId;
      _replyingToUsername = username;
    });
    _commentFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToUsername = null;
    });
    _commentController.clear();
  }

  void _handleAddComment() {
    if (_commentController.text.trim().isNotEmpty) {
      if (_replyingToCommentId != null) {
        // Adding a reply
        context.read<AppBloc>().add(
              AddComment(
                widget.post.id,
                _commentController.text.trim(),
                parentId: _replyingToCommentId,
              ),
            );
      } else {
        // Adding a top-level comment
        context.read<AppBloc>().add(
              AddComment(widget.post.id, _commentController.text.trim()),
            );
      }
      _commentController.clear();
      _cancelReply();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          final post = state.selectedPost ?? widget.post;

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // Media Section
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          if (post.media.isNotEmpty)
                            SizedBox(
                              height: 400,
                              child: PhotoViewGallery.builder(
                                itemCount: post.media.length,
                                pageController: PageController(
                                  initialPage: _currentMediaIndex,
                                ),
                                onPageChanged: (index) {
                                  setState(() => _currentMediaIndex = index);
                                },
                                builder: (context, index) {
                                  return PhotoViewGalleryPageOptions(
                                    imageProvider: CachedNetworkImageProvider(
                                      post.media[index].url,
                                    ),
                                    minScale:
                                        PhotoViewComputedScale.contained * 0.8,
                                    maxScale:
                                        PhotoViewComputedScale.covered * 1.8,
                                  );
                                },
                              ),
                            ),
                          // Author Info
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundImage: post.author
                                                  .profilePicture !=
                                              null
                                          ? CachedNetworkImageProvider(
                                              post.author.profilePicture!,
                                            )
                                          : null,
                                      child:
                                          post.author.profilePicture == null
                                              ? const Icon(Icons.person)
                                              : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                post.author.username,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              if (post.author.isVerified) ...[
                                                const SizedBox(width: 4),
                                                const Icon(
                                                  Icons.verified,
                                                  size: 16,
                                                  color: AppColors.primary,
                                                ),
                                              ],
                                            ],
                                          ),
                                          Text(
                                            post.author.bio ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Follow/Unfollow
                                      },
                                      child: Text(
                                        post.author.isFollowing
                                            ? 'Following'
                                            : 'Follow',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (post.caption != null)
                                  Text(
                                    post.caption!,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                if (post.location != null) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        post.location!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                                if (post.tags.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: post.tags
                                        .map(
                                          (tag) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              '#$tag',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: AppColors.primary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                // Stats
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            post.likesCount.toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          Text(
                                            'Likes',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            post.commentsCount.toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          Text(
                                            'Comments',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            post.sharesCount.toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          Text(
                                            'Shares',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Comments Section Header
                    SliverAppBar(
                      pinned: true,
                      automaticallyImplyLeading: false,
                      title: Text('Comments (${state.comments.length})'),
                      centerTitle: false,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    // Comments List
                    if (state.isLoadingComments && state.comments.isEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: LoadingWidget()),
                        ),
                      )
                    else if (state.comments.isEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'No comments yet. Be the first to comment!',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final comment = state.comments[index];
                            return CommentItem(
                              comment: comment,
                              onReply: _handleReply,
                            );
                          },
                          childCount: state.comments.length,
                        ),
                      ),
                    // Bottom padding for input
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 80),
                    ),
                  ],
                ),
              ),
              // Add Comment Input (Fixed at bottom)
              _buildCommentInput(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reply indicator
            if (_replyingToUsername != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.reply,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                          children: [
                            const TextSpan(text: 'Replying to '),
                            TextSpan(
                              text: '@$_replyingToUsername',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _cancelReply,
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            if (_replyingToUsername != null) const SizedBox(height: 8),
            // Comment input
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _commentController,
                    focusNode: _commentFocusNode,
                    hint: _replyingToUsername != null
                        ? 'Write your reply...'
                        : 'Add a comment...',
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _handleAddComment,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}