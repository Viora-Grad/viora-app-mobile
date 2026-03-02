// TODO NEED SOME IMPROVEMENT IN THIS FILE
import 'package:viora_app/core/errors/error_model.dart';

/// **ServerException** - Thrown when API/server requests fail
///
/// Usage Example:
/// ```dart
/// try {
///   final users = await fetchUsers();
/// } on ServerException catch (e) {
///   showSnackBar (e.message); // Shows: '404: Not Found'
///   print('Status: ${e.errorModel.statusCode}');      // e.g., 404
///   print('Message: ${e.errorModel.errorMessage}');   // e.g., 'Not Found'
/// }
/// ```
class ServerException implements Exception {
  final ErrorModel errorModel;
  ServerException(this.errorModel);

  @override
  String toString() => '${errorModel.statusCode}: ${errorModel.errorMessage}';
}

/// **CacheException** - Thrown when local cache/storage operations fail
///
/// Usage Example:
/// ```dart
/// try {
///   await cacheHelper.patchData('user_token', newToken);
/// } on CacheException catch (e) {
///   
///   print('Cache Error: ${e.message}');  // e.g., 'Key user_token does not exist'
/// }
/// ```
class CacheException implements Exception {
  final String message;
  CacheException(this.message);

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
  NetworkException(this.message);

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
  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}
