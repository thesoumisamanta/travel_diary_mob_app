import 'package:flutter/material.dart';
import 'package:travel_diary_mob_app/core/theme/app_colors.dart';
import 'package:video_player/video_player.dart';

class VideoPostPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;

  const VideoPostPlayer({
    super.key,
    required this.videoUrl,
    this.autoPlay = true,
  });

  @override
  State<VideoPostPlayer> createState() => _VideoPostPlayerState();
}

class _VideoPostPlayerState extends State<VideoPostPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    )..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          if (widget.autoPlay) {
            _controller.play();
            _controller.setLooping(true);
          }
        }
      }).catchError((error) {
        debugPrint('Video initialization error: $error');
      });

    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _showControls = !_controller.value.isPlaying;
    });

    // Hide controls after 2 seconds
    if (!_controller.value.isPlaying) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _controller.value.isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 300,
          width: double.infinity,
          color: Colors.black,
          child: _isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
        ),
        // Progress bar at the bottom
        if (_isInitialized)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Time display
                if (_showControls)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    color: Colors.black54,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_controller.value.position),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatDuration(_controller.value.duration),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Progress indicator
                VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  padding: const EdgeInsets.all(0),
                  colors: const VideoProgressColors(
                    playedColor: AppColors.primary,
                    bufferedColor: Colors.grey,
                    backgroundColor: Colors.white24,
                  ),
                ),
              ],
            ),
          ),
        // Play/Pause button overlay
        Positioned.fill(
          child: GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _showControls || !_controller.value.isPlaying
                      ? 1.0
                      : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}