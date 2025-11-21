import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:travel_diary_mob_app/business_logic/app_bloc/app_state.dart';
import 'package:travel_diary_mob_app/presentation/screens/post/post_details_screen.dart';
import '../../../../business_logic/app_bloc/app_bloc.dart';
import '../../../../business_logic/app_bloc/app_event.dart';
import '../../../../data/models/post_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../widgets/loading_widget.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      buildWhen: (previous, current) {
        final prevPost = previous.feedPosts.firstWhere(
          (p) => p.id == post.id,
          orElse: () => post,
        );
        final currPost = current.feedPosts.firstWhere(
          (p) => p.id == post.id,
          orElse: () => post,
        );

        // Rebuild if like/dislike state or counts changed
        return prevPost.isLiked != currPost.isLiked ||
            prevPost.isDisliked != currPost.isDisliked ||
            prevPost.likesCount != currPost.likesCount ||
            prevPost.dislikesCount != currPost.dislikesCount;
      },
      builder: (context, state) {
        // Get the updated post from state
        final updatedPost = state.feedPosts.firstWhere(
          (p) => p.id == post.id,
          orElse: () => post,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (updatedPost.media.isNotEmpty) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PostDetailScreen(post: updatedPost),
                    ),
                  );
                },
                child: SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: updatedPost.media.length == 1
                      ? CachedNetworkImage(
                          imageUrl: updatedPost.media.first.url,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const LoadingWidget(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        )
                      : PageView.builder(
                          itemCount: updatedPost.media.length,
                          itemBuilder: (context, index) => CachedNetworkImage(
                            imageUrl: updatedPost.media[index].url,
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
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      buildUserAvatar(updatedPost.author.profilePicture),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (updatedPost.caption != null)
                            Text(
                              updatedPost.caption!,
                              style: TextStyle(
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
                                style: TextStyle(
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
                                SizedBox(width: 4),
                              ],
                              Container(
                                width: 4,
                                height: 4,
                                color: AppColors.border,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                DateFormatter.formatRelativeTime(
                                  updatedPost.createdAt,
                                ),
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.read<AppBloc>().add(
                                  LikePost(updatedPost.id, updatedPost.isLiked),
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

                            // COMMENTS BUTTON
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PostDetailScreen(post: updatedPost),
                                  ),
                                );
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

                            // SHARE BUTTON
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

  Widget buildUserAvatar(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return CircleAvatar(
        backgroundColor: AppColors.primary,
        child: Text(
          post.author.username[0].toUpperCase(),
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
          post.author.username[0].toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
