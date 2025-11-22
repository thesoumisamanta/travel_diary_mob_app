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
  static const String uploadPosts = '/posts/upload';
  static const String userPost = '/posts';
  static const String allPosts = '/posts/user';
  static const String listPosts = '/posts/list';
  static const String getFeed = '/posts/feed/following';
  static const String likePost = '/posts';
  static const String dislikePost = '/posts';

  // Comment endpoints
  static const String commentPost = '/comments';

  // Search endpoints - NEW
  static const String searchUsers = '/search/users';
  static const String searchPosts = '/search/posts';
  static const String searchAll = '/search/all';
  static const String searchContent = '/search/all';
  static const String getShorts = '/search/shorts';


  // Story endpoints
  static const String stories = '/stories';
  static const String createStory = '/stories/create';
  static const String viewStory = '/stories/view'; // + /:storyId

  // Chat endpoints
  static const String chats = '/chats';
  static const String getChatHistory = '/chats/history'; // + /:chatId
  static const String sendMessage = '/chats/send';

  // Media Upload
  static const String uploadMedia = '/upload/media';
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);}