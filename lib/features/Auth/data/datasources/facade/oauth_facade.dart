import 'package:viora_app/features/auth/domain/entities/oauth_provider_service.dart';
import '../remote/oauth_remote.dart';

class OAuthFacade {
  final OAuthRemote googleRemote;

  OAuthFacade({required this.googleRemote});

  Future<String> signIn(OAuthProviderService provider) async {
    switch (provider) {
      case OAuthProviderService.google:
        final user = await googleRemote.signInWithGoogle();
        return googleRemote.exchangeGoogleToken(user);
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
