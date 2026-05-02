import 'package:viora_app/features/auth/data/models/oauth_user_model.dart';

abstract class OAuthRemote {
  Future<OAuthUserModel> signInWithGoogle();
  Future<String> exchangeGoogleToken(OAuthUserModel googleUser);
  Future<void> signOutGoogle();
}
