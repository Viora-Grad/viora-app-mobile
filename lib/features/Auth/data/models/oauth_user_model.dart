import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/oauth_user_entity.dart';

class OAuthUserModel extends OAuthUserEntity {
  final String? idToken;
  final String? accessToken;

  const OAuthUserModel({
    required super.id,
    required super.email,
    super.name,
    super.photoUrl,
    this.idToken,
    this.accessToken,
  });

  factory OAuthUserModel.fromGoogleAccount({
    required GoogleSignInAccount account,
    required String? idToken,
    String? accessToken,
  }) {
    return OAuthUserModel(
      id: account.id,
      email: account.email,
      name: account.displayName,
      photoUrl: account.photoUrl,
      idToken: idToken,
      accessToken: accessToken,
    );
  }
}
