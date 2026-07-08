import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/Auth/domain/entities/user.dart';
import '../entities/oauth_provider_service.dart';

abstract class OAuthRepository {
  Future<Either<Failure, User>> signInWithProvider(
    OAuthProviderService provider,
  );

  Future<Either<Failure, void>> signOutFromProvider(
    OAuthProviderService provider,
  );
}
