import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/core/errors/exceptions.dart';

DioException _makeDioException(DioExceptionType type, {Response? response}) {
  return DioException(
    type: type,
    requestOptions: RequestOptions(path: '/test'),
    response: response,
    message: 'Test error message',
  );
}

void main() {
  group('handleDioException', () {
    test('connectionTimeout throws ServerException with status 408', () {
      expect(
        () => handleDioException(
          _makeDioException(DioExceptionType.connectionTimeout),
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.errorModel.statusCode,
            'statusCode',
            408,
          ),
        ),
      );
    });

    test('sendTimeout throws ServerException with status 408', () {
      expect(
        () =>
            handleDioException(_makeDioException(DioExceptionType.sendTimeout)),
        throwsA(
          isA<ServerException>().having(
            (e) => e.errorModel.statusCode,
            'statusCode',
            408,
          ),
        ),
      );
    });

    test('receiveTimeout throws ServerException with status 408', () {
      expect(
        () => handleDioException(
          _makeDioException(DioExceptionType.receiveTimeout),
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.errorModel.statusCode,
            'statusCode',
            408,
          ),
        ),
      );
    });

    test('cancel throws ServerException with status 499', () {
      expect(
        () => handleDioException(_makeDioException(DioExceptionType.cancel)),
        throwsA(
          isA<ServerException>().having(
            (e) => e.errorModel.statusCode,
            'statusCode',
            499,
          ),
        ),
      );
    });

    test('unknown throws ServerException with status 500', () {
      expect(
        () => handleDioException(_makeDioException(DioExceptionType.unknown)),
        throwsA(
          isA<ServerException>().having(
            (e) => e.errorModel.statusCode,
            'statusCode',
            500,
          ),
        ),
      );
    });

    test('badResponse uses response statusCode', () {
      final response = Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 422,
        statusMessage: 'Unprocessable Entity',
      );
      expect(
        () => handleDioException(
          _makeDioException(DioExceptionType.badResponse, response: response),
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.errorModel.statusCode,
            'statusCode',
            422,
          ),
        ),
      );
    });

    test('badResponse uses response statusMessage', () {
      final response = Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 404,
        statusMessage: 'Not Found',
      );
      expect(
        () => handleDioException(
          _makeDioException(DioExceptionType.badResponse, response: response),
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.errorModel.errorMessage,
            'errorMessage',
            'Not Found',
          ),
        ),
      );
    });

    test('badResponse with null response falls back to 500', () {
      expect(
        () =>
            handleDioException(_makeDioException(DioExceptionType.badResponse)),
        throwsA(
          isA<ServerException>().having(
            (e) => e.errorModel.statusCode,
            'statusCode',
            500,
          ),
        ),
      );
    });
  });
}
