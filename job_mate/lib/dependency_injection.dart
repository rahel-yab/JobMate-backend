import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:job_mate/core/network/network_info.dart';
import 'package:job_mate/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:job_mate/features/auth/data/datasources/auth_local_data_source_impl.dart';
import 'package:job_mate/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:job_mate/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:job_mate/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:job_mate/features/auth/domain/repositories/auth_repository.dart';
import 'package:job_mate/features/auth/domain/usecases/login.dart';
import 'package:job_mate/features/auth/domain/usecases/logout.dart';
import 'package:job_mate/features/auth/domain/usecases/refresh_token.dart';
import 'package:job_mate/features/auth/domain/usecases/register.dart';
import 'package:job_mate/features/auth/domain/usecases/request_otp.dart';
import 'package:job_mate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:job_mate/features/cv/data/datasources/local/profile_local_data_source.dart';
import 'package:job_mate/features/cv/data/datasources/local/profile_local_data_source_impl.dart';
import 'package:job_mate/features/cv/data/datasources/remote/cv_remote_data_source.dart';
import 'package:job_mate/features/cv/data/datasources/remote/cv_remote_data_source_impl.dart';
import 'package:job_mate/features/cv/data/repositories/cv_repository_impl.dart';
import 'package:job_mate/features/cv/domain/repositories/cv_repository.dart';
import 'package:job_mate/features/cv/domain/usecases/analyze_cv.dart';
import 'package:job_mate/features/cv/domain/usecases/upload_cv.dart';
import 'package:job_mate/features/cv/presentation/bloc/cv_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // === External Dependencies ===
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Dio
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.options.baseUrl = 'https://jobmate-api-3wuo.onrender.com'; // Update with actual base URL
    // dio.options.connectTimeout = const Duration(seconds: 60);
    // dio.options.receiveTimeout = const Duration(seconds: 60);
    // dio.options.sendTimeout = const Duration(seconds: 60);
    dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Clear auth data on 401 (replace with actual method when implemented)
          sl<AuthLocalDataSource>().clearAuthData();
        }
        handler.next(error);
      },
    ));
    return dio;
  });

  // NetworkInfo
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(InternetConnectionChecker.createInstance()),
  );

  // === Auth Feature - Data Layer ===
  // Auth Local Data Source
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl<SharedPreferences>()),
  );

  // Auth Remote Data Source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Auth Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Auth Usecases
  sl.registerLazySingleton<RequestOtp>(
    () => RequestOtp(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<Register>(
    () => Register(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<Login>(
    () => Login(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<Logout>(
    () => Logout(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<Refreshtoken>(
    () => Refreshtoken(sl<AuthRepository>()),
  );

  // Auth Bloc
  sl.registerFactory(
    () => AuthBloc(
      register: sl<Register>(),
      login: sl<Login>(),
      logout: sl<Logout>(),
      requestOtp: sl<RequestOtp>(),
      refreshToken: sl<Refreshtoken>(),
    ),
  );

  // === CV Feature ===

  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(preferences: sl<SharedPreferences>()),
  );

  // CV Remote Data Source
  sl.registerLazySingleton<CvRemoteDataSource>(
    () => CvRemoteDataSourceImpl(
      dio: sl<Dio>(),
      authLocalDataSource: sl<AuthLocalDataSource>()
    ),
  );
  // Cv  Repository
  sl.registerLazySingleton<CvRepository>(
    () => CvRepositoryImpl(
      remoteDataSource: sl<CvRemoteDataSource>(),
      localDataSource: sl<ProfileLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  //Usecases
  sl.registerLazySingleton<AnalyzeCv>(
    ()=>AnalyzeCv(sl<CvRepository>()));
  sl.registerLazySingleton<UploadCv>(
    ()=>UploadCv(sl<CvRepository>()));

  // CV Bloc
  sl.registerFactory(
    () => CvBloc(
      uploadCv: sl<UploadCv>(),
      analyzeCv: sl<AnalyzeCv>(),
    ),
  );
}