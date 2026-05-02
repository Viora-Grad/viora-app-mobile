import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import '../entities/oauth_provider_service.dart';
import '../repositories/oauth_repository.dart';

class SignInWithOAuthUseCase {
  final OAuthRepository repository;

  SignInWithOAuthUseCase(this.repository);

  Future<Either<Failure, String>> call(OAuthProviderService provider) {
    return repository.signInWithProvider(provider);
  }
}