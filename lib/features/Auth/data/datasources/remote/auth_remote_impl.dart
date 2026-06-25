import 'package:dio/dio.dart';
import 'package:viora_app/core/api/api_consumer.dart';
import 'package:viora_app/core/api/end_points.dart';
import 'package:viora_app/core/params/user_parameters.dart';
import 'package:viora_app/features/auth/data/datasources/local/auth_local.dart';
import 'package:viora_app/features/auth/data/datasources/remote/auth_remote.dart';
import 'package:viora_app/features/auth/data/models/user_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiConsumer _apiConsumer;
  final AuthLocalDataSource _authLocalDataSource;

  AuthRemoteDataSourceImpl(this._apiConsumer, this._authLocalDataSource);

  @override
  Future<UserModel> fetchCurrentUser() async {
    final userResponse = await _apiConsumer.get(
      EndPoints.meUrl,
      requiresAuth: true,
    );
    return UserModel.fromJson(userResponse);
  }

  @override
  Future<UserModel> oauthRegister({
    required String firstName,
    required String lastName,
    required String email,
    required String gender,
    required String dateOfBirth,
    required String providerKey,
  }) async {
    await _apiConsumer.postRaw(
      EndPoints.googleOAuthRegisterUrl,
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'email': email,
        'providerKey': providerKey,
      },
    );

    final idToken = await _authLocalDataSource.getGoogleIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Google idToken not found for OAuth login after registration');
    }

    final loginResponse = await _apiConsumer.post(
      EndPoints.googleOAuthLoginUrl,
      data: {'token': idToken},
    );

    final accessToken = loginResponse['accessToken'] as String?;
    final refreshToken = loginResponse['refreshToken'] as String?;

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token missing from OAuth login response');
    }

    await _authLocalDataSource.saveUserToken(accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _authLocalDataSource.saveRefreshToken(refreshToken);
    }
    await _authLocalDataSource.clearGoogleIdToken();

    final userResponse = await _apiConsumer.get(
      EndPoints.meUrl,
      requiresAuth: true,
    );

    final user = UserModel.fromJson({
      'id': loginResponse['userId']?.toString() ?? '',
      ...userResponse,
    });

    await _authLocalDataSource.saveUser(user);
    return user;
  }

  @override
  Future<UserModel> login(LoginParameters params) async {
    // 1. Call login endpoint -> get AuthResult with tokens
    final authResponse = await _apiConsumer.post(
      EndPoints.loginUrl,
      data: {'email': params.email, 'password': params.password},
    );

    // 2. Store both tokens
    final accessToken = authResponse['accessToken'] as String?;
    final refreshToken = authResponse['refreshToken'] as String?;

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token missing from response');
    }

    await _authLocalDataSource.saveUserToken(accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _authLocalDataSource.saveRefreshToken(refreshToken);
    }

    // 3. Fetch user profile from /me
    final userResponse = await _apiConsumer.get(
      EndPoints.meUrl,
      requiresAuth: true,
    );

    // 4. Build UserModel from /me response
    final user = UserModel.fromJson({
      'id': authResponse['userId']?.toString() ?? '',
      ...userResponse,
    });

    await _authLocalDataSource.saveUser(user);
    return user;
  }

  @override
  Future<UserModel> register(
    RegisterParameters params, {
    CancelToken? cancelToken,
  }) async {
    // 1. Call register endpoint -> returns user ID as string
    final dateStr =
        '${params.dateOfBirth.year.toString().padLeft(4, '0')}-'
        '${params.dateOfBirth.month.toString().padLeft(2, '0')}-'
        '${params.dateOfBirth.day.toString().padLeft(2, '0')}';

    await _apiConsumer.postRaw(
      EndPoints.registerUrl,
      data: {
        'firstName': params.firstName,
        'lastName': params.lastName,
        'dateOfBirth': dateStr,
        'gender': params.gender.name[0].toUpperCase() + params.gender.name.substring(1),
        'email': params.email,
        'password': params.password,
      },
      cancelToken: cancelToken,
    );

    // 2. Auto-login to get JWT and redirect as logged in
    return await login(
      LoginParameters(email: params.email, password: params.password),
    );
  }
}
