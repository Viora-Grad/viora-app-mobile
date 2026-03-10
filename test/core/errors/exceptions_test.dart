import 'package:flutter_test/flutter_test.dart';
import 'package:viora_app/core/errors/error_model.dart';
import 'package:viora_app/core/errors/exceptions.dart';
import 'package:viora_app/core/errors/failure.dart';

void main() {
  group('ServerException', () {
    test('stores the ErrorModel correctly', () {
      final model = ErrorModel(statusCode: 404, errorMessage: 'Not Found');
      final exception = ServerException(model);
      expect(exception.errorModel.statusCode, 404);
      expect(exception.errorModel.errorMessage, 'Not Found');
    });

    test('message getter returns statusCode: errorMessage', () {
      final model = ErrorModel(statusCode: 500, errorMessage: 'Server Error');
      final exception = ServerException(model);
      expect(exception.message, '500: Server Error');
    });

    test('toString returns ServerException prefix with message', () {
      final model = ErrorModel(statusCode: 500, errorMessage: 'Server Error');
      final exception = ServerException(model);
      expect(exception.toString(), 'ServerException: 500: Server Error');
    });

    test(
      'toFailure returns ServerFailure with correct message and statusCode',
      () {
        final model = ErrorModel(statusCode: 404, errorMessage: 'Not Found');
        final exception = ServerException(model);
        final failure = exception.toFailure();
        expect(failure, isA<ServerFailure>());
        expect(failure.message, '404: Not Found');
        expect(failure.statusCode, 404);
      },
    );

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

    test('toFailure returns CacheFailure with correct message', () {
      final exception = CacheException('Key not found');
      final failure = exception.toFailure();
      expect(failure, isA<CacheFailure>());
      expect(failure.message, 'Key not found');
    });

    test('can be caught as Exception', () {
      expect(
        () => throw CacheException('storage error'),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('NetworkException', () {
    test('stores the message correctly', () {
      final exception = NetworkException('No internet');
      expect(exception.message, 'No internet');
    });

    test('toString returns NetworkException prefix with message', () {
      expect(
        NetworkException('No internet').toString(),
        'NetworkException: No internet',
      );
    });

    test('toFailure returns NetworkFailure with correct message', () {
      final failure = NetworkException('No internet').toFailure();
      expect(failure, isA<NetworkFailure>());
      expect(failure.message, 'No internet');
    });
  });

  group('ValidationException', () {
    test('stores the message correctly', () {
      final exception = ValidationException('Invalid email');
      expect(exception.message, 'Invalid email');
    });

    test('toString returns ValidationException prefix with message', () {
      expect(
        ValidationException('Invalid email').toString(),
        'ValidationException: Invalid email',
      );
    });

    test('toFailure returns ValidationFailure with correct message', () {
      final failure = ValidationException('Invalid email').toFailure();
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'Invalid email');
    });
  });
}
