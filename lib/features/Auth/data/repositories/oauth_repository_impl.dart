import 'package:dartz/dartz.dart';
import 'package:viora_app/core/database/cache/cache_helper.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/core/errors/failure.dart';
import '../../domain/entities/oauth_provider_service.dart';
import '../../domain/repositories/oauth_repository.dart';
import '../datasources/facade/oauth_facade.dart';

class OAuthRepositoryImpl implements OAuthRepository {
  static const _tokenKey = 'user_token';

  final OAuthFacade facade;
  final CacheHelper cacheHelper;

  OAuthRepositoryImpl({required this.facade, required this.cacheHelper});

  @override
  Future<Either<Failure, String>> signInWithProvider(
    OAuthProviderService provider,
  ) async {
    try {
      final appJwt = await facade.signIn(provider);
      await cacheHelper.saveData(_tokenKey, appJwt);
      return Right(appJwt);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, String?>> getCachedOAuthToken() async {
    try {
      final token = await cacheHelper.getData(_tokenKey);
      return Right(token?.toString());
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
      await cacheHelper.deleteData(_tokenKey);
      return const Right(null);
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
