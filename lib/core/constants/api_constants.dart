class ApiConstants {
  static const String baseUrl = 'https://api.traveldiaryapp.com/api/v1';
  
  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  
  // User Endpoints
  static const String users = '/users';
  static const String userProfile = '/users/profile';
  static const String updateProfile = '/users/update';
  static const String followUser = '/users/follow';
  static const String unfollowUser = '/users/unfollow';
  static const String followers = '/users/followers';
  static const String following = '/users/following';
  
  // Post Endpoints
  static const String posts = '/posts';
  static const String createPost = '/posts/create';
  static const String updatePost = '/posts/update';
  static const String deletePost = '/posts/delete';
  static const String likePost = '/posts/like';
  static const String unlikePost = '/posts/unlike';
  static const String commentPost = '/posts/comment';
  static const String feed = '/posts/feed';
  
  // Story Endpoints
  static const String stories = '/stories';
  static const String createStory = '/stories/create';
  static const String viewStory = '/stories/view';
  
  // Chat Endpoints
  static const String chats = '/chats';
  static const String sendMessage = '/chats/send';
  static const String getChatHistory = '/chats/history';
  
  // Search Endpoints
  static const String searchUsers = '/search/users';
  static const String searchPosts = '/search/posts';
  static const String searchContent = '/search/content';
  
  // Media Upload
  static const String uploadMedia = '/media/upload';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}