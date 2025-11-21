import 'dart:io';

import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

class ApiClient {
  late final Dio _dio;
  String? _accessToken;
  String? _refreshToken;
  
  // Callback to get refresh token from storage
  Future<String?> Function()? _getRefreshToken;
  // Callback to save new tokens to storage
  Future<void> Function(String accessToken, String refreshToken)? _onTokensRefreshed;
  // Callback when refresh fails (logout user)
  Future<void> Function()? _onRefreshFailed;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Check if error is 401 and not from refresh endpoint
          if (error.response?.statusCode == 401 && 
              !error.requestOptions.path.contains('/auth/refresh-token')) {
            
            // Try to refresh token
            final refreshed = await _refreshAccessToken();
            
            if (refreshed) {
              // Retry the original request with new token
              final options = error.requestOptions;
              options.headers['Authorization'] = 'Bearer $_accessToken';
              
              try {
                final response = await _dio.fetch(options);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            } else {
              // Refresh failed, call logout callback
              if (_onRefreshFailed != null) {
                await _onRefreshFailed!();
              }
              return handler.next(error);
            }
          }
          
          return handler.next(error);
        },
      ),
    );
  }

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  void setRefreshToken(String? token) {
    _refreshToken = token;
  }

  void setTokenCallbacks({
    Future<String?> Function()? getRefreshToken,
    Future<void> Function(String accessToken, String refreshToken)? onTokensRefreshed,
    Future<void> Function()? onRefreshFailed,
  }) {
    _getRefreshToken = getRefreshToken;
    _onTokensRefreshed = onTokensRefreshed;
    _onRefreshFailed = onRefreshFailed;
  }

  Future<bool> _refreshAccessToken() async {
    try {
      
      String? refreshToken = _refreshToken;
      if (_getRefreshToken != null) {
        refreshToken = await _getRefreshToken!();
      }

      if (refreshToken == null) {
        return false;
      }

      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {
            'Authorization': 'Bearer $refreshToken',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final newAccessToken = data['data']['access_token'] ?? data['data']['accessToken'];
        final newRefreshToken = data['data']['refresh_token'] ?? data['data']['refreshToken'];

        if (newAccessToken != null) {
          _accessToken = newAccessToken;
          
          // Save new tokens via callback
          if (_onTokensRefreshed != null && newRefreshToken != null) {
            await _onTokensRefreshed!(newAccessToken, newRefreshToken);
          }
          
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.delete(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> uploadFile(
    String path,
    File file, {
    Map<String, dynamic>? data,
    ProgressCallback? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        ...?data,
      });

      return await _dio.post(
        path,
        data: formData,
        onSendProgress: onProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  AppException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Connection timeout');
      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);
      case DioExceptionType.cancel:
        return NetworkException('Request cancelled');
      default:
        return NetworkException('Network error occurred');
    }
  }

  AppException _handleResponseError(Response? response) {
    if (response == null) {
      return ServerException('Unknown server error');
    }

    switch (response.statusCode) {
      case 400:
        return BadRequestException(
          response.data['message'] ?? 'Bad request',
        );
      case 401:
        return UnauthorizedException('Unauthorized access');
      case 403:
        return ForbiddenException('Access forbidden');
      case 404:
        return NotFoundException('Resource not found');
      case 500:
        return ServerException('Internal server error');
      default:
        return ServerException('Server error: ${response.statusCode}');
    }
  }
}