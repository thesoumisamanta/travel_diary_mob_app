import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:travel_diary_mob_app/presentation/screens/home/widgets/video_post_player.dart';
import 'package:video_player/video_player.dart';
import 'package:travel_diary_mob_app/business_logic/app_bloc/app_state.dart';
import 'package:travel_diary_mob_app/presentation/screens/post/post_details_screen.dart';
import '../../../../business_logic/app_bloc/app_bloc.dart';
import '../../../../business_logic/app_bloc/app_event.dart';
import '../../../../data/models/post_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../widgets/loading_widget.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    // Only initialize video for video posts
    if (widget.post.isVideoPost && widget.post.primaryMediaUrl != null) {
      _videoController =
          VideoPlayerController.networkUrl(
              Uri.parse(widget.post.primaryMediaUrl!),
            )
            ..initialize()
                .then((_) {
                  if (mounted) {
                    setState(() {
                      _isVideoInitialized = true;
                    });
                    // Auto-play video
                    _videoController?.play();
                    _videoController?.setLooping(true);
                  }
                })
                .catchError((error) {
                  debugPrint('Video initialization error: $error');
                });

      // Add listener for video progress
      _videoController?.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_videoController != null && _isVideoInitialized) {
      setState(() {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
        } else {
          _videoController!.play();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      buildWhen: (previous, current) {
        final prevPost = previous.feedPosts.firstWhere(
          (p) => p.id == widget.post.id,
          orElse: () => widget.post,
        );
        final currPost = current.feedPosts.firstWhere(
          (p) => p.id == widget.post.id,
          orElse: () => widget.post,
        );

        return prevPost.isLiked != currPost.isLiked ||
            prevPost.isDisliked != currPost.isDisliked ||
            prevPost.likesCount != currPost.likesCount ||
            prevPost.dislikesCount != currPost.dislikesCount;
      },
      builder: (context, state) {
        final updatedPost = state.feedPosts.firstWhere(
          (p) => p.id == widget.post.id,
          orElse: () => widget.post,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (updatedPost.media.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildMediaSection(updatedPost),
            ],
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      buildUserAvatar(updatedPost.author.profilePicture),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (updatedPost.caption != null)
                              Text(
                                updatedPost.caption!,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            Row(
                              children: [
                                Text(
                                  updatedPost.author.fullName,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                if (updatedPost.author.isVerified) ...[
                                  const Icon(
                                    Icons.verified,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: AppColors.border,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormatter.formatRelativeTime(
                                    updatedPost.createdAt,
                                  ),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.read<AppBloc>().add(
                                  LikePost(updatedPost.id),
                                );
                              },
                              child: Icon(
                                updatedPost.isLiked
                                    ? Icons.thumb_up
                                    : Icons.thumb_up_outlined,
                                color: updatedPost.isLiked
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              updatedPost.likesCount.toString(),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () {
                                context.read<AppBloc>().add(
                                  DislikePost(updatedPost.id),
                                );
                              },
                              child: Icon(
                                updatedPost.isDisliked
                                    ? Icons.thumb_down
                                    : Icons.thumb_down_outlined,
                                color: updatedPost.isDisliked
                                    ? AppColors.error
                                    : AppColors.textSecondary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              updatedPost.dislikesCount.toString(),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () async {
                                // Navigate to post details
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PostDetailScreen(post: updatedPost),
                                  ),
                                );

                                // ✅ CRITICAL: When user comes back, reload ENTIRE feed from backend
                                if (mounted) {
                                  print(
                                    '🔄 Returned from post details - Refreshing feed from backend...',
                                  );
                                  context.read<AppBloc>().add(
                                    LoadFeed(refresh: true),
                                  );
                                }
                              },
                              child: const Icon(
                                Icons.chat_bubble_outline,
                                color: AppColors.textSecondary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              updatedPost.commentsCount.toString(),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () {
                                // Share implementation
                              },
                              child: const Icon(
                                Icons.share_outlined,
                                color: AppColors.textSecondary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              updatedPost.sharesCount.toString(),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'save',
                            child: Text('Save Post'),
                          ),
                          const PopupMenuItem(
                            value: 'download',
                            child: Text('Download'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (updatedPost.location != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          updatedPost.location!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMediaSection(PostModel post) {
    // Handle VIDEO posts
    if (post.isVideoPost) {
      // Handle VIDEO posts
      if (post.isVideoPost) {
        return VideoPostPlayer(
          videoUrl: post.primaryMediaUrl ?? '',
          autoPlay: true,
        );

        // return GestureDetector(
        //   onTap: () {
        //     Navigator.of(context).push(
        //       MaterialPageRoute(
        //         builder: (context) => PostDetailScreen(post: post),
        //       ),
        //     );
        //   },
        //   child: Stack(
        //     children: [
        //       Container(
        //         height: 300,
        //         width: double.infinity,
        //         color: Colors.black,
        //         child: _isVideoInitialized && _videoController != null
        //             ? AspectRatio(
        //                 aspectRatio: _videoController!.value.aspectRatio,
        //                 child: VideoPlayer(_videoController!),
        //               )
        //             : const Center(
        //                 child: CircularProgressIndicator(color: Colors.white),
        //               ),
        //       ),
        //       // Video progress bar
        //       if (_isVideoInitialized && _videoController != null)
        //         Positioned(
        //           bottom: 0,
        //           left: 0,
        //           right: 0,
        //           child: VideoProgressIndicator(
        //             _videoController!,
        //             allowScrubbing: true,
        //             padding: const EdgeInsets.all(0),
        //             colors: const VideoProgressColors(
        //               playedColor: AppColors.primary,
        //               bufferedColor: Colors.grey,
        //               backgroundColor: Colors.white24,
        //             ),
        //           ),
        //         ),
        //       // Play/Pause overlay (optional - for tap feedback)
        //       if (_isVideoInitialized && _videoController != null)
        //         Positioned.fill(
        //           child: GestureDetector(
        //             onTap: _togglePlayPause,
        //             child: Container(
        //               color: Colors.transparent,
        //               child: Center(
        //                 child: AnimatedOpacity(
        //                   opacity: _videoController!.value.isPlaying ? 0.0 : 1.0,
        //                   duration: const Duration(milliseconds: 200),
        //                   child: Container(
        //                     padding: const EdgeInsets.all(12),
        //                     decoration: const BoxDecoration(
        //                       color: Colors.black54,
        //                       shape: BoxShape.circle,
        //                     ),
        //                     child: const Icon(
        //                       Icons.play_arrow,
        //                       color: Colors.white,
        //                       size: 48,
        //                     ),
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ),
        //     ],
        //   ),
        // );
      }
    }

    // Handle IMAGE posts (existing code)
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)),
        );
      },
      child: SizedBox(
        height: 300,
        width: double.infinity,
        child: post.media.length == 1
            ? CachedNetworkImage(
                imageUrl: post.media.first.url,
                fit: BoxFit.cover,
                placeholder: (context, url) => const LoadingWidget(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )
            : PageView.builder(
                itemCount: post.media.length,
                itemBuilder: (context, index) => CachedNetworkImage(
                  imageUrl: post.media[index].url,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const LoadingWidget(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
      ),
    );
  }

  Widget buildUserAvatar(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return CircleAvatar(
        backgroundColor: AppColors.primary,
        child: Text(
          widget.post.author.username[0].toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: avatarUrl,
      imageBuilder: (context, imageProvider) =>
          CircleAvatar(backgroundImage: imageProvider),
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => CircleAvatar(
        backgroundColor: AppColors.primary,
        child: Text(
          widget.post.author.username[0].toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
