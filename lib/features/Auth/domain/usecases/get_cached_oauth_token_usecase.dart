import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import '../repositories/oauth_repository.dart';

class GetCachedOAuthTokenUseCase {
  final OAuthRepository repository;

  GetCachedOAuthTokenUseCase(this.repository);

  Future<Either<Failure, String?>> call() {
    return repository.getCachedOAuthToken();
  }
}
