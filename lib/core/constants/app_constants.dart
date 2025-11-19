class AppConstants {
  // App Info
  static const String appName = 'Travel Diary';
  static const String appVersion = '1.0.0';
  
  // Account Types
  static const String personalAccount = 'personal';
  static const String businessAccount = 'business';
  
  // Post Types
  static const String postTypeImage = 'image';
  static const String postTypeVideo = 'video';
  static const String postTypeShort = 'short';
  
  // Story Duration
  static const Duration storyDuration = Duration(seconds: 15);
  
  // Pagination
  static const int postsPerPage = 20;
  static const int commentsPerPage = 50;
  
  // File Limits
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  static const int maxVideoSize = 100 * 1024 * 1024; // 100MB
  static const int maxImagesPerPost = 10;
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxUsernameLength = 30;
  static const int maxBioLength = 500;
  static const int maxCaptionLength = 2000;
  
  // Agora Configuration
  static const String agoraAppId = 'YOUR_AGORA_APP_ID';
  
  // Socket Events
  static const String socketConnect = 'connect';
  static const String socketDisconnect = 'disconnect';
  static const String socketNewMessage = 'new_message';
  static const String socketTyping = 'typing';
  static const String socketOnline = 'user_online';
  static const String socketOffline = 'user_offline';
}