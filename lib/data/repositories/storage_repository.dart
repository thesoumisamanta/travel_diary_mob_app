import '../services/storage_service.dart';
import '../../core/constants/storage_constants.dart';

class StorageRepository {
  final StorageService _storageService;

  StorageRepository(this._storageService);

  // Token Management
  Future<void> saveAccessToken(String token) async {
    await _storageService.writeSecure(StorageConstants.accessToken, token);
  }

  Future<String?> getAccessToken() async {
    return await _storageService.readSecure(StorageConstants.accessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storageService.writeSecure(StorageConstants.refreshToken, token);
  }

  Future<String?> getRefreshToken() async {
    return await _storageService.readSecure(StorageConstants.refreshToken);
  }

  Future<void> deleteTokens() async {
    await _storageService.deleteSecure(StorageConstants.accessToken);
    await _storageService.deleteSecure(StorageConstants.refreshToken);
  }

  // User ID
  Future<void> saveUserId(String userId) async {
    await _storageService.writeSecure(StorageConstants.userId, userId);
  }

  Future<String?> getUserId() async {
    return await _storageService.readSecure(StorageConstants.userId);
  }

  // User Email
  Future<void> saveUserEmail(String email) async {
    await _storageService.writeSecure(StorageConstants.userEmail, email);
  }

  Future<String?> getUserEmail() async {
    return await _storageService.readSecure(StorageConstants.userEmail);
  }

  // App Settings
  Future<void> setFirstTime(bool value) async {
    await _storageService.setBool(StorageConstants.isFirstTime, value);
  }

  bool isFirstTime() {
    return _storageService.getBool(StorageConstants.isFirstTime) ?? true;
  }

  Future<void> setDarkMode(bool value) async {
    await _storageService.setBool(StorageConstants.isDarkMode, value);
  }

  bool isDarkMode() {
    return _storageService.getBool(StorageConstants.isDarkMode) ?? false;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    await _storageService.setBool(StorageConstants.notificationsEnabled, value);
  }

  bool isNotificationsEnabled() {
    return _storageService.getBool(StorageConstants.notificationsEnabled) ?? true;
  }

  // Clear All Data
  Future<void> clearAll() async {
    await _storageService.deleteAllSecure();
    await _storageService.clear();
  }
}