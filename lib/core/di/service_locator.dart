import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
import 'package:viora_app/features/profile/data/datasources/remote/medical_record_remote.dart';
import 'package:viora_app/features/profile/data/datasources/remote/medical_record_remote_impl.dart';
import 'package:viora_app/features/profile/data/repositories/user_repository_impl.dart';
import 'package:viora_app/features/profile/data/repositories/medical_record_repository_impl.dart';
import 'package:viora_app/features/profile/domain/repositories/user_repository.dart';
import 'package:viora_app/features/profile/domain/repositories/medical_record_repository.dart';
import 'package:viora_app/features/profile/domain/usecases/change_password_usecase.dart';
import 'package:viora_app/features/profile/domain/usecases/get_visited_organization_ids_usecase.dart';
import 'package:viora_app/features/profile/domain/usecases/get_medical_record_usecase.dart';
import 'package:viora_app/features/profile/domain/usecases/create_medical_record_usecase.dart';
import 'package:viora_app/features/profile/domain/usecases/update_medical_record_usecase.dart';
import 'package:viora_app/features/profile/representation/blocs/medical_record/medical_record_bloc.dart';
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
import 'package:viora_app/core/services/notification_service.dart';
import 'package:viora_app/features/wellness/data/wellness_local.dart';
import 'package:viora_app/features/wellness/data/wellness_local_impl.dart';
import 'package:viora_app/features/wellness/presentation/cubits/sleep_cubit.dart';
import 'package:viora_app/features/wellness/presentation/cubits/water_reminder_cubit.dart';
import 'package:viora_app/features/wellness/presentation/cubits/workout_reminder_cubit.dart';
import 'package:viora_app/features/service/data/datasources/remote/service_remote.dart';
import 'package:viora_app/features/service/data/datasources/remote/service_remote_impl.dart';
import 'package:viora_app/features/service/data/repositories/service_repository_impl.dart';
import 'package:viora_app/features/service/domain/repositories/service_repository.dart';
import 'package:viora_app/features/service/domain/usecases/get_services_by_branch_usecase.dart';
import 'package:viora_app/features/service/representation/bloc/service_bloc.dart';
import 'package:viora_app/features/staff/data/datasources/remote/staff_remote.dart';
import 'package:viora_app/features/staff/data/datasources/remote/staff_remote_impl.dart';
import 'package:viora_app/features/staff/data/repositories/staff_repository_impl.dart';
import 'package:viora_app/features/staff/domain/repositories/staff_repository.dart';
import 'package:viora_app/features/staff/domain/usecases/get_staff_by_branch_service.dart';
import 'package:viora_app/features/staff/domain/usecases/get_staff_schedule.dart';
import 'package:viora_app/features/staff/representation/bloc/staff_bloc.dart';
import 'package:viora_app/features/appointments/data/datasources/remote/appointment_remote.dart';
import 'package:viora_app/features/appointments/data/datasources/remote/appointment_remote_impl.dart';
import 'package:viora_app/features/appointments/data/repositories/appointment_repository_impl.dart';
import 'package:viora_app/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:viora_app/features/appointments/domain/usecases/book_appointment.dart';
import 'package:viora_app/features/appointments/domain/usecases/get_doctor_appointments.dart';
import 'package:viora_app/features/appointments/domain/usecases/get_staff_schedule.dart';
import 'package:viora_app/features/appointments/domain/usecases/get_user_appointments.dart';
import 'package:viora_app/features/appointments/domain/usecases/cancel_appointment.dart';
import 'package:viora_app/features/appointments/representation/bloc/appointment_bloc.dart';
import 'package:viora_app/features/appointments/representation/bloc/user_appointments_bloc.dart';
import 'package:viora_app/features/reviews/data/datasources/remote/review_remote.dart';
import 'package:viora_app/features/reviews/data/datasources/remote/review_remote_impl.dart';
import 'package:viora_app/features/reviews/data/repositories/review_repository_impl.dart';
import 'package:viora_app/features/reviews/domain/repositories/review_repository.dart';
import 'package:viora_app/features/reviews/domain/usecases/check_user_feedback_usecase.dart';
import 'package:viora_app/features/reviews/domain/usecases/get_branch_reviews_usecase.dart';
import 'package:viora_app/features/reviews/domain/usecases/submit_feedback_usecase.dart';
import 'package:viora_app/features/reviews/domain/usecases/update_feedback_usecase.dart';
import 'package:viora_app/features/reviews/representation/bloc/review_bloc.dart';
import 'package:viora_app/features/forms/data/datasources/remote/form_remote.dart';
import 'package:viora_app/features/forms/data/datasources/remote/form_remote_impl.dart';
import 'package:viora_app/features/forms/data/repositories/form_repository_impl.dart';
import 'package:viora_app/features/forms/domain/repositories/form_repository.dart';
import 'package:viora_app/features/forms/domain/usecases/get_service_form.dart';
import 'package:viora_app/features/forms/domain/usecases/submit_form_answer.dart';
import 'package:viora_app/features/forms/domain/usecases/upload_form_file.dart';
import 'package:viora_app/features/forms/presentation/bloc/form_bloc.dart';
import 'package:viora_app/features/prescription/data/datasources/remote/prescription_remote.dart';
import 'package:viora_app/features/prescription/data/datasources/remote/prescription_remote_impl.dart';
import 'package:viora_app/features/prescription/data/repositories/prescription_repository_impl.dart';
import 'package:viora_app/features/prescription/domain/repositories/prescription_repository.dart';
import 'package:viora_app/features/prescription/domain/usecases/get_prescription_by_appointment.dart';
import 'package:viora_app/features/prescription/presentation/bloc/prescription_bloc.dart';
import 'package:viora_app/features/wallet/data/datasources/wallet_remote.dart';
import 'package:viora_app/features/wallet/data/datasources/wallet_remote_impl.dart';
import 'package:viora_app/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:viora_app/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:viora_app/features/wallet/domain/usecases/get_wallet_usecase.dart';
import 'package:viora_app/features/wallet/domain/usecases/open_wallet_usecase.dart';
import 'package:viora_app/features/wallet/domain/usecases/recharge_wallet_usecase.dart';
import 'package:viora_app/features/wallet/presentation/bloc/wallet_bloc.dart';

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
      () => OAuthRepositoryImpl(facade: sl(), authLocalDataSource: sl()),
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

  if (!sl.isRegistered<GetVisitedOrganizationIdsUseCase>()) {
    sl.registerLazySingleton<GetVisitedOrganizationIdsUseCase>(
      () => GetVisitedOrganizationIdsUseCase(sl(), sl()),
    );
  }

  // Medical Record
  if (!sl.isRegistered<MedicalRecordRemote>()) {
    sl.registerLazySingleton<MedicalRecordRemote>(
      () => MedicalRecordRemoteImpl(sl()),
    );
  }

  if (!sl.isRegistered<MedicalRecordRepository>()) {
    sl.registerLazySingleton<MedicalRecordRepository>(
      () => MedicalRecordRepositoryImpl(sl()),
    );
  }

  if (!sl.isRegistered<GetMedicalRecordUseCase>()) {
    sl.registerLazySingleton<GetMedicalRecordUseCase>(
      () => GetMedicalRecordUseCase(sl()),
    );
  }

  if (!sl.isRegistered<CreateMedicalRecordUseCase>()) {
    sl.registerLazySingleton<CreateMedicalRecordUseCase>(
      () => CreateMedicalRecordUseCase(sl()),
    );
  }

  if (!sl.isRegistered<UpdateMedicalRecordUseCase>()) {
    sl.registerLazySingleton<UpdateMedicalRecordUseCase>(
      () => UpdateMedicalRecordUseCase(sl()),
    );
  }

  if (!sl.isRegistered<MedicalRecordBloc>()) {
    sl.registerLazySingleton<MedicalRecordBloc>(
      () => MedicalRecordBloc(
        getMedicalRecord: sl<GetMedicalRecordUseCase>(),
        createMedicalRecord: sl<CreateMedicalRecordUseCase>(),
        updateMedicalRecord: sl<UpdateMedicalRecordUseCase>(),
      ),
    );
  }

  // Search
  if (!sl.isRegistered<LocationService>()) {
    sl.registerLazySingleton<LocationService>(() => LocationServiceImpl());
  }

  if (!sl.isRegistered<SearchRemote>()) {
    sl.registerLazySingleton<SearchRemote>(() => SearchRemoteImpl(sl(), sl()));
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
    sl.registerLazySingleton<AiChatRemote>(() => AiChatRemoteImpl(sl()));
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
    sl.registerFactory<ChatBloc>(() => ChatBloc(sl()));
  }

  if (!sl.isRegistered<SessionsBloc>()) {
    sl.registerFactory<SessionsBloc>(() => SessionsBloc(sl(), sl()));
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

  // Wellness
  if (!sl.isRegistered<FlutterLocalNotificationsPlugin>()) {
    sl.registerLazySingleton<FlutterLocalNotificationsPlugin>(
      () => FlutterLocalNotificationsPlugin(),
    );
  }

  if (!sl.isRegistered<NotificationService>()) {
    sl.registerLazySingleton<NotificationService>(
      () => NotificationServiceImpl(sl()),
    );
  }

  if (!sl.isRegistered<WellnessLocal>()) {
    sl.registerLazySingleton<WellnessLocal>(() => WellnessLocalImpl(sl()));
  }

  if (!sl.isRegistered<WaterReminderCubit>()) {
    sl.registerFactory<WaterReminderCubit>(
      () => WaterReminderCubit(sl(), sl()),
    );
  }

  if (!sl.isRegistered<WorkoutReminderCubit>()) {
    sl.registerFactory<WorkoutReminderCubit>(
      () => WorkoutReminderCubit(sl(), sl()),
    );
  }

  if (!sl.isRegistered<SleepCubit>()) {
    sl.registerFactory<SleepCubit>(() => SleepCubit(sl()));
  }

  // Service Listing
  if (!sl.isRegistered<ServiceRemoteDataSource>()) {
    sl.registerLazySingleton<ServiceRemoteDataSource>(
      () => ServiceRemoteDataSourceImpl(sl(), sl()),
    );
  }

  if (!sl.isRegistered<ServiceRepository>()) {
    sl.registerLazySingleton<ServiceRepository>(
      () => ServiceRepositoryImpl(sl()),
    );
  }

  if (!sl.isRegistered<GetServicesByBranchUseCase>()) {
    sl.registerLazySingleton<GetServicesByBranchUseCase>(
      () => GetServicesByBranchUseCase(sl()),
    );
  }

  if (!sl.isRegistered<ServiceBloc>()) {
    sl.registerFactory<ServiceBloc>(
      () => ServiceBloc(getServicesByBranchUseCase: sl()),
    );
  }

  // Staff / Doctors
  if (!sl.isRegistered<StaffRemoteDataSource>()) {
    sl.registerLazySingleton<StaffRemoteDataSource>(
      () => StaffRemoteDataSourceImpl(sl(), sl()),
    );
  }

  if (!sl.isRegistered<StaffRepository>()) {
    sl.registerLazySingleton<StaffRepository>(
      () => StaffRepositoryImpl(sl(), sl(), sl()),
    );
  }

  if (!sl.isRegistered<GetStaffByBranchServiceUseCase>()) {
    sl.registerLazySingleton<GetStaffByBranchServiceUseCase>(
      () => GetStaffByBranchServiceUseCase(sl()),
    );
  }

  if (!sl.isRegistered<GetStaffScheduleUseCase>()) {
    sl.registerLazySingleton<GetStaffScheduleUseCase>(
      () => GetStaffScheduleUseCase(sl()),
    );
  }

  if (!sl.isRegistered<StaffBloc>()) {
    sl.registerFactory<StaffBloc>(
      () => StaffBloc(getStaffByBranchService: sl(), getStaffSchedule: sl()),
    );
  }

  // Appointments
  if (!sl.isRegistered<AppointmentRemoteDataSource>()) {
    sl.registerLazySingleton<AppointmentRemoteDataSource>(
      () => AppointmentRemoteDataSourceImpl(sl(), sl()),
    );
  }

  if (!sl.isRegistered<AppointmentRepository>()) {
    sl.registerLazySingleton<AppointmentRepository>(
      () => AppointmentRepositoryImpl(sl()),
    );
  }

  if (!sl.isRegistered<GetDoctorAppointmentsUseCase>()) {
    sl.registerLazySingleton<GetDoctorAppointmentsUseCase>(
      () => GetDoctorAppointmentsUseCase(sl()),
    );
  }

  if (!sl.isRegistered<BookAppointmentUseCase>()) {
    sl.registerLazySingleton<BookAppointmentUseCase>(
      () => BookAppointmentUseCase(sl()),
    );
  }

  if (!sl.isRegistered<GetDoctorDayShiftUseCase>()) {
    sl.registerLazySingleton<GetDoctorDayShiftUseCase>(
      () => GetDoctorDayShiftUseCase(sl()),
    );
  }

  if (!sl.isRegistered<AppointmentBloc>()) {
    sl.registerFactory<AppointmentBloc>(
      () => AppointmentBloc(
        getDoctorAppointments: sl(),
        getStaffSchedule: sl(),
        bookAppointment: sl(),
      ),
    );
  }

  if (!sl.isRegistered<GetUserAppointmentsUseCase>()) {
    sl.registerLazySingleton<GetUserAppointmentsUseCase>(
      () => GetUserAppointmentsUseCase(sl()),
    );
  }

  if (!sl.isRegistered<CancelAppointmentUseCase>()) {
    sl.registerLazySingleton<CancelAppointmentUseCase>(
      () => CancelAppointmentUseCase(sl()),
    );
  }

  if (!sl.isRegistered<UserAppointmentsBloc>()) {
    sl.registerFactory<UserAppointmentsBloc>(
      () => UserAppointmentsBloc(
        getUserAppointments: sl(),
        cancelAppointment: sl(),
      ),
    );
  }

  // Reviews & Feedback
  if (!sl.isRegistered<ReviewRemote>()) {
    sl.registerLazySingleton<ReviewRemote>(() => ReviewRemoteImpl(sl()));
  }

  if (!sl.isRegistered<ReviewRepository>()) {
    sl.registerLazySingleton<ReviewRepository>(
      () => ReviewRepositoryImpl(sl()),
    );
  }

  if (!sl.isRegistered<GetBranchReviewsUseCase>()) {
    sl.registerLazySingleton<GetBranchReviewsUseCase>(
      () => GetBranchReviewsUseCase(sl()),
    );
  }

  if (!sl.isRegistered<SubmitFeedbackUseCase>()) {
    sl.registerLazySingleton<SubmitFeedbackUseCase>(
      () => SubmitFeedbackUseCase(sl()),
    );
  }

  if (!sl.isRegistered<CheckUserFeedbackUseCase>()) {
    sl.registerLazySingleton<CheckUserFeedbackUseCase>(
      () => CheckUserFeedbackUseCase(sl()),
    );
  }

  if (!sl.isRegistered<UpdateFeedbackUseCase>()) {
    sl.registerLazySingleton<UpdateFeedbackUseCase>(
      () => UpdateFeedbackUseCase(sl()),
    );
  }

  if (!sl.isRegistered<ReviewBloc>()) {
    sl.registerFactory<ReviewBloc>(
      () => ReviewBloc(getBranchReviewsUseCase: sl()),
    );
  }

  // Forms
  if (!sl.isRegistered<FormRemoteDataSource>()) {
    sl.registerLazySingleton<FormRemoteDataSource>(
      () => FormRemoteDataSourceImpl(sl(), sl()),
    );
  }

  if (!sl.isRegistered<FormRepository>()) {
    sl.registerLazySingleton<FormRepository>(() => FormRepositoryImpl(sl()));
  }

  if (!sl.isRegistered<GetServiceFormUseCase>()) {
    sl.registerLazySingleton<GetServiceFormUseCase>(
      () => GetServiceFormUseCase(sl()),
    );
  }

  if (!sl.isRegistered<SubmitFormAnswerUseCase>()) {
    sl.registerLazySingleton<SubmitFormAnswerUseCase>(
      () => SubmitFormAnswerUseCase(sl()),
    );
  }

  if (!sl.isRegistered<UploadFormFileUseCase>()) {
    sl.registerLazySingleton<UploadFormFileUseCase>(
      () => UploadFormFileUseCase(sl()),
    );
  }

  if (!sl.isRegistered<FormBloc>()) {
    sl.registerFactory<FormBloc>(
      () => FormBloc(
        getServiceForm: sl(),
        bookAppointment: sl(),
        submitFormAnswer: sl(),
        uploadFormFile: sl(),
      ),
    );
  }

  // Prescription
  if (!sl.isRegistered<PrescriptionRemoteDataSource>()) {
    sl.registerLazySingleton<PrescriptionRemoteDataSource>(
      () => PrescriptionRemoteDataSourceImpl(sl(), sl()),
    );
  }

  if (!sl.isRegistered<PrescriptionRepository>()) {
    sl.registerLazySingleton<PrescriptionRepository>(
      () => PrescriptionRepositoryImpl(sl()),
    );
  }

  if (!sl.isRegistered<GetPrescriptionByAppointment>()) {
    sl.registerLazySingleton<GetPrescriptionByAppointment>(
      () => GetPrescriptionByAppointment(sl()),
    );
  }

  if (!sl.isRegistered<PrescriptionBloc>()) {
    sl.registerFactory<PrescriptionBloc>(
      () => PrescriptionBloc(getPrescriptionByAppointment: sl()),
    );
  }

  // Wallet
  if (!sl.isRegistered<WalletRemoteDataSource>()) {
    sl.registerLazySingleton<WalletRemoteDataSource>(
      () => WalletRemoteDataSourceImpl(sl()),
    );
  }

  if (!sl.isRegistered<WalletRepository>()) {
    sl.registerLazySingleton<WalletRepository>(
      () => WalletRepositoryImpl(sl()),
    );
  }

  if (!sl.isRegistered<GetWalletUseCase>()) {
    sl.registerLazySingleton<GetWalletUseCase>(() => GetWalletUseCase(sl()));
  }

  if (!sl.isRegistered<OpenWalletUseCase>()) {
    sl.registerLazySingleton<OpenWalletUseCase>(() => OpenWalletUseCase(sl()));
  }

  if (!sl.isRegistered<RechargeWalletUseCase>()) {
    sl.registerLazySingleton<RechargeWalletUseCase>(
      () => RechargeWalletUseCase(sl()),
    );
  }

  if (!sl.isRegistered<WalletBloc>()) {
    sl.registerFactory<WalletBloc>(
      () => WalletBloc(
        getWalletUseCase: sl(),
        openWalletUseCase: sl(),
        rechargeWalletUseCase: sl(),
      ),
    );
  }
}
