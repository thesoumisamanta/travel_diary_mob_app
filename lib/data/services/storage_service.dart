import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Write a string
  Future<void> write(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  // Read a string
  Future<String?> read(String key) async {
    return await _secureStorage.read(key: key);
  }

  // Delete a key
  Future<void> delete(String key) async {
    await _secureStorage.delete(key: key);
  }

  // Delete all keys
  Future<void> deleteAll() async {
    await _secureStorage.deleteAll();
  }

  // Store boolean as string
  Future<void> writeBool(String key, bool value) async {
    await _secureStorage.write(key: key, value: value.toString());
  }

  Future<bool?> readBool(String key) async {
    final value = await _secureStorage.read(key: key);
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }
}
