import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../business_logic/app_bloc/app_bloc.dart';
import '../../../business_logic/app_bloc/app_event.dart';
import '../../../business_logic/app_bloc/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    if (query.isEmpty) {
      context.read<AppBloc>().add(ClearSearch());
      return;
    }

    final selectedIndex = _tabController.index;
    if (selectedIndex == 0) {
      context.read<AppBloc>().add(SearchUsers(query));
    } else if (selectedIndex == 1) {
      context.read<AppBloc>().add(SearchPosts(query));
    } else {
      context.read<AppBloc>().add(SearchContent(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomTextField(
              controller: _searchController,
              hint: 'Search travel diary',
              prefixIcon: const Icon(Icons.search),
              onChanged: _handleSearch,
            ),
          ),
          // Tabs
          TabBar(
            controller: _tabController,
            onTap: (_) {
              _handleSearch(_searchController.text);
            },
            tabs: const [
              Tab(text: 'Users'),
              Tab(text: 'Posts'),
              Tab(text: 'All'),
            ],
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUsersTab(),
                _buildPostsTab(),
                _buildAllTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (state.searchQuery == null || state.searchQuery!.isEmpty) {
          return _buildEmptyState('Search for users');
        }

        if (state.isSearching) {
          return const LoadingWidget();
        }

        if (state.searchedUsers.isEmpty) {
          return _buildEmptyState('No users found');
        }

        return ListView.builder(
          itemCount: state.searchedUsers.length,
          itemBuilder: (context, index) {
            final user = state.searchedUsers[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: user.profilePicture != null
                    ? CachedNetworkImageProvider(
                        user.profilePicture!)
                    : null,
                child: user.profilePicture == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Row(
                children: [
                  Text(user.username),
                  if (user.isVerified) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ],
              ),
              subtitle: Text(user.bio ?? ''),
              trailing: ElevatedButton(
                onPressed: () {
                  if (user.isFollowing) {
                    context.read<AppBloc>().add(UnfollowUser(user.id));
                  } else {
                    context.read<AppBloc>().add(FollowUser(user.id));
                  }
                },
                child: Text(
                  user.isFollowing ? 'Following' : 'Follow',
                ),
              ),
              onTap: () {
                context.read<AppBloc>().add(LoadUserProfile(user.id));
                // Navigate to profile
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPostsTab() {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (state.searchQuery == null || state.searchQuery!.isEmpty) {
          return _buildEmptyState('Search for posts');
        }

        if (state.isSearching) {
          return const LoadingWidget();
        }

        if (state.searchedPosts.isEmpty) {
          return _buildEmptyState('No posts found');
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: state.searchedPosts.length,
          itemBuilder: (context, index) {
            final post = state.searchedPosts[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: post.media.first.url,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: AppColors.shimmerBase),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.favorite,
                            size: 12,
                            color: AppColors.like,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.likesCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
    );
  }

  Widget _buildAllTab() {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (state.searchQuery == null || state.searchQuery!.isEmpty) {
          return _buildEmptyState('Search for users and posts');
        }

        if (state.isSearching) {
          return const LoadingWidget();
        }

        if (state.searchedUsers.isEmpty &&
            state.searchedPosts.isEmpty) {
          return _buildEmptyState('No results found');
        }

        return CustomScrollView(
          slivers: [
            if (state.searchedUsers.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Users',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final user = state.searchedUsers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.profilePicture != null
                            ? CachedNetworkImageProvider(
                                user.profilePicture!)
                            : null,
                        child: user.profilePicture == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(user.username),
                      subtitle: Text(user.bio ?? ''),
                      trailing: ElevatedButton(
                        onPressed: () {
                          if (user.isFollowing) {
                            context
                                .read<AppBloc>()
                                .add(UnfollowUser(user.id));
                          } else {
                            context
                                .read<AppBloc>()
                                .add(FollowUser(user.id));
                          }
                        },
                        child: Text(
                          user.isFollowing
                              ? 'Following'
                              : 'Follow',
                        ),
                      ),
                    );
                  },
                  childCount: state.searchedUsers.length,
                ),
              ),
            ],
            if (state.searchedPosts.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Posts',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = state.searchedPosts[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: post.media.first.url,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(
                              color: AppColors.shimmerBase,
                            ),
                        errorWidget:
                            (context, url, error) =>
                                const Icon(Icons.error),
                      ),
                    );
                  },
                  childCount: state.searchedPosts.length,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search,
            size: 48,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}