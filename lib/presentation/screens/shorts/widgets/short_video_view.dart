import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_diary_mob_app/business_logic/app_bloc/app_bloc.dart';
import 'package:travel_diary_mob_app/business_logic/app_bloc/app_event.dart';
import 'package:travel_diary_mob_app/business_logic/app_bloc/app_state.dart';
import 'package:travel_diary_mob_app/core/theme/app_colors.dart';
import 'package:video_player/video_player.dart';
import '../../../../data/models/post_model.dart';

class ShortVideoView extends StatefulWidget {
  final PostModel post;

  const ShortVideoView({
    super.key,
    required this.post,
  });

  @override
  State<ShortVideoView> createState() => _ShortVideoViewState();
}

class _ShortVideoViewState extends State<ShortVideoView> {
  late VideoPlayerController _controller;
  bool isPaused = false;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    final videoUrl = widget.post.primaryMediaUrl ?? '';
    if (videoUrl.isEmpty) return;

    _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() => isInitialized = true);
          _controller.play();
          _controller.setLooping(true);
        }
      }).catchError((error) {
        debugPrint('Video initialization error: $error');
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void togglePlayback() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        isPaused = true;
      } else {
        _controller.play();
        isPaused = false;
      }
    });
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      buildWhen: (previous, current) {
        // Rebuild when like/dislike state changes for this specific short
        final prevShort = previous.shorts.firstWhere(
          (p) => p.id == widget.post.id,
          orElse: () => widget.post,
        );
        final currShort = current.shorts.firstWhere(
          (p) => p.id == widget.post.id,
          orElse: () => widget.post,
        );

        return prevShort.isLiked != currShort.isLiked ||
            prevShort.isDisliked != currShort.isDisliked ||
            prevShort.likesCount != currShort.likesCount ||
            prevShort.dislikesCount != currShort.dislikesCount;
      },
      builder: (context, state) {
        // Get the updated short from state
        final updatedShort = state.shorts.firstWhere(
          (p) => p.id == widget.post.id,
          orElse: () => widget.post,
        );

        return Stack(
          children: [
            /// FULL SCREEN VIDEO
            GestureDetector(
              onTap: togglePlayback,
              child: SizedBox.expand(
                child: isInitialized
                    ? FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller.value.size.width,
                          height: _controller.value.size.height,
                          child: VideoPlayer(_controller),
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
              ),
            ),

            /// PAUSE ICON ANIMATION
            if (isPaused)
              Center(
                child: AnimatedOpacity(
                  opacity: isPaused ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.pause_circle_filled,
                    color: Colors.white70,
                    size: 90,
                  ),
                ),
              ),

            /// GRADIENT BOTTOM OVERLAY
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 180,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black87],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            /// USERNAME + TITLE (FLOATING)
            Positioned(
              left: 16,
              bottom: 40,
              right: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "@${updatedShort.author.username}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    updatedShort.caption ?? updatedShort.title ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            /// RIGHT SIDE FLOATING ICONS
            Positioned(
              right: 16,
              bottom: 40,
              child: Column(
                children: [
                  // LIKE BUTTON
                  GestureDetector(
                    onTap: () {
                      context.read<AppBloc>().add(
                            LikePost(updatedShort.id),
                          );
                    },
                    child: Column(
                      children: [
                        Icon(
                          updatedShort.isLiked
                              ? Icons.thumb_up
                              : Icons.thumb_up_outlined,
                          color: updatedShort.isLiked
                              ? AppColors.primary
                              : Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCount(updatedShort.likesCount),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // DISLIKE BUTTON
                  GestureDetector(
                    onTap: () {
                      context.read<AppBloc>().add(
                            DislikePost(updatedShort.id),
                          );
                    },
                    child: Column(
                      children: [
                        Icon(
                          updatedShort.isDisliked
                              ? Icons.thumb_down
                              : Icons.thumb_down_outlined,
                          color: updatedShort.isDisliked
                              ? AppColors.error
                              : Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCount(updatedShort.dislikesCount),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // COMMENTS BUTTON
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to comments or show comment sheet
                    },
                    child: Column(
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCount(updatedShort.commentsCount),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // SHARE BUTTON
                  GestureDetector(
                    onTap: () {
                      // TODO: Handle share
                    },
                    child: Column(
                      children: [
                        const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Share",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}