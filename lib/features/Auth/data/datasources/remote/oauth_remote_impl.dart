import 'package:google_sign_in/google_sign_in.dart';
import 'package:viora_app/core/api/api_consumer.dart';
import 'package:viora_app/core/api/end_points.dart';
import 'package:viora_app/core/errors/exceptions.dart';
import 'package:viora_app/features/auth/data/datasources/remote/oauth_remote.dart';
import 'package:viora_app/features/auth/data/models/oauth_user_model.dart';

class GoogleOAuthRemoteImpl implements OAuthRemote {
  final GoogleSignIn googleSignIn;
  final ApiConsumer apiConsumer;

  GoogleOAuthRemoteImpl({
    required this.googleSignIn,
    required this.apiConsumer,
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

    final auth = account.authentication; // This for the idToken
    final idToken = auth.idToken;
    final authorization = await account
        .authorizationClient // This for the accessToken
        .authorizationForScopes(['email']);
    final accessToken = authorization?.accessToken;
    if ((idToken == null || idToken.isEmpty) &&
        (accessToken == null || accessToken.isEmpty)) {
      throw Exception('Google token missing');
    }

    return OAuthUserModel.fromGoogleAccount(
      account: account,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  @override
  Future<String> exchangeGoogleToken(OAuthUserModel googleUser) async {
    final idToken = googleUser.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Google idToken missing');
    }

    final response = await apiConsumer.post(
      EndPoints.googleLoginUrl,
      data: {
        'provider': 'google',
        'idToken': idToken,
        if (googleUser.accessToken != null &&
            googleUser.accessToken!.isNotEmpty)
          'accessToken': googleUser.accessToken,
        'email': googleUser.email,
        'name': googleUser.name,
        'photoUrl': googleUser.photoUrl,
        'googleId': googleUser.id,
      },
    );

    final token = _extractJwt(response);
    if (token == null || token.isEmpty) {
      throw Exception('Backend JWT token missing');
    }

    return token;
  }

  String? _extractJwt(Map<String, dynamic> response) {
    final directToken =
        _asNonEmptyString(response['token']) ??
        _asNonEmptyString(response['accessToken']) ??
        _asNonEmptyString(response['jwt']);
    if (directToken != null) {
      return directToken;
    }

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return _asNonEmptyString(data['token']) ??
          _asNonEmptyString(data['accessToken']) ??
          _asNonEmptyString(data['jwt']);
    }

    return null;
  }

  String? _asNonEmptyString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  @override
  Future<void> signOutGoogle() async {
    await googleSignIn.signOut();
  }
}
