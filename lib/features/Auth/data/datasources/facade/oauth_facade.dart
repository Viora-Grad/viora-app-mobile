import 'package:viora_app/features/auth/data/datasources/local/auth_local.dart';
import 'package:viora_app/features/auth/data/datasources/remote/auth_remote.dart';
import 'package:viora_app/features/auth/data/datasources/remote/oauth_remote.dart';
import 'package:viora_app/features/auth/domain/entities/oauth_provider_service.dart';
import 'package:viora_app/features/auth/domain/entities/user.dart';

class OAuthFacade {
  final OAuthRemote googleRemote;
  final AuthLocalDataSource authLocalDataSource;
  final AuthRemoteDataSource authRemoteDataSource;

  OAuthFacade({
    required this.googleRemote,
    required this.authLocalDataSource,
    required this.authRemoteDataSource,
  });

  Future<User> signIn(OAuthProviderService provider) async {
    switch (provider) {
      case OAuthProviderService.google:
        final user = await googleRemote.signInWithGoogle();
        final authResult = await googleRemote.validateAndLoginGoogle(user);

        final accessToken = authResult['accessToken'] as String?;
        final refreshToken = authResult['refreshToken'] as String?;

        if (accessToken == null || accessToken.isEmpty) {
          throw Exception('Access token missing from OAuth login response');
        }

        await authLocalDataSource.saveUserToken(accessToken);
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await authLocalDataSource.saveRefreshToken(refreshToken);
        }

        final userModel = await authRemoteDataSource.fetchCurrentUser();
        await authLocalDataSource.saveUser(userModel);

        return userModel.toEntity();

      case OAuthProviderService.twitter:
        throw Exception('Provider not supported yet');
      case OAuthProviderService.facebook:
        throw Exception('Provider not supported yet');
    }
  }

  Future<void> signOut(OAuthProviderService provider) async {
    switch (provider) {
      case OAuthProviderService.google:
        await googleRemote.signOutGoogle();
        break;
      case OAuthProviderService.twitter:
        throw Exception('Provider not supported yet');
      case OAuthProviderService.facebook:
        throw Exception('Provider not supported yet');
    }
  }
}