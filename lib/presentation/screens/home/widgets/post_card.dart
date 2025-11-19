import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:travel_diary_mob_app/presentation/screens/post/post_details_screen.dart';
import '../../../../business_logic/app_bloc/app_bloc.dart';
import '../../../../business_logic/app_bloc/app_event.dart';
import '../../../../data/models/post_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../widgets/loading_widget.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: post.author.profilePicture != null
                      ? CachedNetworkImageProvider(post.author.profilePicture!)
                      : null,
                  child: post.author.profilePicture == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.author.username,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
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
                        DateFormatter.formatRelativeTime(post.createdAt),
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
                      value: 'report',
                      child: Text('Report'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Caption
          if (post.caption != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                post.caption!,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          // Media
          if (post.media.isNotEmpty) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PostDetailScreen(post: post),
                  ),
                );
              },
              child: SizedBox(
                height: 300,
                width: double.infinity,
                child: post.media.length == 1
                    ? CachedNetworkImage(
                        imageUrl: post.media.first.url,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const LoadingWidget(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      )
                    : PageView.builder(
                        itemCount: post.media.length,
                        itemBuilder: (context, index) =>
                            CachedNetworkImage(
                          imageUrl: post.media[index].url,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const LoadingWidget(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
              ),
            ),
          ],
          // Actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              context.read<AppBloc>().add(
                                    LikePost(post.id, post.isLiked),
                                  );
                            },
                            child: Icon(
                              post.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: post.isLiked
                                  ? AppColors.like
                                  : AppColors.textSecondary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.likesCount.toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PostDetailScreen(post: post),
                                ),
                              );
                            },
                            child: Icon(
                              Icons.chat_bubble_outline,
                              color: AppColors.textSecondary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.commentsCount.toString(),
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
                            post.sharesCount.toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Download implementation
                      },
                      child: const Icon(
                        Icons.download_outlined,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                if (post.location != null) ...[
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
                        post.location!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}