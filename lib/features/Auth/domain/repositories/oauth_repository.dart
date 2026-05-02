import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import '../entities/oauth_provider_service.dart';

abstract class OAuthRepository {
  Future<Either<Failure, String>> signInWithProvider(
    OAuthProviderService provider,
  );

  Future<Either<Failure, String?>> getCachedOAuthToken();

  Future<Either<Failure, void>> signOutFromProvider(
    OAuthProviderService provider,
  );
}
