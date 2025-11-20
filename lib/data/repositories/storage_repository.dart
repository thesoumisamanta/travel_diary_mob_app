import '../services/storage_service.dart';

class StorageRepository {
  final StorageService _storageService;

  StorageRepository(this._storageService);

  // Tokens
  Future<void> saveAccessToken(String token) async {
    await _storageService.write('access_token', token);
  }

  Future<String?> getAccessToken() async {
    return await _storageService.read('access_token');
  }

  Future<void> saveRefreshToken(String token) async {
    await _storageService.write('refresh_token', token);
  }

  Future<String?> getRefreshToken() async {
    return await _storageService.read('refresh_token');
  }

  // User
  Future<void> saveUserId(String userId) async {
    await _storageService.write('user_id', userId);
  }

  Future<String?> getUserId() async {
    return await _storageService.read('user_id');
  }

  Future<void> saveUserEmail(String email) async {
    await _storageService.write('user_email', email);
  }

  Future<String?> getUserEmail() async {
    return await _storageService.read('user_email');
  }

  Future<void> saveUserPassword(String password) async {
    await _storageService.write('user_password', password);
  }

  Future<String?> getUserPassword() async {
    return await _storageService.read('user_password');
  }

  // Remember Me
  Future<void> saveRememberMe(bool value) async {
    await _storageService.writeBool('remember_me', value);
  }

  Future<bool?> getRememberMe() async {
    return await _storageService.readBool('remember_me');
  }

  // Clear all
  Future<void> clearAll() async {
    await _storageService.deleteAll();
  }
}
