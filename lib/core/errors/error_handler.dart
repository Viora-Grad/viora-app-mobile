import 'package:dio/dio.dart';
import 'package:viora_app/core/errors/exceptions.dart';
import 'package:viora_app/core/errors/error_model.dart';

// Dio Exceptions
dynamic handleDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
      throw ServerException(
        ErrorModel(
          statusCode: 408,
          errorMessage:
              'Dio message: ${e.message} So it is a Connection Timeout',
        ),
      );
    case DioExceptionType.sendTimeout:
      throw ServerException(
        ErrorModel(
          statusCode: 408,
          errorMessage: 'Dio message: ${e.message} So it is a Send Timeout',
        ),
      );
    case DioExceptionType.receiveTimeout:
      throw ServerException(
        ErrorModel(
          statusCode: 408,
          errorMessage: 'Dio message: ${e.message} So it is a Receive Timeout',
        ),
      );
    case DioExceptionType.badResponse:
      throw ServerException(
        ErrorModel(
          statusCode: e.response?.statusCode ?? 500,
          errorMessage: e.response?.statusMessage ?? 'Bad Response',
        ),
      );
    case DioExceptionType.cancel:
      throw ServerException(
        ErrorModel(
          statusCode: 499,
          errorMessage: 'Dio message: ${e.message} Request Cancelled',
        ),
      );
    case DioExceptionType.unknown:
    default:
      throw ServerException(
        ErrorModel(
          statusCode: 500,
          errorMessage: 'Dio message: ${e.message} Unknown Error',
        ),
      );
  }
}
