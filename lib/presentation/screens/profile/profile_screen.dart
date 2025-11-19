import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_diary_mob_app/business_logic/app_bloc/app_bloc.dart';
import 'package:travel_diary_mob_app/business_logic/auth_bloc/auth_bloc.dart';
import 'package:travel_diary_mob_app/business_logic/auth_bloc/auth_event.dart';

import '../../../business_logic/app_bloc/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: const Text('Edit Profile'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
              PopupMenuItem(
                value: 'settings',
                child: const Text('Settings'),
                onTap: () {
                  // Navigate to settings
                },
              ),
              PopupMenuItem(
                value: 'logout',
                child: const Text('Logout'),
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          final user = state.currentUser;

          if (user == null) {
            return const Center(
              child: Text('No user data'),
            );
          }

          return CustomScrollView(
            slivers: [
              // Profile Header
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Cover Image
                    Container(
                      height: 150,
                      width: double.infinity,
                      color: AppColors.primary.withOpacity(0.1),
                      child: user.coverPicture != null
                          ? CachedNetworkImage(
                              imageUrl: user.coverPicture!,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image, size: 48),
                    ),
                    // Profile Info
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage:
                                    user.profilePicture != null
                                        ? CachedNetworkImageProvider(
                                            user.profilePicture!)
                                        : null,
                                child: user.profilePicture == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 50,
                                      )
                                    : null,
                              ),
                              if (user.isVerified)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding:
                                        const EdgeInsets.all(4),
                                    decoration:
                                        const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.verified,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Text(
                                user.username,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          if (user.fullName != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              user.fullName!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium,
                            ),
                          ],
                          if (user.bio != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              user.bio!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall,
                            ),
                          ],
                          if (user.website != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.link,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  user.website!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color:
                                            AppColors.primary,
                                      ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 16),
                          // Stats
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceEvenly,
                            children: [
                              _buildStatColumn(
                                context,
                                user.postsCount
                                    .toString(),
                                'Posts',
                              ),
                              _buildStatColumn(
                                context,
                                user.followersCount
                                    .toString(),
                                'Followers',
                              ),
                              _buildStatColumn(
                                context,
                                user.followingCount
                                    .toString(),
                                'Following',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Account Type Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: user.accountType
                                          .toString() ==
                                      'AccountType.business'
                                  ? AppColors.accent
                                  : AppColors.primary,
                              borderRadius:
                                  BorderRadius.circular(16),
                            ),
                            child: Text(
                              user.accountType
                                          .toString() ==
                                      'AccountType.business'
                                  ? 'Business Account'
                                  : 'Personal Account',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Tabs
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                flexibleSpace: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(icon: Icon(Icons.grid_3x3), text: 'Posts'),
                    Tab(
                      icon: Icon(Icons.bookmark_outline),
                      text: 'Saved',
                    ),
                  ],
                ),
              ),
              // Posts Grid
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPostsGrid(context, state),
                    _buildSavedGrid(context),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(
    BuildContext context,
    String count,
    String label,
  ) {
    return Column(
      children: [
        Text(
          count,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildPostsGrid(
    BuildContext context,
    AppState state,
  ) {
    if (state.userPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image_outlined,
              size: 48,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 12),
            Text(
              'No posts yet',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: state.userPosts.length,
      itemBuilder: (context, index) {
        final post = state.userPosts[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: post.media.first.url,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppColors.shimmerBase,
            ),
            errorWidget: (context, url, error) =>
                const Icon(Icons.error),
          ),
        );
      },
    );
  }

  Widget _buildSavedGrid(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.bookmark_outline,
            size: 48,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 12),
          Text(
            'No saved posts',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout?',
        ),
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
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}