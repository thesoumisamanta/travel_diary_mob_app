import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../data/models/story_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../story/story_viewer_screen.dart';

class StoryCard extends StatelessWidget {
  final StoryGroupModel storyGroup;

  const StoryCard({Key? key, required this.storyGroup}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasUnviewed = storyGroup.hasUnviewedStories;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StoryViewerScreen(stories: storyGroup.stories),
          ),
        );
      },
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasUnviewed ? AppColors.primary : AppColors.border,
            width: hasUnviewed ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: CachedNetworkImage(
                imageUrl: storyGroup.stories.first.mediaUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  color: AppColors.cardBackground,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: CircleAvatar(
                radius: 12,
                backgroundImage:
                    storyGroup.user.profilePicture != null
                        ? CachedNetworkImageProvider(
                            storyGroup.user.profilePicture!)
                        : null,
                child: storyGroup.user.profilePicture == null
                    ? const Icon(Icons.person, size: 12)
                    : null,
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                storyGroup.user.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}