import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:viora_app/core/config/oauth_config.dart';
import 'package:viora_app/core/connections/network_info.dart';
import 'package:viora_app/core/api/api_consumer.dart';
import 'package:viora_app/core/api/auth_interceptor.dart';
import 'package:viora_app/core/api/dio_consumer.dart';
import 'package:viora_app/core/database/cache/cache_helper.dart';
import 'package:viora_app/core/services/location_service.dart';
import 'package:viora_app/features/auth/data/datasources/local/auth_local.dart';
import 'package:viora_app/features/auth/data/datasources/local/auth_local_impl.dart';
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
import 'package:viora_app/features/auth/domain/usecases/sign_in_with_oauth_usecase.dart';
import 'package:viora_app/features/auth/data/repositories/oauth_repository_impl.dart';
import 'package:viora_app/features/auth/representation/blocs/oauth_bloc.dart';
import 'package:viora_app/features/profile/data/datasources/local/user_local.dart';
import 'package:viora_app/features/profile/data/datasources/local/user_local_impl.dart';
import 'package:viora_app/features/profile/data/datasources/remote/user_remote.dart';
import 'package:viora_app/features/profile/data/datasources/remote/user_remote_impl.dart';
import 'package:viora_app/features/profile/data/repositories/user_repository_impl.dart';
import 'package:viora_app/features/profile/domain/repositories/user_repository.dart';
import 'package:viora_app/features/profile/domain/usecases/change_password_usecase.dart';
import 'package:viora_app/features/organization/data/datasources/local/saved_organizations_local.dart';
import 'package:viora_app/features/organization/data/datasources/local/saved_organizations_local_impl.dart';
import 'package:viora_app/features/organization/data/datasources/remote/organization_remote.dart';
import 'package:viora_app/features/organization/data/datasources/remote/organization_remote_impl.dart';
import 'package:viora_app/features/organization/data/repositories/organization_repository_impl.dart';
import 'package:viora_app/features/organization/domain/repositories/organization_repository.dart';
import 'package:viora_app/features/organization/domain/usecases/get_branch_details_usecase.dart';
import 'package:viora_app/features/organization/domain/usecases/get_branch_schedule_usecase.dart';
import 'package:viora_app/features/organization/domain/usecases/get_organization_details_usecase.dart';
import 'package:viora_app/features/organization/representation/bloc/organization_bloc.dart';
import 'package:viora_app/features/search/data/datasources/remote/search_remote.dart';
import 'package:viora_app/features/search/data/datasources/remote/search_remote_impl.dart';
import 'package:viora_app/features/search/data/repositories/search_repository_impl.dart';
import 'package:viora_app/features/search/domain/repositories/search_repository.dart';
import 'package:viora_app/features/search/domain/usecases/search_organizations_usecase.dart';
import 'package:viora_app/features/search/domain/usecases/search_branches_usecase.dart';
import 'package:viora_app/features/search/representation/bloc/search_bloc.dart';
import 'package:viora_app/features/vivi/data/datasources/remote/ai_chat_remote.dart';
import 'package:viora_app/features/vivi/data/datasources/remote/ai_chat_remote_impl.dart';
import 'package:viora_app/features/vivi/data/repositories/ai_chat_repository_impl.dart';
import 'package:viora_app/features/vivi/domain/repositories/ai_chat_repository.dart';
import 'package:viora_app/features/vivi/domain/usecases/get_session_history_usecase.dart';
import 'package:viora_app/features/vivi/domain/usecases/get_sessions_usecase.dart';
import 'package:viora_app/features/vivi/domain/usecases/send_message_usecase.dart';
import 'package:viora_app/features/vivi/representation/blocs/chat/chat_bloc.dart';
import 'package:viora_app/features/vivi/representation/blocs/sessions/sessions_bloc.dart';

final sl = GetIt.instance;

