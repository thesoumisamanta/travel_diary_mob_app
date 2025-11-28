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
  final Function(String commentId, String username)? onReply;
  final bool isReply;
  final int depth;
  final String rootCommentId;

  const CommentItem({
    super.key,
    required this.comment,
    this.onReply,
    this.isReply = false,
    this.depth = 0,
    String? rootCommentId,
  }) : rootCommentId = rootCommentId ?? '';

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool _showReplies = false;

  @override
Widget build(BuildContext context) {
  return BlocBuilder<AppBloc, AppState>(
    builder: (context, state) {
      // ✅ Find the most up-to-date version of this comment
      CommentModel updatedComment = widget.comment;

      // Search in main comments first
      try {
        updatedComment = state.comments.firstWhere(
          (c) => c.id == widget.comment.id,
        );
      } catch (_) {
        // Not in main comments, search in replies
        for (var repliesList in state.replies.values) {
          try {
            updatedComment = repliesList.firstWhere(
              (c) => c.id == widget.comment.id,
            );
            break;
          } catch (_) {}
        }
      }

      // ✅ Debug log the state
      if (updatedComment.isLiked || updatedComment.isDisliked) {
        print('💬 Comment ${updatedComment.id}: isLiked=${updatedComment.isLiked}, isDisliked=${updatedComment.isDisliked}');
      }

      final leftPadding = (widget.depth > 0 ? (widget.depth * 24.0).clamp(0, 72) : 12.0);
      final actualRootId = widget.rootCommentId.isEmpty ? widget.comment.id : widget.rootCommentId;

      return Padding(
        padding: EdgeInsets.only(
          left: leftPadding.toDouble(),
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
                  radius: widget.depth > 0 ? 16 : 18,
                  backgroundImage: updatedComment.author.profilePicture != null &&
                          updatedComment.author.profilePicture!.isNotEmpty
                      ? CachedNetworkImageProvider(
                          updatedComment.author.profilePicture!,
                        )
                      : null,
                  child: updatedComment.author.profilePicture == null ||
                          updatedComment.author.profilePicture!.isEmpty
                      ? Text(
                          updatedComment.author.username.isNotEmpty
                              ? updatedComment.author.username[0].toUpperCase()
                              : '?',
                          style: TextStyle(fontSize: widget.depth > 0 ? 12 : 14),
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
                          Flexible(
                            child: Text(
                              updatedComment.author.username,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
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
                      // ✅ Action buttons
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          // ✅ Like button
                          InkWell(
                            onTap: () {
                              print('👍 Tapping like on comment: ${updatedComment.id}');
                              context.read<AppBloc>().add(
                                    LikeComment(updatedComment.id),
                                  );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  updatedComment.isLiked
                                      ? Icons.thumb_up
                                      : Icons.thumb_up_outlined,
                                  size: 16,
                                  color: updatedComment.isLiked
                                      ? const Color(0xFF1976D2)  // ✅ Explicit blue color
                                      : AppColors.textSecondary,
                                ),
                                if (updatedComment.likesCount > 0) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    updatedComment.likesCount.toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: updatedComment.isLiked
                                          ? FontWeight.w700
                                          : FontWeight.normal,
                                      color: updatedComment.isLiked
                                          ? const Color(0xFF1976D2)  // ✅ Explicit blue color
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // ✅ Dislike button
                          InkWell(
                            onTap: () {
                              print('👎 Tapping dislike on comment: ${updatedComment.id}');
                              context.read<AppBloc>().add(
                                    DislikeComment(updatedComment.id),
                                  );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  updatedComment.isDisliked
                                      ? Icons.thumb_down
                                      : Icons.thumb_down_outlined,
                                  size: 16,
                                  color: updatedComment.isDisliked
                                      ? const Color(0xFFD32F2F)  // ✅ Explicit red color
                                      : AppColors.textSecondary,
                                ),
                                if (updatedComment.dislikesCount > 0) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    updatedComment.dislikesCount.toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: updatedComment.isDisliked
                                          ? FontWeight.w700
                                          : FontWeight.normal,
                                      color: updatedComment.isDisliked
                                          ? const Color(0xFFD32F2F)  // ✅ Explicit red color
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Reply button
                          if (widget.onReply != null)
                            InkWell(
                              onTap: () {
                                widget.onReply!(
                                  updatedComment.id,
                                  updatedComment.author.username,
                                );
                              },
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
                          if (updatedComment.replyCount > 0 && widget.depth == 0)
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _showReplies = !_showReplies;
                                });
                                
                                if (_showReplies) {
                                  print('📂 Loading replies for comment: ${updatedComment.id}');
                                  context.read<AppBloc>().add(
                                        LoadCommentReplies(
                                          updatedComment.id,
                                          refresh: true,
                                        ),
                                      );
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
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
                                    '${updatedComment.replyCount} ${updatedComment.replyCount == 1 ? 'Reply' : 'Replies'}',
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Replies section
            if (_showReplies && widget.depth == 0) ...[
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
      return Padding(
        padding: EdgeInsets.only(left: 24.0 * (widget.depth + 1), top: 8, bottom: 8),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (replies.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort replies by creation time (oldest first - FCFS)
    final sortedReplies = List<CommentModel>.from(replies)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return Column(
      children: sortedReplies.map((reply) {
        return CommentItem(
          comment: reply,
          isReply: true,
          depth: widget.depth + 1,
          onReply: widget.onReply,
          rootCommentId: widget.rootCommentId.isEmpty ? commentId : widget.rootCommentId,
        );
      }).toList(),
    );
  }
}