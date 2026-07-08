import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:viora_app/core/errors/error_model.dart';
import 'package:viora_app/core/errors/exceptions.dart';
import 'package:viora_app/core/errors/failure.dart';

/// Translates a [DioException] into a typed [ServerException] and rethrows it.
///
/// Call this inside a `catch (DioException e)` block in remote data sources.
Never handleDioException(DioException e) {
  debugPrint('[ErrorHandler] ===== DioException =====');
  debugPrint('[ErrorHandler] Type: ${e.type}');
  debugPrint('[ErrorHandler] Message: ${e.message}');
  debugPrint('[ErrorHandler] Status code: ${e.response?.statusCode}');
  debugPrint('[ErrorHandler] Response body: ${e.response?.data}');
  debugPrint('[ErrorHandler] Request URI: ${e.requestOptions.uri}');
  debugPrint('[ErrorHandler] Request method: ${e.requestOptions.method}');
  debugPrint('[ErrorHandler] Request body: ${e.requestOptions.data}');
  debugPrint('[ErrorHandler] Request headers: ${e.requestOptions.headers}');
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
      final statusCode = e.response?.statusCode ?? 500;
      final errorMessage = _parseBackendError(e.response, statusCode);
      throw ServerException(ErrorModel(
        statusCode: statusCode,
        errorMessage: errorMessage,
      ));
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
      if (e.error is SocketException) {
        throw ServerException(unavailableErrorModel());
      }

      if (e.message?.toLowerCase().contains('failed host lookup') ?? false) {
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
  if (e is OAuthRequiresRegistrationException) {
    return OAuthRequiresRegistrationFailure(
      providerKey: e.providerKey,
      email: e.email,
      firstName: e.firstName,
      lastName: e.lastName,
    );
  }
  return ServerFailure(e.toString(), statusCode: 500);
}

/// Parses backend error response body into a human-readable message.
///
/// Backend returns two formats:
/// - Auth endpoints: `{ "name": "...", "description": "...", "category": "..." }`
/// - Exception middleware: `{ "Error": "...", "TraceId": "..." }`
String _parseBackendError(Response? response, int statusCode) {
  if (response?.data == null) {
    return 'An error occurred. Please try again later.';
  }

  final data = response!.data;

  if (data is Map<String, dynamic>) {
    // Auth error format: { "name", "description", "category" }
    if (data.containsKey('description') && data['description'] is String) {
      return data['description'] as String;
    }

    // Exception middleware format: { "Error", "TraceId" }
    if (data.containsKey('Error') && data['Error'] is String) {
      return data['Error'] as String;
    }

    // ProblemDetails format: { "title", "detail", "errors" }
    if (data.containsKey('errors') && data['errors'] is Map) {
      final errors = data['errors'] as Map<String, dynamic>;
      final messages = errors.entries
          .map((e) => '${e.key}: ${(e.value as List).join(", ")}')
          .join('; ');
      if (messages.isNotEmpty) return messages;
    }
    if (data.containsKey('detail') && data['detail'] is String) {
      return data['detail'] as String;
    }
    if (data.containsKey('title') && data['title'] is String) {
      return data['title'] as String;
    }
  }

  if (data is String && data.isNotEmpty) {
    return data;
  }

  return 'An error occurred. Please try again later.';
}
