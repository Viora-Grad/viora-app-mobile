import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:viora_app/core/connections/network_info.dart';
import 'package:viora_app/core/api/api_consumer.dart';
import 'package:viora_app/core/api/dio_consumer.dart';
import 'package:viora_app/core/database/cache/cache_helper.dart';



final sl = GetIt.instance;

Future<void> dependencyInjection() async {
  // Register dependencies here
  // Dio
  sl.registerSingleton<Dio>(Dio());


  // Api Consumer
  sl.registerLazySingleton<ApiConsumer>(() => DioConsumer(sl()));


  // Dependency
  sl.registerLazySingleton<DataConnectionChecker>(() => DataConnectionChecker());


  // Repositories
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));


  // Cache Helper
  sl.registerLazySingleton<CacheHelper>(() => CacheHelperImpl());


  // Use Cases



  // Blocs



}