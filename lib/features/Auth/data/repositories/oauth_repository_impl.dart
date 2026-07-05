import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/auth/data/datasources/facade/oauth_facade.dart';
import 'package:viora_app/features/auth/data/datasources/local/auth_local.dart';
import 'package:viora_app/features/auth/domain/entities/oauth_provider_service.dart';
import 'package:viora_app/features/auth/domain/entities/user.dart';
import 'package:viora_app/features/auth/domain/repositories/oauth_repository.dart';

class OAuthRepositoryImpl implements OAuthRepository {
  final OAuthFacade facade;
  final AuthLocalDataSource authLocalDataSource;

  OAuthRepositoryImpl({
    required this.facade,
    required this.authLocalDataSource,
  });

  @override
  Future<Either<Failure, User>> signInWithProvider(
    OAuthProviderService provider,
  ) async {
    try {
      final user = await facade.signIn(provider);
      return Right(user);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> signOutFromProvider(
    OAuthProviderService provider,
  ) async {
    try {
      await facade.signOut(provider);
      await authLocalDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(handleException(e));
    }
  }
}