import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:viora_app/core/database/api/dio_consumer.dart';
import 'package:viora_app/core/errors/exceptions.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late DioConsumer dioConsumer;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockDio = MockDio();
    // Provide a BaseOptions so DioConsumer constructor doesn't crash
    when(() => mockDio.options).thenReturn(BaseOptions());
    dioConsumer = DioConsumer(mockDio);
  });

  group('DioConsumer - GET', () {
    test('returns data on successful GET', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/users'),
        data: {'id': 1, 'name': 'Alice'},
        statusCode: 200,
      );
      when(
        () => mockDio.get(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => response);

      final result = await dioConsumer.get('/users');

      expect(result, {'id': 1, 'name': 'Alice'});
    });

    test('throws ServerException on DioException during GET', () async {
      when(
        () => mockDio.get(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/users'),
          message: 'timeout',
        ),
      );

      expect(() => dioConsumer.get('/users'), throwsA(isA<ServerException>()));
    });
  });

  group('DioConsumer - POST', () {
    test('returns data on successful POST', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/users'),
        data: {'id': 2, 'name': 'Bob'},
        statusCode: 201,
      );
      when(
        () => mockDio.post(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => response);

      final result = await dioConsumer.post('/users', data: {'name': 'Bob'});

      expect(result, {'id': 2, 'name': 'Bob'});
    });

    test('throws ServerException on DioException during POST', () async {
      when(
        () => mockDio.post(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/users'),
          response: Response(
            requestOptions: RequestOptions(path: '/users'),
            statusCode: 400,
            statusMessage: 'Bad Request',
          ),
        ),
      );

      expect(() => dioConsumer.post('/users'), throwsA(isA<ServerException>()));
    });
  });

  group('DioConsumer - PUT', () {
    test('returns data on successful PUT', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/users/1'),
        data: {'id': 1, 'name': 'Updated'},
        statusCode: 200,
      );
      when(
        () => mockDio.put(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => response);

      final result = await dioConsumer.put(
        '/users/1',
        data: {'name': 'Updated'},
      );

      expect(result, {'id': 1, 'name': 'Updated'});
    });
  });

  group('DioConsumer - PATCH', () {
    test('returns data on successful PATCH', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/users/1'),
        data: {'id': 1, 'name': 'Patched'},
        statusCode: 200,
      );
      when(
        () => mockDio.patch(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => response);

      final result = await dioConsumer.patch(
        '/users/1',
        data: {'name': 'Patched'},
      );

      expect(result, {'id': 1, 'name': 'Patched'});
    });
  });

  group('DioConsumer - DELETE', () {
    test('returns data on successful DELETE', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/users/1'),
        data: null,
        statusCode: 204,
      );
      when(
        () => mockDio.delete(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => response);

      final result = await dioConsumer.delete('/users/1');

      expect(result, isNull);
    });
  });
}
