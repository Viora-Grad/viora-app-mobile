import 'package:equatable/equatable.dart';

class ErrorModel extends Equatable {
  final int statusCode;
  final String errorMessage;

  const ErrorModel({required this.statusCode, required this.errorMessage});

  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    return ErrorModel(
      statusCode: json['statusCode'] ?? 0,
      errorMessage: json['errorMessage'] ?? 'Unknown error',
    );
  }

  Map<String, dynamic> toJson() => {
    'statusCode': statusCode,
    'errorMessage': errorMessage,
  };

  @override
  String toString() => '$statusCode: $errorMessage';

  @override
  List<Object> get props => [statusCode, errorMessage];
}
