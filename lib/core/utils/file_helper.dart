import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_constants.dart';

class FileHelper {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }

  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  static bool validateImageSize(File file) {
    final fileSize = file.lengthSync();
    return fileSize <= AppConstants.maxImageSize;
  }

  static bool validateVideoSize(File file) {
    final fileSize = file.lengthSync();
    return fileSize <= AppConstants.maxVideoSize;
  }

  static String getFileSizeString(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  static Future<String> getDownloadDirectory() async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    return directory?.path ?? '';
  }

  static Future<File> downloadFile(String url, String filename) async {
    final directory = await getDownloadDirectory();
    final filePath = '$directory/$filename';
    // Implementation for downloading file from URL
    // This is a placeholder - actual implementation would use http or dio
    return File(filePath);
  }

  static String getFileExtension(String filename) {
    return filename.split('.').last.toLowerCase();
  }

  static bool isImageFile(String filename) {
    final ext = getFileExtension(filename);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  static bool isVideoFile(String filename) {
    final ext = getFileExtension(filename);
    return ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext);
  }
}