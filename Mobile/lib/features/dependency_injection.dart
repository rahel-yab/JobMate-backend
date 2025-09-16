// import 'package:dio/dio.dart';
// import 'package:get_it/get_it.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
// import 'package:job_mate/core/network/network_info.dart';
// import 'package:job_mate/features/auth/data/datasources/auth_local_data_source.dart';
// import 'package:job_mate/features/auth/data/datasources/auth_local_data_source_impl.dart';
// import 'package:job_mate/features/auth/data/datasources/auth_remote_data_source.dart';
// import 'package:job_mate/features/auth/data/datasources/auth_remote_data_source_impl.dart';
// import 'package:job_mate/features/auth/data/repositories/auth_repository_impl.dart';
// import 'package:job_mate/features/auth/domain/repositories/auth_repository.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// final sl = GetIt.instance;

// Future<void> init() async {
//   // External dependencies
//   final sharedPreferences = await SharedPreferences.getInstance();
//   sl.registerLazySingleton(() => sharedPreferences);
  
//   // Network
//   sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(InternetConnectionChecker.createInstance()));
  
//   // Auth data sources
//   sl.registerLazySingleton<AuthLocalDataSource>(
//     () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
//   );
  
//   // Dio configuration
//   sl.registerLazySingleton<Dio>(() {
//     final dio = Dio();
//     dio.options.baseUrl = 'http://localhost:8080'; // Update this with your actual base URL
//     dio.options.connectTimeout = const Duration(seconds: 30);
//     dio.options.receiveTimeout = const Duration(seconds: 30);
//     dio.options.sendTimeout = const Duration(seconds: 30);
    
//     // Add interceptors for authentication
//     dio.interceptors.add(InterceptorsWrapper(
//       onError: (error, handler) {
//         // Handle 401 errors by clearing local auth data
//         if (error.response?.statusCode == 401) {
//           sl<AuthLocalDataSource>().clearAuthData();
//         }
//         handler.next(error);
//       },
//     ));
    
//     return dio;
//   });
  
//   sl.registerLazySingleton<AuthRemoteDataSource>(
//     () => AuthRemoteDataSourceImpl(dio: sl()),
//   );
  
//   // Auth repository
//   sl.registerLazySingleton<AuthRepository>(
//     () => AuthRepositoryImpl(
//       remoteDataSource: sl(),
//       localDataSource: sl(),
//       networkInfo: sl(),
//     ),
//   );
  
//   // Register other dependencies here later
// }