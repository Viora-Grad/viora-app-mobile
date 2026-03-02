import 'package:flutter_test/flutter_test.dart';
import 'package:viora_app/core/errors/error_model.dart';

void main() {
  group('ErrorModel', () {
    test('creates instance with required fields', () {
      final model = ErrorModel(statusCode: 404, errorMessage: 'Not Found');
      expect(model.statusCode, 404);
      expect(model.errorMessage, 'Not Found');
    });

    test('fromJson parses valid JSON correctly', () {
      final json = {'statusCode': 500, 'errorMessage': 'Internal Server Error'};
      final model = ErrorModel.fromJson(json);
      expect(model.statusCode, 500);
      expect(model.errorMessage, 'Internal Server Error');
    });

    test('fromJson uses defaults for missing fields', () {
      final model = ErrorModel.fromJson({});
      expect(model.statusCode, 0);
      expect(model.errorMessage, 'Unknown error');
    });

    test('fromJson handles null statusCode with default 0', () {
      final json = {'statusCode': null, 'errorMessage': 'Some error'};
      final model = ErrorModel.fromJson(json);
      expect(model.statusCode, 0);
    });

    test('fromJson handles null errorMessage with default', () {
      final json = {'statusCode': 400, 'errorMessage': null};
      final model = ErrorModel.fromJson(json);
      expect(model.errorMessage, 'Unknown error');
    });
  });
}
