import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:viora_app/core/connections/network_info.dart';

class MockDataConnectionChecker extends Mock implements DataConnectionChecker {}

void main() {
  late MockDataConnectionChecker mockChecker;
  late NetworkInfoImpl networkInfo;

  setUp(() {
    mockChecker = MockDataConnectionChecker();
    networkInfo = NetworkInfoImpl(mockChecker);
  });

  group('NetworkInfoImpl', () {
    test('isConnected returns true when device is online', () async {
      when(() => mockChecker.hasConnection).thenAnswer((_) async => true);

      final result = await networkInfo.isConnected;

      expect(result, true);
      verify(() => mockChecker.hasConnection).called(1);
    });

    test('isConnected returns false when device is offline', () async {
      when(() => mockChecker.hasConnection).thenAnswer((_) async => false);

      final result = await networkInfo.isConnected;

      expect(result, false);
      verify(() => mockChecker.hasConnection).called(1);
    });

    test(
      'isConnected delegates to DataConnectionChecker.hasConnection',
      () async {
        when(() => mockChecker.hasConnection).thenAnswer((_) async => true);

        await networkInfo.isConnected;

        verify(() => mockChecker.hasConnection).called(1);
      },
    );
  });
}
