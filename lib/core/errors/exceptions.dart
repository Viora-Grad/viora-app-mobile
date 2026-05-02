import 'package:viora_app/core/errors/error_model.dart';
import 'package:viora_app/core/errors/failure.dart';

/// **ServerException** - Thrown when API/server requests fail
///
/// Usage Example:
/// ```dart
/// try {
///   final users = await fetchUsers();
/// } on ServerException catch (e) {
///   showSnackBar(e.message); // Shows: '404: Not Found'
///   print('Status: ${e.errorModel.statusCode}');      // e.g., 404
///   print('Message: ${e.errorModel.errorMessage}');   // e.g., 'Not Found'
/// }
/// ```
class ServerException implements Exception {
  final ErrorModel errorModel;
  const ServerException(this.errorModel);

  String get message => errorModel.toString();

  ServerFailure toFailure() =>
      ServerFailure(message, statusCode: errorModel.statusCode);

  @override
  String toString() => 'ServerException: $message';
}

/// **CacheException** - Thrown when local cache/storage operations fail
///
/// Usage Example:
/// ```dart
/// try {
///   await cacheHelper.patchData('user_token', newToken);
/// } on CacheException catch (e) {
///   print('Cache Error: ${e.message}');  // e.g., 'Key user_token does not exist'
/// }
/// ```
class CacheException implements Exception {
  final String message;
  const CacheException(this.message);

  CacheFailure toFailure() => CacheFailure(message);

  @override
  String toString() => 'CacheException: $message';
}

/// **NetworkException** - Thrown when there's no internet connectivity
///
/// Usage Example:
/// ```dart
/// try {
///   await apiCall();
/// } on NetworkException catch (e) {
///   showSnackBar('Please check your internet connection');
/// }
/// ```
class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  NetworkFailure toFailure() => NetworkFailure(message);

  @override
  String toString() => 'NetworkException: $message';
}

/// **ValidationException** - Thrown when input validation fails
///
/// Usage Example:
/// ```dart
/// try {
///   validateEmail(email);
/// } on ValidationException catch (e) {
///   print('Validation Error: ${e.message}');
/// }
/// ```
class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);

  ValidationFailure toFailure() => ValidationFailure(message);

  @override
  String toString() => 'ValidationException: $message';
}

class OAuthCancelledException implements Exception {
  final String message;
  const OAuthCancelledException([this.message = 'OAuth cancelled by user']);

  OAuthCancelledFailure toFailure() => OAuthCancelledFailure(message);

  @override
  String toString() => 'OAuthCancelledException: $message';
}
