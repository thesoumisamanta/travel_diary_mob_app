import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../business_logic/app_bloc/app_bloc.dart';
import '../../../business_logic/app_bloc/app_event.dart';
import '../../../data/models/story_model.dart';


class StoryViewerScreen extends StatefulWidget {
  final List<StoryModel> stories;
  final int initialIndex;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    this.initialIndex = 0,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _animationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );
    _startStoryTimer();
    _markStoryAsViewed();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startStoryTimer() {
    _animationController.forward();
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _markStoryAsViewed() {
    context.read<AppBloc>().add(ViewStory(widget.stories[_currentIndex].id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Story Content
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _animationController.reset();
              });
              _startStoryTimer();
              _markStoryAsViewed();
            },
            itemCount: widget.stories.length,
            itemBuilder: (context, index) {
              final story = widget.stories[index];
              return CachedNetworkImage(
                imageUrl: story.mediaUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    const Center(
                  child: Icon(
                    Icons.error,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          // Progress Bars
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 12,
                left: 8,
                right: 8,
              ),
              child: Row(
                children: List.generate(
                  widget.stories.length,
                  (index) => Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: index == _currentIndex
                          ? AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return LinearProgressIndicator(
                                  value: _animationController.value,
                                  backgroundColor: Colors.transparent,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                );
                              },
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: index < _currentIndex
                                    ? Colors.white
                                    : Colors.white30,
                                borderRadius:
                                    BorderRadius.circular(2),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Close Button & User Info
          Positioned(
            top: 48,
            left: 16,
            right: 16,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: CachedNetworkImageProvider(
                    widget.stories[_currentIndex].author
                        .profilePicture ??
                        '',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget
                            .stories[_currentIndex]
                            .author
                            .username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${(DateTime.now().difference(widget.stories[_currentIndex].createdAt).inMinutes)} minutes ago',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Click Areas for Navigation
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _previousStory,
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _nextStory,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}