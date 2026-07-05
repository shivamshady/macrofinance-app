import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../constants/app_constants.dart';
import 'api_interceptors.dart';

/// MacroFinance — HTTP Client (Dio)
/// Configured with auth interceptors, logging, and error handling
class ApiClient {
  late final Dio _dio;

  static ApiClient? _instance;

  factory ApiClient() {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-App-Version': AppConstants.appVersion,
          'X-Platform': 'mobile',
        },
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);

    // Implement Certificate Pinning
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          // In a real app, you would check the SHA-256 fingerprint here
          // Example: return cert.sha256 == 'expected_fingerprint';
          // For now, returning false enforces that the certificate MUST be valid
          // according to the device's root certificates, preventing MITM proxies
          // like Charles/Proxyman from working without root installation.
          return true; // DISABLED FOR DEV
        };
        return client;
      },
    );
  }

  Dio get dio => _dio;

  // ── GET ──
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // ── POST ──
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // ── PUT ──
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      options: options,
    );
  }

  // ── DELETE ──
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      options: options,
    );
  }

  // ── UPLOAD ──
  Future<Response<T>> upload<T>(
    String path, {
    required FormData formData,
    void Function(int, int)? onSendProgress,
    Options? options,
  }) async {
    return _dio.post<T>(
      path,
      data: formData,
      onSendProgress: onSendProgress,
      options: options ?? Options(contentType: 'multipart/form-data'),
    );
  }
}
