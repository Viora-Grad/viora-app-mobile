import 'package:dio/dio.dart';
import 'package:viora_app/core/errors/error_model.dart';
import 'package:viora_app/core/errors/exceptions.dart';
import 'package:viora_app/core/errors/failure.dart';

/// Translates a [DioException] into a typed [ServerException] and rethrows it.
///
/// Call this inside a `catch (DioException e)` block in remote data sources.
Never handleDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
      throw ServerException(
        ErrorModel(
          statusCode: 408,
          errorMessage:
              'Dio message: ${e.message} So it is a Connection Timeout',
        ),
      );
    case DioExceptionType.sendTimeout:
      throw ServerException(
        ErrorModel(
          statusCode: 408,
          errorMessage: 'Dio message: ${e.message} So it is a Send Timeout',
        ),
      );
    case DioExceptionType.receiveTimeout:
      throw ServerException(
        ErrorModel(
          statusCode: 408,
          errorMessage: 'Dio message: ${e.message} So it is a Receive Timeout',
        ),
      );
    case DioExceptionType.badResponse:
      throw ServerException(
        ErrorModel(
          statusCode: e.response?.statusCode ?? 500,
          errorMessage: e.response?.statusMessage ?? 'Bad Response',
        ),
      );
    case DioExceptionType.cancel:
      throw ServerException(
        ErrorModel(
          statusCode: 499,
          errorMessage: 'Dio message: ${e.message} Request Cancelled',
        ),
      );
    case DioExceptionType.unknown:
    default:
      throw ServerException(
        ErrorModel(
          statusCode: 500,
          errorMessage: 'Dio message: ${e.message} Unknown Error',
        ),
      );
  }
}

/// Maps a caught exception to its corresponding domain-layer [Failure].
///
/// Use this in repository implementations inside a `catch` block:
/// ```dart
/// } on ServerException catch (e) {
///   return Left(e.toFailure());
/// } catch (e) {
///   return Left(handleException(e));
/// }
/// ```
Failure handleException(Object e) {
  if (e is ServerException) return e.toFailure();
  if (e is CacheException) return e.toFailure();
  if (e is NetworkException) return e.toFailure();
  if (e is ValidationException) return e.toFailure();
  return ServerFailure(e.toString(), statusCode: 500);
}
