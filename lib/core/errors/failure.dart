import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Returned when an API/server request fails.
class ServerFailure extends Failure {
  final int statusCode;

  const ServerFailure(super.message, {required this.statusCode});

  @override
  List<Object> get props => [message, statusCode];
}

// Returned when oauth provider sign-in fails.
class OAuthFailure extends Failure {
  const OAuthFailure(super.message);
}

class OAuthCancelledFailure extends OAuthFailure {
  const OAuthCancelledFailure([super.message = 'OAuth cancelled by user']);
}

class OAuthRequiresRegistrationFailure extends Failure {
  final String providerKey;
  final String email;
  final String? firstName;
  final String? lastName;

  const OAuthRequiresRegistrationFailure({
    required this.providerKey,
    required this.email,
    this.firstName,
    this.lastName,
    String message = 'Registration required',
  }) : super(message);

  @override
  List<Object> get props => [message, providerKey, email, firstName ?? '', lastName ?? ''];
}

/// Returned when a local cache/storage operation fails.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Returned when there is no internet connectivity.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Returned when input validation fails.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
