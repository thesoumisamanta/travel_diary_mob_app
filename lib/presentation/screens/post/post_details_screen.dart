import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../../business_logic/app_bloc/app_bloc.dart';
import '../../../business_logic/app_bloc/app_event.dart';
import '../../../business_logic/app_bloc/app_state.dart';
import '../../../data/models/post_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;

  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _commentController;
  int _currentMediaIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _commentController = TextEditingController();
    context.read<AppBloc>().add(LoadPostDetails(widget.post.id));
    context.read<AppBloc>().add(LoadComments(widget.post.id));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _handleAddComment() {
    if (_commentController.text.trim().isNotEmpty) {
      context.read<AppBloc>().add(
            AddComment(widget.post.id, _commentController.text.trim()),
          );
      _commentController.clear();
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

          return CustomScrollView(
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
                          pageController:
                              PageController(initialPage: _currentMediaIndex),
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
                                backgroundImage: post
                                        .author.profilePicture !=
                                    null
                                    ? CachedNetworkImageProvider(
                                        post.author
                                            .profilePicture!)
                                    : null,
                                child: post.author
                                            .profilePicture ==
                                        null
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
                                            color: AppColors
                                                .primary,
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      post.author.bio ?? '',
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow.ellipsis,
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium,
                            ),
                          if (post.location != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: AppColors
                                      .textSecondary,
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
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                      decoration:
                                          BoxDecoration(
                                        color: AppColors
                                            .primary
                                            .withOpacity(
                                                0.1),
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                                    16),
                                      ),
                                      child: Text(
                                        '#$tag',
                                        style: Theme.of(
                                                context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors
                                                  .primary,
                                              fontWeight:
                                                  FontWeight
                                                      .w500,
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
                                      post.likesCount
                                          .toString(),
                                      style: Theme.of(
                                              context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                    ),
                                    Text(
                                      'Likes',
                                      style: Theme.of(
                                              context)
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
                                      post.commentsCount
                                          .toString(),
                                      style: Theme.of(
                                              context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                    ),
                                    Text(
                                      'Comments',
                                      style: Theme.of(
                                              context)
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
                                      post.sharesCount
                                          .toString(),
                                      style: Theme.of(
                                              context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                    ),
                                    Text(
                                      'Shares',
                                      style: Theme.of(
                                              context)
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
              // Comments Section
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                title: const Text('Comments'),
                centerTitle: false,
              ),
              if (state.isLoadingComments)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: LoadingWidget(),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final comment = state.comments[index];
                      return Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: comment
                                          .author
                                          .profilePicture !=
                                      null
                                      ? CachedNetworkImageProvider(
                                          comment.author
                                              .profilePicture!)
                                      : null,
                                  child: comment
                                              .author
                                              .profilePicture ==
                                          null
                                      ? const Icon(
                                          Icons.person,
                                          size: 12,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        comment.author
                                            .username,
                                        style: Theme.of(
                                                context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight:
                                                  FontWeight
                                                      .w600,
                                            ),
                                      ),
                                      Text(
                                        DateFormatter
                                            .formatRelativeTime(
                                          comment
                                              .createdAt,
                                        ),
                                        style: Theme.of(
                                                context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              comment.content,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium,
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: state.comments.length,
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller:
                              _commentController,
                          hint: 'Add a comment...',
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _handleAddComment,
                        child: Container(
                          padding:
                              const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius:
                                BorderRadius.circular(
                                    8),
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}