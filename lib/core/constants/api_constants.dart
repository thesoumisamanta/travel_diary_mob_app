class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';

  // User endpoints
  static const String userProfile = '/users/current';
  static const String updateProfile = '/users/update-account';
  static const String updateAvatar = '/users/avatar';
  static const String updateCoverImage = '/users/cover-image';
  static const String getUserChannel = '/users/channel'; // + /:username

  // Follow endpoints
  static const String followUser = '/follow/follow'; // + /:userId
  static const String unfollowUser = '/follow/unfollow'; // + /:userId
  static const String followers = '/follow/followers'; // + /:userId
  static const String following = '/follow/following'; // + /:userId
  static const String followStatus = '/follow/status'; // + /:userId

  // Post endpoints
  static const String posts = '/posts';
  static const String postFeed = '/posts/feed/following';
  static const String videofeed = '/videos/feed/following'; 
  static const String createPost = '/posts/upload';
  static const String updatePost = '/posts'; // + /:postId
  static const String deletePost = '/posts'; // + /:postId
  static const String likePost = '/posts'; // + /:postId/like
  static const String unlikePost = '/posts'; // + /:postId/like
  static const String userPosts = '/posts/user'; // + /:userId
  static const String searchPosts = '/posts/search';

  // Video endpoints
  static const String videos = '/videos';
  static const String videoFeed = '/videos/feed/following'; // Feed from followed users only
  static const String uploadVideo = '/videos/upload';
  static const String likeVideo = '/videos'; // + /:videoId/like
  static const String userVideos = '/videos/user'; // + /:userId
  static const String searchVideos = '/videos/search';

  // Comment endpoints
  static const String commentPost = '/comments'; // + /:postId

  // Story endpoints
  static const String stories = '/stories';
  static const String createStory = '/stories/create';
  static const String viewStory = '/stories/view'; // + /:storyId

  // Chat endpoints
  static const String chats = '/chats';
  static const String getChatHistory = '/chats/history'; // + /:chatId
  static const String sendMessage = '/chats/send';

  // Search endpoints
  static const String searchUsers = '/users/search';
  static const String searchContent = '/search/content';

  // Media Upload
  static const String uploadMedia = '/upload/media';
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);}