import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Injects auth token into request headers
class AuthInterceptor extends Interceptor {
  final _storage = const FlutterSecureStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: AppConstants.keyAuthToken);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired — trigger refresh flow
      debugPrint('[Auth] Token expired, needs refresh');
      // A full implementation would use a Dio instance without interceptors to refresh token
      // then retry the original request.
    }
    handler.next(err);
  }
}

/// Logs request/response details in debug mode
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌─── API Request ───');
      debugPrint('│ ${options.method} ${options.uri}');
      if (options.data != null) {
        debugPrint('│ Body: ${options.data}');
      }
      debugPrint('└───────────────────');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌─── API Response ──');
      debugPrint('│ ${response.statusCode} ${response.requestOptions.uri}');
      debugPrint('└───────────────────');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌─── API Error ─────');
      debugPrint('│ ${err.response?.statusCode} ${err.requestOptions.uri}');
      debugPrint('│ ${err.message}');
      debugPrint('└───────────────────');
    }
    handler.next(err);
  }
}

/// Maps Dio errors to user-friendly messages
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timed out. Please check your internet connection.';
        break;
      case DioExceptionType.connectionError:
        message = 'Unable to connect. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        message = _handleBadResponse(err.response?.statusCode);
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      default:
        message = 'An unexpected error occurred. Please try again.';
    }

    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: err.error,
        message: message,
      ),
    );
  }

  String _handleBadResponse(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Session expired. Please log in again.';
      case 403:
        return 'Access denied. You do not have permission.';
      case 404:
        return 'Resource not found.';
      case 422:
        return 'Validation error. Please check your input.';
      case 429:
        return 'Too many requests. Please wait and try again.';
      case 500:
        return 'Server error. Please try again later.';
      case 503:
        return 'Service temporarily unavailable. Please try again later.';
      default:
        return 'Something went wrong (Error $statusCode).';
    }
  }
}
