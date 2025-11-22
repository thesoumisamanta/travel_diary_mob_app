import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ShortVideoView extends StatefulWidget {
  final String videoUrl;
  final String username;
  final String title;

  const ShortVideoView({
    super.key,
    required this.videoUrl,
    required this.username,
    required this.title,
  });

  @override
  State<ShortVideoView> createState() => _ShortVideoViewState();
}

class _ShortVideoViewState extends State<ShortVideoView> {
  late VideoPlayerController _controller;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        _controller.play();
        _controller.setLooping(true);
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void togglePlayback() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      isPaused = true;
    } else {
      _controller.play();
      isPaused = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// FULL SCREEN VIDEO — NO CARD
        GestureDetector(
          onTap: togglePlayback,
          child: SizedBox.expand(
            child: _controller.value.isInitialized
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "@${widget.username}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 250,
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),

        /// RIGHT SIDE FLOATING ICONS (NO CARD)
        Positioned(
          right: 16,
          bottom: 40,
          child: Column(
            children: [
              actionButton(Icons.favorite_outline, "11k"),
              const SizedBox(height: 20),
              actionButton(Icons.chat_bubble_outline, "234"),
              const SizedBox(height: 20),
              actionButton(Icons.send_rounded, "Share"),
            ],
          ),
        ),
      ],
    );
  }

  Widget actionButton(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
