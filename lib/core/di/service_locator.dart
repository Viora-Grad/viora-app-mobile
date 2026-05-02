import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:viora_app/core/config/app_flags.dart';
import 'package:viora_app/core/config/oauth_config.dart';
import 'package:viora_app/core/connections/network_info.dart';
import 'package:viora_app/core/api/api_consumer.dart';
import 'package:viora_app/core/api/dio_consumer.dart';
import 'package:viora_app/core/database/cache/cache_helper.dart';
import 'package:viora_app/features/auth/data/datasources/local/auth_local.dart';
import 'package:viora_app/features/auth/data/datasources/local/auth_local_impl.dart';
import 'package:viora_app/features/auth/data/datasources/dummy/auth_remote_dummy_impl.dart';
import 'package:viora_app/features/auth/data/datasources/remote/auth_remote.dart';
import 'package:viora_app/features/auth/data/datasources/remote/auth_remote_impl.dart';
import 'package:viora_app/features/auth/data/datasources/remote/oauth_remote_impl.dart';
import 'package:viora_app/features/auth/data/repositories/auth_local_repository_impl.dart';
import 'package:viora_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:viora_app/features/auth/domain/repositories/auth_local_repository.dart';
import 'package:viora_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:viora_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:viora_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:viora_app/features/auth/representation/blocs/login_bloc.dart';
import 'package:viora_app/features/auth/representation/blocs/register_bloc.dart';
import 'package:viora_app/features/splash/representation/blocs/splash_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:viora_app/features/auth/data/datasources/remote/oauth_remote.dart';
import 'package:viora_app/features/auth/data/datasources/facade/oauth_facade.dart';
import 'package:viora_app/features/auth/domain/repositories/oauth_repository.dart';
import 'package:viora_app/features/auth/domain/usecases/get_cached_oauth_token_usecase.dart';
import 'package:viora_app/features/auth/domain/usecases/sign_in_with_oauth_usecase.dart';
import 'package:viora_app/features/auth/data/repositories/oauth_repository_impl.dart';
import 'package:viora_app/features/auth/representation/blocs/oauth_bloc.dart';

final sl = GetIt.instance;

Future<void> dependencyInjection() async {
  if (!sl.isRegistered<Dio>()) {
    sl.registerSingleton<Dio>(Dio());
  }

  if (!sl.isRegistered<ApiConsumer>()) {
    sl.registerLazySingleton<ApiConsumer>(() => DioConsumer(sl()));
  }

  if (!sl.isRegistered<DataConnectionChecker>()) {
    sl.registerLazySingleton<DataConnectionChecker>(
      () => DataConnectionChecker(),
    );
  }

  if (!sl.isRegistered<NetworkInfo>()) {
    sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  }

  if (!sl.isRegistered<SharedPreferences>()) {
    final sharedPreferences = await SharedPreferences.getInstance();
    sl.registerSingleton<SharedPreferences>(sharedPreferences);
  }

  if (!sl.isRegistered<FlutterSecureStorage>()) {
    sl.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
  }

  if (!sl.isRegistered<CacheHelper>()) {
    sl.registerLazySingleton<CacheHelper>(() => CacheHelperImpl(sl()));
  }

  if (!sl.isRegistered<SplashBloc>()) {
    sl.registerFactory<SplashBloc>(() => SplashBloc());
  }

  if (!sl.isRegistered<AuthLocalDataSource>()) {
    sl.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalImpl(secureStorage: sl()),
    );
  }

  if (!sl.isRegistered<AuthRemoteDataSource>()) {
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => useDummyAuthApi
          ? AuthRemoteDummyDataSourceImpl()
          : AuthRemoteDataSourceImpl(sl(), sl()),
    );
  }

  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl()),
    );
  }

  if (!sl.isRegistered<AuthLocalRepository>()) {
    sl.registerLazySingleton<AuthLocalRepository>(
      () => AuthLocalRepositoryImpl(sl()),
    );
  }

  if (!sl.isRegistered<RegisterUsecase>()) {
    sl.registerLazySingleton<RegisterUsecase>(() => RegisterUsecase(sl()));
  }

  if (!sl.isRegistered<RegisterBloc>()) {
    sl.registerFactory<RegisterBloc>(() => RegisterBloc(registerUsecase: sl()));
  }

  if (!sl.isRegistered<LoginUsecase>()) {
    sl.registerLazySingleton<LoginUsecase>(() => LoginUsecase(sl()));
  }

  if (!sl.isRegistered<LoginBloc>()) {
    sl.registerFactory<LoginBloc>(() => LoginBloc(loginUsecase: sl()));
  }

  // register GoogleSignIn
  if (!sl.isRegistered<GoogleSignIn>()) {
    await GoogleSignIn.instance.initialize(
      serverClientId: OAuthConfig.googleServerClientId,
    );
    sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);
  }

  // register OAuth remote impl
  if (!sl.isRegistered<OAuthRemote>()) {
    sl.registerLazySingleton<OAuthRemote>(
      () => GoogleOAuthRemoteImpl(googleSignIn: sl(), apiConsumer: sl()),
    );
  }

  // facade
  if (!sl.isRegistered<OAuthFacade>()) {
    sl.registerLazySingleton<OAuthFacade>(
      () => OAuthFacade(googleRemote: sl()),
    );
  }

  // repository
  if (!sl.isRegistered<OAuthRepository>()) {
    sl.registerLazySingleton<OAuthRepository>(
      () => OAuthRepositoryImpl(facade: sl(), cacheHelper: sl()),
    );
  }

  // usecase
  if (!sl.isRegistered<SignInWithOAuthUseCase>()) {
    sl.registerLazySingleton<SignInWithOAuthUseCase>(
      () => SignInWithOAuthUseCase(sl()),
    );
  }

  if (!sl.isRegistered<GetCachedOAuthTokenUseCase>()) {
    sl.registerLazySingleton<GetCachedOAuthTokenUseCase>(
      () => GetCachedOAuthTokenUseCase(sl()),
    );
  }

  if (!sl.isRegistered<OAuthBloc>()) {
    sl.registerFactory<OAuthBloc>(
      () => OAuthBloc(signInWithOAuthUseCase: sl()),
    );
  }
}
