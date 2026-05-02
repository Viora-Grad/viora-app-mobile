import 'dart:io';

import 'package:dio/dio.dart';
import 'package:viora_app/core/config/app_flags.dart';
import 'package:viora_app/core/errors/error_model.dart';
import 'package:viora_app/core/errors/exceptions.dart';
import 'package:viora_app/core/errors/failure.dart';

/// Translates a [DioException] into a typed [ServerException] and rethrows it.
///
/// Call this inside a `catch (DioException e)` block in remote data sources.
Never handleDioException(DioException e) {
  bool shouldShowServerUnavailableMessage(int? statusCode) {
    if (useDummyAuthApi) {
      return false;
    }

    const unavailableStatusCodes = <int>{404, 500, 502, 503, 504};
    return statusCode != null && unavailableStatusCodes.contains(statusCode);
  }

  ErrorModel unavailableErrorModel([int statusCode = 503]) => ErrorModel(
    statusCode: statusCode,
    errorMessage:
        'Server is currently unavailable or has an issue. Please try again later.',
  );

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
          errorMessage:
              shouldShowServerUnavailableMessage(e.response?.statusCode)
              ? unavailableErrorModel().errorMessage
              : (e.response?.statusMessage ?? 'Bad Response'),
        ),
      );
    case DioExceptionType.connectionError:
      throw ServerException(unavailableErrorModel());
    case DioExceptionType.cancel:
      throw ServerException(
        ErrorModel(
          statusCode: 499,
          errorMessage: 'Dio message: ${e.message} Request Cancelled',
        ),
      );
    case DioExceptionType.unknown:
      if (!useDummyAuthApi && e.error is SocketException) {
        throw ServerException(unavailableErrorModel());
      }

      if (!useDummyAuthApi &&
          (e.message?.toLowerCase().contains('failed host lookup') ?? false)) {
        throw ServerException(unavailableErrorModel());
      }

      throw ServerException(
        ErrorModel(
          statusCode: 500,
          errorMessage: 'Dio message: ${e.message} Unknown Dio Error',
        ),
      );

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
  if (e is OAuthCancelledException) return e.toFailure();
  return ServerFailure(e.toString(), statusCode: 500);
}
