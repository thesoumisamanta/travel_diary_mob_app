import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:travel_diary_mob_app/business_logic/app_bloc/app_bloc.dart';
import 'package:travel_diary_mob_app/business_logic/app_bloc/app_event.dart';
import 'package:travel_diary_mob_app/business_logic/app_bloc/app_state.dart';
import 'package:travel_diary_mob_app/core/theme/app_colors.dart';
import 'package:travel_diary_mob_app/core/utils/date_formatter.dart';
import 'package:travel_diary_mob_app/data/models/comment_model.dart';

class CommentItem extends StatefulWidget {
  final CommentModel comment;
  final VoidCallback? onReply;
  final bool isReply;

  const CommentItem({
    super.key,
    required this.comment,
    this.onReply,
    this.isReply = false,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool _showReplies = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        // Find updated comment from state
        CommentModel updatedComment = widget.comment;

        // Look in main comments list
        try {
          updatedComment = state.comments.firstWhere(
            (c) => c.id == widget.comment.id,
          );
        } catch (e) {
          // If not found in main comments, look in replies
          for (var repliesList in state.replies.values) {
            try {
              updatedComment = repliesList.firstWhere(
                (c) => c.id == widget.comment.id,
              );
              break;
            } catch (_) {}
          }
        }

        return Padding(
          padding: EdgeInsets.only(
            left: widget.isReply ? 48.0 : 12.0,
            right: 12.0,
            top: 12.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 18,
                    backgroundImage:
                        updatedComment.author.profilePicture != null
                        ? CachedNetworkImageProvider(
                            updatedComment.author.profilePicture!,
                          )
                        : null,
                    child: updatedComment.author.profilePicture == null
                        ? Text(
                            updatedComment.author.username[0].toUpperCase(),
                            style: const TextStyle(fontSize: 14),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Comment content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Author and time
                        Row(
                          children: [
                            Text(
                              updatedComment.author.username,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            if (updatedComment.author.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ],
                            const SizedBox(width: 8),
                            Text(
                              DateFormatter.formatRelativeTime(
                                updatedComment.createdAt,
                              ),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            if (updatedComment.isEdited) ...[
                              const SizedBox(width: 4),
                              const Text(
                                '(edited)',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Comment text
                        Text(
                          updatedComment.content,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        // Action buttons
                        Row(
                          children: [
                            // Like button
                            InkWell(
                              onTap: () {
                                context.read<AppBloc>().add(
                                  LikeComment(updatedComment.id),
                                );
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    updatedComment.isLiked
                                        ? Icons.thumb_up
                                        : Icons.thumb_up_outlined,
                                    size: 16,
                                    color: updatedComment.isLiked
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    updatedComment.likesCount.toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: updatedComment.isLiked
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Dislike button
                            InkWell(
                              onTap: () {
                                context.read<AppBloc>().add(
                                  DislikeComment(updatedComment.id),
                                );
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    updatedComment.isDisliked
                                        ? Icons.thumb_down
                                        : Icons.thumb_down_outlined,
                                    size: 16,
                                    color: updatedComment.isDisliked
                                        ? AppColors.error
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    updatedComment.dislikesCount.toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: updatedComment.isDisliked
                                          ? AppColors.error
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Reply button
                            if (widget.onReply != null)
                              InkWell(
                                onTap: widget.onReply,
                                child: const Text(
                                  'Reply',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            // Show replies button
                            if (updatedComment.replyCount > 0 &&
                                !widget.isReply) ...[
                              const SizedBox(width: 16),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _showReplies = !_showReplies;
                                  });
                                  if (_showReplies) {
                                    context.read<AppBloc>().add(
                                      LoadCommentReplies(
                                        updatedComment.id,
                                        refresh: true,
                                      ),
                                    );
                                  }
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      _showReplies
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${updatedComment.replyCount} ${updatedComment.replyCount == 1 ? 'reply' : 'replies'}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Replies section
              if (_showReplies && !widget.isReply) ...[
                const SizedBox(height: 8),
                _buildRepliesSection(state, updatedComment.id),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRepliesSection(AppState state, String commentId) {
    final replies = state.replies[commentId] ?? [];

    if (state.isLoadingReplies && replies.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      children: replies.map((reply) {
        return CommentItem(
          comment: reply,
          isReply: true,
          onReply: () {
            // Handle reply to reply - can show input with @username
          },
        );
      }).toList(),
    );
  }
}
