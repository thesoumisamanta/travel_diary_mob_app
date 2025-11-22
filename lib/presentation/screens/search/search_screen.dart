import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../business_logic/app_bloc/app_bloc.dart';
import '../../../business_logic/app_bloc/app_event.dart';
import '../../../business_logic/app_bloc/app_state.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/user_model.dart';
import '../../../core/theme/app_colors.dart';
import '../profile/profile_screen.dart';
import '../post/post_details_screen.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  
  const SearchScreen({super.key, this.onBackPressed});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  late TabController _tabController;
  SearchFilterType _currentFilter = SearchFilterType.all;

  final List<String> _tabs = ['All', 'Users', 'Videos', 'Images', 'Shorts'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    
    setState(() {
      switch (_tabController.index) {
        case 0: _currentFilter = SearchFilterType.all; break;
        case 1: _currentFilter = SearchFilterType.users; break;
        case 2: _currentFilter = SearchFilterType.videos; break;
        case 3: _currentFilter = SearchFilterType.images; break;
        case 4: _currentFilter = SearchFilterType.shorts; break;
      }
    });
    
    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      context.read<AppBloc>().add(ClearSearch());
      return;
    }
    context.read<AppBloc>().add(RealtimeSearch(query, filterType: _currentFilter));
  }

  void _navigateToUserProfile(UserModel user) {
    // Check if the user is viewing their own profile
    final currentUser = context.read<AppBloc>().state.currentUser;
    final isCurrentUser = currentUser != null && currentUser.id == user.id;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          userId: user.id,
          username: user.username,
          isCurrentUser: isCurrentUser, // Pass the correct flag
        ),
      ),
    );
  }

  void _navigateToPostDetail(PostModel post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(post: post),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar with Search
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      // Clear search and navigate back
                      _searchController.clear();
                      context.read<AppBloc>().add(ClearSearch());
                      if (widget.onBackPressed != null) {
                        widget.onBackPressed!();
                      }
                    },
                  ),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        style: const TextStyle(color: Colors.black87, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Search users, videos, images...',
                          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: Colors.grey[500]),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                    context.read<AppBloc>().add(ClearSearch());
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            // Tab Bar
            TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
            ),
            // Content
            Expanded(
              child: BlocBuilder<AppBloc, AppState>(
                builder: (context, state) {
                  if (state.isSearching) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.searchQuery == null || state.searchQuery!.isEmpty) {
                    return _buildEmptyState();
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAllResults(state),
                      _buildUserResults(state.searchedUsers),
                      _buildPostResults(state.searchedVideoPosts, PostType.video),
                      _buildPostResults(state.searchedImagePosts, PostType.image),
                      _buildPostResults(state.searchedShortPosts, PostType.short),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Search for users, videos, images, or shorts',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAllResults(AppState state) {
    final hasUsers = state.searchedUsers.isNotEmpty;
    final hasPosts = state.searchedPosts.isNotEmpty;

    if (!hasUsers && !hasPosts) {
      return _buildNoResults();
    }

    return ListView(
      children: [
        if (hasUsers) ...[
          _buildSectionHeader('Users', state.searchedUsers.length),
          ...state.searchedUsers.take(5).map((u) => _buildUserTile(u)),
          if (state.searchedUsers.length > 5)
            TextButton(
              onPressed: () => _tabController.animateTo(1),
              child: const Text('See all users'),
            ),
        ],
        if (hasPosts) ...[
          _buildSectionHeader('Posts', state.searchedPosts.length),
          _buildPostGrid(state.searchedPosts),
        ],
      ],
    );
  }

  Widget _buildUserResults(List<UserModel> users) {
    if (users.isEmpty) return _buildNoResults();
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) => _buildUserTile(users[index]),
    );
  }

  Widget _buildPostResults(List<PostModel> posts, PostType type) {
    if (posts.isEmpty) return _buildNoResults();
    
    if (type == PostType.short) {
      return _buildShortsGrid(posts);
    }
    return _buildPostGrid(posts);
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No results found', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text('($count)', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildUserTile(UserModel user) {
    // Check if this is the current user to show badge
    final currentUser = context.read<AppBloc>().state.currentUser;
    final isCurrentUser = currentUser != null && currentUser.id == user.id;
    
    return ListTile(
      onTap: () => _navigateToUserProfile(user),
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: user.profilePicture != null && user.profilePicture!.isNotEmpty
            ? CachedNetworkImageProvider(user.profilePicture!)
            : null,
        child: user.profilePicture == null || user.profilePicture!.isEmpty
            ? Text(user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              user.fullName,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (user.isVerified) ...[
            const SizedBox(width: 4),
            const Icon(Icons.verified, size: 16, color: AppColors.primary),
          ],
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'You',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        '@${user.username} • ${user.followersCount} followers',
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  Widget _buildPostGrid(List<PostModel> posts) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) => _buildPostThumbnail(posts[index]),
    );
  }

  Widget _buildShortsGrid(List<PostModel> posts) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 9 / 16,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) => _buildShortThumbnail(posts[index]),
    );
  }

  Widget _buildPostThumbnail(PostModel post) {
    String? thumbnailUrl;
    if (post.isVideoPost || post.isShortPost) {
      thumbnailUrl = post.thumbnailUrl ?? post.primaryMediaUrl;
    } else if (post.media.isNotEmpty) {
      thumbnailUrl = post.media.first.url;
    }

    return GestureDetector(
      onTap: () => _navigateToPostDetail(post),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: thumbnailUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: Colors.grey[300]),
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            )
          else
            Container(color: Colors.grey[300], child: const Icon(Icons.image, color: Colors.grey)),
          if (post.isVideoPost)
            Positioned(top: 4, right: 4, child: _buildTypeIcon(Icons.play_circle_fill)),
          if (post.media.length > 1)
            Positioned(top: 4, right: 4, child: _buildTypeIcon(Icons.collections)),
        ],
      ),
    );
  }

  Widget _buildShortThumbnail(PostModel post) {
    return GestureDetector(
      onTap: () => _navigateToPostDetail(post),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: post.thumbnailUrl ?? post.primaryMediaUrl ?? '',
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(color: Colors.grey[800]),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title ?? post.caption ?? '',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.play_arrow, color: Colors.white, size: 14),
                      Text(' ${post.viewsCount}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }
}