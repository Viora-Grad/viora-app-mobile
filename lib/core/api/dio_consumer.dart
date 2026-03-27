import 'package:dio/dio.dart';
import 'package:viora_app/core/api/api_consumer.dart';
import 'package:viora_app/core/api/end_points.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/core/errors/error_model.dart';
import 'package:viora_app/core/errors/exceptions.dart';

// DioConsumer is an implementation of ApiConsumer using the Dio package for HTTP requests.
class DioConsumer extends ApiConsumer {
  final Dio dio;

  DioConsumer(this.dio) {
    dio.options.baseUrl = EndPoints.baseUrl;
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
  }) async {
    try {
      Response response = await dio.get(
        url,
        data: isFormData
            ? FormData.fromMap(data as Map<String, dynamic>)
            : data,
        queryParameters: queryParameters,
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
  }) async {
    try {
      Response response = await dio.post(
        url,
        data: isFormData
            ? FormData.fromMap(data as Map<String, dynamic>)
            : data,
        queryParameters: queryParameters,
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
  }) async {
    try {
      Response response = await dio.put(
        url,
        data: isFormData
            ? FormData.fromMap(data as Map<String, dynamic>)
            : data,
        queryParameters: queryParameters,
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
  }) async {
    try {
      Response response = await dio.patch(
        url,
        data: isFormData
            ? FormData.fromMap(data as Map<String, dynamic>)
            : data,
        queryParameters: queryParameters,
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
  }) async {
    try {
      Response response = await dio.delete(
        url,
        data: isFormData
            ? FormData.fromMap(data as Map<String, dynamic>)
            : data,
        queryParameters: queryParameters,
      );
      return _normalizeResponse(response.data);
    } on DioException catch (e) {
      handleDioException(e);
    }
  }
}
