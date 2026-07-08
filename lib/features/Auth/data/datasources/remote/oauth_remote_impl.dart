import 'package:google_sign_in/google_sign_in.dart';
import 'package:viora_app/core/api/api_consumer.dart';
import 'package:viora_app/core/api/end_points.dart';
import 'package:viora_app/core/errors/exceptions.dart';
import 'package:viora_app/features/Auth/data/datasources/local/auth_local.dart';
import 'package:viora_app/features/Auth/data/datasources/remote/oauth_remote.dart';
import 'package:viora_app/features/Auth/data/models/oauth_user_model.dart';

class GoogleOAuthRemoteImpl implements OAuthRemote {
  final GoogleSignIn googleSignIn;
  final ApiConsumer apiConsumer;
  final AuthLocalDataSource authLocalDataSource;

  GoogleOAuthRemoteImpl({
    required this.googleSignIn,
    required this.apiConsumer,
    required this.authLocalDataSource,
  });

  @override
  Future<OAuthUserModel> signInWithGoogle() async {
    late final GoogleSignInAccount account;
    try {
      account = await googleSignIn.authenticate(scopeHint: ['email']);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const OAuthCancelledException();
      }
      rethrow;
    }

    final auth = account.authentication;
    final idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Google idToken missing');
    }

    return OAuthUserModel.fromGoogleAccount(
      account: account,
      idToken: idToken,
    );
  }

  @override
  Future<Map<String, dynamic>> validateAndLoginGoogle(
    OAuthUserModel googleUser,
  ) async {
    final idToken = googleUser.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Google idToken missing');
    }

    final validateResponse = await apiConsumer.post(
      EndPoints.googleValidateUrl,
      data: {'token': idToken},
    );

    final isUserExists = validateResponse['isUserExists'] as bool? ?? false;
    final providerKey = validateResponse['providerKey'] as String? ?? '';
    final email = validateResponse['email'] as String? ?? '';

    if (!isUserExists) {
      await authLocalDataSource.saveGoogleIdToken(idToken);
      final nameParts = _splitName(googleUser.name ?? '');
      throw OAuthRequiresRegistrationException(
        providerKey: providerKey,
        email: email,
        firstName: nameParts[0],
        lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
      );
    }

    final loginResponse = await apiConsumer.post(
      EndPoints.googleOAuthLoginUrl,
      data: {'token': idToken},
    );

    return loginResponse;
  }

  List<String> _splitName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || (parts.length == 1 && parts[0].isEmpty)) {
      return ['', ''];
    }
    return parts;
  }

  @override
  Future<void> signOutGoogle() async {
    await googleSignIn.signOut();
  }
}
