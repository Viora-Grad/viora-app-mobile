import 'package:flutter_test/flutter_test.dart';
import 'package:viora_app/core/errors/error_model.dart';
import 'package:viora_app/core/errors/exceptions.dart';

void main() {
  group('ServerException', () {
    test('stores the ErrorModel correctly', () {
      final model = ErrorModel(statusCode: 404, errorMessage: 'Not Found');
      final exception = ServerException(model);
      expect(exception.errorModel.statusCode, 404);
      expect(exception.errorModel.errorMessage, 'Not Found');
    });

    test('toString returns statusCode and message', () {
      final model = ErrorModel(statusCode: 500, errorMessage: 'Server Error');
      final exception = ServerException(model);
      expect(exception.toString(), '500: Server Error');
    });

    test('can be caught as Exception', () {
      expect(
        () => throw ServerException(
          ErrorModel(statusCode: 401, errorMessage: 'Unauthorized'),
        ),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('CacheException', () {
    test('stores the message correctly', () {
      final exception = CacheException('Key not found');
      expect(exception.message, 'Key not found');
    });

    test('toString returns CacheException prefix with message', () {
      final exception = CacheException('Key not found');
      expect(exception.toString(), 'CacheException: Key not found');
    });

    test('can be caught as Exception', () {
      expect(
        () => throw CacheException('storage error'),
        throwsA(isA<CacheException>()),
      );
    });
  });
}