Future<void> dependencyInjection() async {
  if (!sl.isRegistered<FlutterSecureStorage>()) {
    sl.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
  }

  if (!sl.isRegistered<Dio>()) {
    final dio = Dio();
    dio.options.baseUrl = 'http://10.0.2.2:8080';
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 15);

    // Add auth interceptor for automatic token refresh
    dio.interceptors.add(AuthInterceptor(sl(), dio));

    sl.registerSingleton<Dio>(dio);
  }

  if (!sl.isRegistered<ApiConsumer>()) {
    sl.registerLazySingleton<ApiConsumer>(() => DioConsumer(sl(), sl()));
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
      () => AuthRemoteDataSourceImpl(sl(), sl()),
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
      () => GoogleOAuthRemoteImpl(
        googleSignIn: sl(),
        apiConsumer: sl(),
        authLocalDataSource: sl(),
      ),
    );
  }

  // facade
  if (!sl.isRegistered<OAuthFacade>()) {
    sl.registerLazySingleton<OAuthFacade>(
      () => OAuthFacade(
        googleRemote: sl(),
        authLocalDataSource: sl(),
        authRemoteDataSource: sl(),
      ),
    );
  }

  // repository
  if (!sl.isRegistered<OAuthRepository>()) {
    sl.registerLazySingleton<OAuthRepository>(
      () => OAuthRepositoryImpl(
        facade: sl(),
        authLocalDataSource: sl(),
      ),
    );
  }

  // usecase
  if (!sl.isRegistered<SignInWithOAuthUseCase>()) {
    sl.registerLazySingleton<SignInWithOAuthUseCase>(
      () => SignInWithOAuthUseCase(sl()),
    );
  }

  if (!sl.isRegistered<OAuthBloc>()) {
    sl.registerFactory<OAuthBloc>(
      () => OAuthBloc(signInWithOAuthUseCase: sl()),
    );
  }

  // Profile
  if (!sl.isRegistered<UserLocal>()) {
    sl.registerLazySingleton<UserLocal>(() => UserLocalImpl(sl()));
  }

  if (!sl.isRegistered<UserRemote>()) {
    sl.registerLazySingleton<UserRemote>(
      () => UserRemoteImpl(sl(), sl(), sl()),
    );
  }

  if (!sl.isRegistered<UserRepository>()) {
    sl.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(sl(), sl()),
    );
  }

  if (!sl.isRegistered<ChangePasswordUseCase>()) {
    sl.registerLazySingleton<ChangePasswordUseCase>(
      () => ChangePasswordUseCase(sl()),
    );
  }

  // Search
  if (!sl.isRegistered<LocationService>()) {
    sl.registerLazySingleton<LocationService>(() => LocationServiceImpl());
  }

  if (!sl.isRegistered<SearchRemote>()) {
    sl.registerLazySingleton<SearchRemote>(
      () => SearchRemoteImpl(sl(), sl()),
    );
  }

  if (!sl.isRegistered<SearchRepository>()) {
    sl.registerLazySingleton<SearchRepository>(
      () => SearchRepositoryImpl(sl()),
    );
  }

  if (!sl.isRegistered<SearchOrganizationsUseCase>()) {
    sl.registerLazySingleton<SearchOrganizationsUseCase>(
      () => SearchOrganizationsUseCase(sl()),
    );
  }

  if (!sl.isRegistered<GetCountriesUseCase>()) {
    sl.registerLazySingleton<GetCountriesUseCase>(
      () => GetCountriesUseCase(sl()),
    );
  }

  if (!sl.isRegistered<GetServiceTypesUseCase>()) {
    sl.registerLazySingleton<GetServiceTypesUseCase>(
      () => GetServiceTypesUseCase(sl()),
    );
  }

  if (!sl.isRegistered<SearchBranchesUseCase>()) {
    sl.registerLazySingleton<SearchBranchesUseCase>(
      () => SearchBranchesUseCase(sl()),
    );
  }

  if (!sl.isRegistered<SearchBloc>()) {
    sl.registerFactory<SearchBloc>(
      () => SearchBloc(
        searchBranchesUseCase: sl(),
        searchOrganizationsUseCase: sl(),
        getCountriesUseCase: sl(),
        getServiceTypesUseCase: sl(),
        locationService: sl(),
      ),
    );
  }

  // AI Chat
  if (!sl.isRegistered<AiChatRemote>()) {
    sl.registerLazySingleton<AiChatRemote>(
      () => AiChatRemoteImpl(sl()),
    );
  }

  if (!sl.isRegistered<AiChatRepository>()) {
    sl.registerLazySingleton<AiChatRepository>(
      () => AiChatRepositoryImpl(sl()),
    );
  }

  if (!sl.isRegistered<SendMessageUseCase>()) {
    sl.registerLazySingleton<SendMessageUseCase>(
      () => SendMessageUseCase(sl()),
    );
  }

  if (!sl.isRegistered<GetSessionsUseCase>()) {
    sl.registerLazySingleton<GetSessionsUseCase>(
      () => GetSessionsUseCase(sl()),
    );
  }

  if (!sl.isRegistered<GetSessionHistoryUseCase>()) {
    sl.registerLazySingleton<GetSessionHistoryUseCase>(
      () => GetSessionHistoryUseCase(sl()),
    );
  }

  if (!sl.isRegistered<ChatBloc>()) {
    sl.registerFactory<ChatBloc>(
      () => ChatBloc(sl()),
    );
  }

  if (!sl.isRegistered<SessionsBloc>()) {
    sl.registerFactory<SessionsBloc>(
      () => SessionsBloc(sl(), sl()),
    );
  }

  // Organization Details
  if (!sl.isRegistered<SavedOrganizationsLocal>()) {
    sl.registerLazySingleton<SavedOrganizationsLocal>(
      () => SavedOrganizationsLocalImpl(sl()),
    );
  }

  if (!sl.isRegistered<OrganizationRemote>()) {
    sl.registerLazySingleton<OrganizationRemote>(
      () => OrganizationRemoteImpl(sl(), sl()),
    );
  }

  if (!sl.isRegistered<OrganizationRepository>()) {
    sl.registerLazySingleton<OrganizationRepository>(
      () => OrganizationRepositoryImpl(sl()),
    );
  }

  if (!sl.isRegistered<GetOrganizationDetailsUseCase>()) {
    sl.registerLazySingleton<GetOrganizationDetailsUseCase>(
      () => GetOrganizationDetailsUseCase(sl()),
    );
  }

  if (!sl.isRegistered<GetBranchDetailsUseCase>()) {
    sl.registerLazySingleton<GetBranchDetailsUseCase>(
      () => GetBranchDetailsUseCase(sl()),
    );
  }

  if (!sl.isRegistered<GetBranchScheduleUseCase>()) {
    sl.registerLazySingleton<GetBranchScheduleUseCase>(
      () => GetBranchScheduleUseCase(sl()),
    );
  }

  if (!sl.isRegistered<OrganizationBloc>()) {
    sl.registerFactory<OrganizationBloc>(
      () => OrganizationBloc(
        getOrganizationDetailsUseCase: sl(),
        getBranchDetailsUseCase: sl(),
        getBranchScheduleUseCase: sl(),
      ),
    );
  }
}
