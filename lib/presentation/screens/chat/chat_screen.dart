import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../business_logic/app_bloc/app_bloc.dart';
import '../../../business_logic/app_bloc/app_event.dart';
import '../../../business_logic/app_bloc/app_state.dart';
import '../../../data/models/chat_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';

class ChatScreen extends StatefulWidget {
  final ChatModel chat;

  const ChatScreen({Key? key, required this.chat}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    context.read<AppBloc>().add(LoadChatHistory(widget.chat.id));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      context.read<AppBloc>().add(
            SendMessage(
              widget.chat.participant.id,
              _messageController.text.trim(),
              'text',
            ),
          );
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.chat.participant.username),
            Text(
              widget.chat.isOnline ? 'Active now' : 'Offline',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'call',
                child: const Text('Voice Call'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Initiating voice call...'),
                    ),
                  );
                },
              ),
              PopupMenuItem(
                value: 'video',
                child: const Text('Video Call'),
                onTap: () {
                  if (widget.chat.participant.isFollowing &&
                      widget.chat.participant.isFollowingMe) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Initiating video call...'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Both users need to follow each other for video calls',
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
              ),
              PopupMenuItem(
                value: 'info',
                child: const Text('View Profile'),
                onTap: () {
                  // Navigate to profile
                },
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<AppBloc, AppState>(
              builder: (context, state) {
                if (state.isLoadingMessages && state.messages.isEmpty) {
                  return const LoadingWidget();
                }

                if (state.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.message_outlined,
                          size: 48,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No messages yet',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Start a conversation',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    final isOwn = message.senderId == 'currentUserId';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: isOwn
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isOwn) ...[
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: widget.chat.participant.profilePicture != null
                                  ? CachedNetworkImageProvider(
                                      widget.chat.participant.profilePicture!)
                                  : null,
                              child: widget.chat.participant.profilePicture == null
                                  ? const Icon(Icons.person, size: 12)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isOwn
                                    ? AppColors.primary
                                    : AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: isOwn
                                    ? null
                                    : Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: isOwn
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (message.content != null)
                                    Text(
                                      message.content!,
                                      style: TextStyle(
                                        color: isOwn
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  if (message.mediaUrl != null) ...[
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: message.mediaUrl!,
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormatter.formatTime(message.createdAt),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isOwn
                                          ? Colors.white70
                                          : AppColors.textHint,
                                    ),
                                  ),
                                  if (isOwn) ...[
                                    const SizedBox(height: 2),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (message.status == MessageStatus.sent)
                                          const Icon(Icons.done, size: 12, color: Colors.white70),
                                        if (message.status == MessageStatus.delivered)
                                          const Icon(Icons.done_all, size: 12, color: Colors.white70),
                                        if (message.status == MessageStatus.read)
                                          const Icon(Icons.done_all, size: 12, color: Colors.blue),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    // Show options for media
                  },
                ),
                Expanded(
                  child: CustomTextField(
                    controller: _messageController,
                    hint: 'Type a message...',
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}