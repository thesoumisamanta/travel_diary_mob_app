import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../business_logic/app_bloc/app_bloc.dart';
import '../../../business_logic/app_bloc/app_event.dart';
import '../../../business_logic/app_bloc/app_state.dart';
import '../../../business_logic/auth_bloc/auth_bloc.dart';
import '../../../business_logic/auth_bloc/auth_event.dart';
import '../../../business_logic/auth_bloc/auth_state.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/post_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/loading_widget.dart';
import '../post/post_details_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  final String? username;
  final bool isCurrentUser;

  const ProfileScreen({
    super.key,
    this.userId,
    this.username,
    this.isCurrentUser = true,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserModel? _otherUser;
  List<PostModel> _otherUserPosts = [];
  bool _isLoadingOtherUser = false;
  String? _error;

  @override
void initState() {
  super.initState();
  _tabController = TabController(length: 3, vsync: this);

  if (widget.isCurrentUser) {
    // ✅ Load both user profile AND posts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔥 INIT: Loading current user profile and posts');
      final appBloc = context.read<AppBloc>();
      
      // Load user profile first
      appBloc.add(LoadUserProfile());
      
      // Wait a moment then load posts
      Future.delayed(const Duration(milliseconds: 100), () {
        final currentUser = appBloc.state.currentUser;
        if (currentUser != null) {
          print('✅ Current user exists: ${currentUser.username} (${currentUser.id})');
          // Load posts for current user
          appBloc.add(LoadUserPosts(currentUser.id, refresh: true));
        }
      });
    });
  } else {
    _loadOtherUserProfile();
  }
}

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  Future<void> _loadCurrentUserPosts() async {
    final state = context.read<AppBloc>().state;
    if (state.currentUser != null) {
      print('Loading posts for user: ${state.currentUser!.id}');
      context.read<AppBloc>().add(
        LoadUserPosts(state.currentUser!.id, refresh: true),
      );
    }
  }

  Future<void> _loadOtherUserProfile() async {
    setState(() {
      _isLoadingOtherUser = true;
      _error = null;
    });

    try {
      final userRepository = context.read<UserRepository>();

      if (widget.username != null) {
        final user = await userRepository.getUserChannel(widget.username!);

        final appBloc = context.read<AppBloc>();
        appBloc.add(LoadUserPosts(user.id, refresh: true));

        await Future.delayed(const Duration(milliseconds: 300));

        setState(() {
          _otherUser = user;
          _otherUserPosts = appBloc.state.userPosts;
          _isLoadingOtherUser = false;
        });
      } else if (widget.userId != null) {
        final appBloc = context.read<AppBloc>();
        appBloc.add(LoadUserPosts(widget.userId!, refresh: true));

        await Future.delayed(const Duration(milliseconds: 500));

        final state = appBloc.state;
        if (state.userPosts.isNotEmpty) {
          setState(() {
            _otherUser = state.userPosts.first.author;
            _otherUserPosts = state.userPosts;
            _isLoadingOtherUser = false;
          });
        } else {
          setState(() {
            _isLoadingOtherUser = false;
            _error = 'User not found';
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingOtherUser = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }


  void _handleFollow() {
    if (_otherUser != null) {
      if (_otherUser!.isFollowing) {
        context.read<AppBloc>().add(UnfollowUser(_otherUser!.id));
        setState(() {
          _otherUser = _otherUser!.copyWith(
            isFollowing: false,
            followersCount: _otherUser!.followersCount - 1,
          );
        });
      } else {
        context.read<AppBloc>().add(FollowUser(_otherUser!.id));
        setState(() {
          _otherUser = _otherUser!.copyWith(
            isFollowing: true,
            followersCount: _otherUser!.followersCount + 1,
          );
        });
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Saved Posts'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      },
      child: widget.isCurrentUser
          ? _buildCurrentUserProfile()
          : _buildOtherUserProfile(),
    );
  }

  Widget _buildCurrentUserProfile() {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        // ✅ ADD COMPREHENSIVE LOGGING
        print('═══════════════════════════════════════');
        print('🔍 BUILDING CURRENT USER PROFILE');
        print('isLoadingUser: ${state.isLoadingUser}');
        print('isLoadingPosts: ${state.isLoadingPosts}');
        print('currentUser: ${state.currentUser?.username}');
        print('currentUser.id: ${state.currentUser?.id}');
        print('userPosts.length: ${state.userPosts.length}');
        if (state.userPosts.isNotEmpty) {
          print('First post ID: ${state.userPosts.first.id}');
          print('First post author: ${state.userPosts.first.author.username}');
          print('First post type: ${state.userPosts.first.type}');
        }
        print('═══════════════════════════════════════');

        // Show loading only if user is null
        if (state.isLoadingUser && state.currentUser == null) {
          return const Scaffold(body: LoadingWidget());
        }

        final user = state.currentUser;
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load profile'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AppBloc>().add(LoadUserProfile());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // ✅ PASS userPosts from state - this should contain the current user's posts
        return _buildProfileScaffold(user, state.userPosts, true);
      },
    );
  }

  Widget _buildOtherUserProfile() {
    if (_isLoadingOtherUser) {
      return const Scaffold(body: LoadingWidget());
    }

    if (_error != null || _otherUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                _error ?? 'User not found',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadOtherUserProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return _buildProfileScaffold(_otherUser!, _otherUserPosts, false);
  }

  Widget _buildProfileScaffold(
    UserModel user,
    List<PostModel> posts,
    bool isCurrentUser,
  ) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              automaticallyImplyLeading: !isCurrentUser,
              leading: isCurrentUser
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
              actions: [
                if (isCurrentUser)
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: _showSettingsBottomSheet,
                    tooltip: 'Settings',
                  ),
                if (!isCurrentUser)
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'share',
                        child: Text('Share Profile'),
                      ),
                      const PopupMenuItem(
                        value: 'report',
                        child: Text('Report'),
                      ),
                      const PopupMenuItem(value: 'block', child: Text('Block')),
                    ],
                    onSelected: (value) {
                      // Handle menu actions
                    },
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (user.coverPicture != null &&
                        user.coverPicture!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: user.coverPicture!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    Container(color: Colors.black.withOpacity(0.3)),
                  ],
                ),
              ),
            ),
          ],
          body: Column(
            children: [
              _buildProfileHeader(user, isCurrentUser),
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(icon: Icon(Icons.grid_on)),
                  Tab(icon: Icon(Icons.video_library_outlined)),
                  Tab(icon: Icon(Icons.bookmark_border)),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPostsGrid(posts.where((p) => p.isImagePost).toList()),
                    _buildPostsGrid(
                      posts
                          .where((p) => p.isVideoPost || p.isShortPost)
                          .toList(),
                    ),
                    isCurrentUser
                        ? _buildSavedPosts()
                        : const Center(child: Text('Private')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // CRITICAL: Always show bottom navigation when opened from search
      bottomNavigationBar: isCurrentUser ? null : _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0, // No active tab since this is a standalone profile
      onTap: (index) {
        // Navigate back and switch to the appropriate tab
        Navigator.pop(context);
        // You might want to add a callback here to switch tabs in HomeScreen
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'Create',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message_outlined),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildProfileHeader(UserModel user, bool isCurrentUser) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      user.profilePicture != null &&
                          user.profilePicture!.isNotEmpty
                      ? CachedNetworkImageProvider(user.profilePicture!)
                      : null,
                  child:
                      user.profilePicture == null ||
                          user.profilePicture!.isEmpty
                      ? Text(
                          user.fullName.isNotEmpty
                              ? user.fullName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn(user.postsCount.toString(), 'Posts'),
                    _buildStatColumn(
                      user.followersCount.toString(),
                      'Followers',
                    ),
                    _buildStatColumn(
                      user.followingCount.toString(),
                      'Following',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (user.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
                Text(
                  '@${user.username}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                if (user.bio != null && user.bio!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(user.bio!, style: const TextStyle(fontSize: 14)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (isCurrentUser)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
                child: const Text('Edit Profile'),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleFollow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: user.isFollowing
                          ? Colors.grey[300]
                          : AppColors.primary,
                      foregroundColor: user.isFollowing
                          ? Colors.black
                          : Colors.white,
                    ),
                    child: Text(user.isFollowing ? 'Following' : 'Follow'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Navigate to chat
                    },
                    child: const Text('Message'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildPostsGrid(List<PostModel> posts) {
    final isLoading = context.watch<AppBloc>().state.isLoadingPosts;

    print('📊 _buildPostsGrid called with ${posts.length} posts, isLoading: $isLoading');

    if (isLoading && posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text('No posts yet', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('Posts loaded: ${posts.length}', 
              style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        String? thumbnailUrl;

        if (post.isVideoPost || post.isShortPost) {
          thumbnailUrl = post.thumbnailUrl ?? post.primaryMediaUrl;
        } else if (post.media.isNotEmpty) {
          thumbnailUrl = post.media.first.url;
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailScreen(post: post),
              ),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.error_outline, color: Colors.grey),
                  ),
                )
              else
                Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              if (post.isVideoPost || post.isShortPost)
                const Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              if (post.media.length > 1)
                const Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(Icons.collections, color: Colors.white, size: 20),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavedPosts() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No saved posts', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
