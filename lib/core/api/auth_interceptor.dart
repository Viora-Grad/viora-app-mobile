import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:viora_app/core/api/end_points.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;
  final Dio _dio;
  static const _tokenKey = 'user_token';
  static const _refreshTokenKey = 'refresh_token';

  AuthInterceptor(this._secureStorage, this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for login, register, refresh, and OAuth endpoints
    final path = options.path;
    if (path.contains('/api/auth/login') ||
        path.contains('/api/auth/register') ||
        path.contains('/api/auth/refresh') ||
        path.contains('/api/auth/oauth/')) {
      return handler.next(options);
    }

    final token = await _secureStorage.read(key: _tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only handle 401 errors for non-auth endpoints
    if (err.response?.statusCode == 401) {
      final path = err.requestOptions.path;
      if (path.contains('/api/auth/login') ||
          path.contains('/api/auth/register') ||
          path.contains('/api/auth/refresh') ||
          path.contains('/api/auth/oauth/')) {
        return handler.next(err);
      }

      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        // Retry the original request with new token
        final newToken = await _secureStorage.read(key: _tokenKey);
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';

        try {
          final response = await _dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } on DioException catch (e) {
          return handler.next(e);
        }
      }
    }

    return handler.next(err);
  }

  Future<bool> _tryRefreshToken() async {
    final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final response = await _dio.post(
        EndPoints.refreshUrl,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data;
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await _secureStorage.write(key: _tokenKey, value: newAccessToken);
        }
        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          await _secureStorage.write(
            key: _refreshTokenKey,
            value: newRefreshToken,
          );
        }

        return true;
      }
    } catch (_) {
      // Refresh failed - user will need to re-login
    }

    return false;
  }
}
