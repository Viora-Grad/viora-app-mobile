import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:viora_app/core/api/api_consumer.dart';
import 'package:viora_app/core/api/end_points.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/core/errors/error_model.dart';
import 'package:viora_app/core/errors/exceptions.dart';

// DioConsumer is an implementation of ApiConsumer using the Dio package for HTTP requests.
class DioConsumer extends ApiConsumer {
  final Dio dio;

  // TODO: Replace with your actual backend certificate public key hash (SPKI SHA-256)
  // Ask backend team for: openssl x509 -in cert.crt -pubkey -noout | openssl pkey -pubin -outform DER | openssl dgst -sha256 -binary | openssl enc -base64
  static const String _pinnedCertificate = 'sha256/YOUR_BACKEND_CERT_HASH_HERE';

  DioConsumer(this.dio) {
    dio.options.baseUrl = EndPoints.baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.validateStatus = (status) =>
        status != null && status >= 200 && status < 500;

    // Add Certificate Pinning Interceptor
    if (kReleaseMode) {
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback = (cert, host, port) {
            // Verify certificate pin matches expected backend certificate
            if (cert.pem == _pinnedCertificate) {
              return true; // Certificate is valid and pinned
            }
            // Certificate does not match pinned certificate - reject connection
            throw ServerException(
              ErrorModel(
                statusCode: 495, // Certificate Error status code
                errorMessage:
                    'Certificate pinning validation failed for host: $host. '
                    'The server certificate does not match the expected pinned certificate.',
              ),
            );
          };
          return client;
        },
      );
    }
  }

  Map<String, dynamic> _normalizeResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw ServerException(
      ErrorModel(
        statusCode: 500,
        errorMessage:
            'Expected a JSON object response but received ${data.runtimeType}.',
      ),
    );
  }

  // Helper method to handle Dio get requests and exceptions.
  @override
  Future<Map<String, dynamic>> get(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
    CancelToken? cancelToken,
  }) async {
    try {
      Response response = await dio.get(
        url,
        data: isFormData
            ? FormData.fromMap(data as Map<String, dynamic>)
            : data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return _normalizeResponse(response.data);
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  // Helper method to handle Dio post requests and exceptions.
  @override
  Future<Map<String, dynamic>> post(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
    CancelToken? cancelToken,
  }) async {
    try {
      Response response = await dio.post(
        url,
        data: isFormData
            ? FormData.fromMap(data as Map<String, dynamic>)
            : data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return _normalizeResponse(response.data);
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  // Helper method to handle Dio put requests and exceptions.
  @override
  Future<Map<String, dynamic>> put(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
    CancelToken? cancelToken,
  }) async {
    try {
      Response response = await dio.put(
        url,
        data: isFormData
            ? FormData.fromMap(data as Map<String, dynamic>)
            : data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return _normalizeResponse(response.data);
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  // Helper method to handle Dio patch requests and exceptions.
  @override
  Future<Map<String, dynamic>> patch(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
    CancelToken? cancelToken,
  }) async {
    try {
      Response response = await dio.patch(
        url,
        data: isFormData
            ? FormData.fromMap(data as Map<String, dynamic>)
            : data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return _normalizeResponse(response.data);
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  // Helper method to handle Dio delete requests and exceptions.
  @override
  Future<Map<String, dynamic>> delete(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
    CancelToken? cancelToken,
  }) async {
    try {
      Response response = await dio.delete(
        url,
        data: isFormData
            ? FormData.fromMap(data as Map<String, dynamic>)
            : data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return _normalizeResponse(response.data);
    } on DioException catch (e) {
      handleDioException(e);
    }
  }
}
