class ErrorModel {
  final int statusCode;
  final String errorMessage;

  ErrorModel({
    required this.statusCode,
    required this.errorMessage,
  });

  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    return ErrorModel(
      statusCode: json['statusCode'] ?? 0,
      errorMessage: json['errorMessage'] ?? 'Unknown error',
    );
  }
}
