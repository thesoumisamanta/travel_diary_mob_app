import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../business_logic/app_bloc/app_bloc.dart';
import '../../../business_logic/app_bloc/app_event.dart';
import '../../../business_logic/app_bloc/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../widgets/loading_widget.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AppBloc>().add(LoadChats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
      ),
      body: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          if (state.isLoadingChats) {
            return const LoadingWidget();
          }

          if (state.chats.isEmpty) {
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
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: state.chats.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1),
            itemBuilder: (context, index) {
              final chat = state.chats[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(chat: chat),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: chat.unreadCount > 0
                      ? AppColors.primary.withOpacity(0.05)
                      : Colors.transparent,
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: chat.participant
                                        .profilePicture !=
                                    null
                                ? CachedNetworkImageProvider(
                                    chat.participant
                                        .profilePicture!)
                                : null,
                            child: chat.participant
                                        .profilePicture ==
                                    null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          if (chat.isOnline)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white,
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              chat.participant.username,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight:
                                        chat.unreadCount > 0
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            if (chat.lastMessage != null) ...[
                              Text(
                                chat.lastMessage!.content ??
                                    '${chat.lastMessage!.type.toString().split('.').last}',
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: chat.unreadCount >
                                              0
                                          ? AppColors
                                              .textPrimary
                                          : AppColors
                                              .textSecondary,
                                      fontWeight: chat
                                                  .unreadCount >
                                              0
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.end,
                        children: [
                          Text(
                            chat.lastMessage != null
                                ? DateFormatter
                                    .formatChatTime(
                                    chat.lastMessage!
                                        .createdAt)
                                : '',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall,
                          ),
                          if (chat.unreadCount > 0) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: AppColors
                                    .primary,
                                borderRadius:
                                    BorderRadius
                                        .circular(10),
                              ),
                              child: Text(
                                chat.unreadCount
                                    .toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}