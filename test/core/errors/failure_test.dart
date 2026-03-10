import 'package:flutter_test/flutter_test.dart';
import 'package:viora_app/core/errors/failure.dart';

void main() {
  group('Failure subtypes', () {
    test('ServerFailure stores message and statusCode correctly', () {
      const failure = ServerFailure('404: Not Found', statusCode: 404);
      expect(failure.message, '404: Not Found');
      expect(failure.statusCode, 404);
    });

    test('CacheFailure stores message correctly', () {
      const failure = CacheFailure('Key not found');
      expect(failure.message, 'Key not found');
    });

    test('NetworkFailure stores message correctly', () {
      const failure = NetworkFailure('No internet');
      expect(failure.message, 'No internet');
    });

    test('ValidationFailure stores message correctly', () {
      const failure = ValidationFailure('Invalid email');
      expect(failure.message, 'Invalid email');
    });

    test('two ServerFailures with same message are equal (Equatable)', () {
      const a = ServerFailure('error', statusCode: 500);
      const b = ServerFailure('error', statusCode: 500);
      expect(a, b);
    });

    test('two ServerFailures with different messages are not equal', () {
      const a = ServerFailure('error A', statusCode: 500);
      const b = ServerFailure('error B', statusCode: 500);
      expect(a, isNot(b));
    });

    test(
      'two ServerFailures with same message but different statusCode are not equal',
      () {
        const a = ServerFailure('error', statusCode: 404);
        const b = ServerFailure('error', statusCode: 500);
        expect(a, isNot(b));
      },
    );

    test(
      'failures of different subtypes are not equal even with same message',
      () {
        const a = ServerFailure('error', statusCode: 500);
        const b = CacheFailure('error');
        expect(a, isNot(b));
      },
    );
  });
}
