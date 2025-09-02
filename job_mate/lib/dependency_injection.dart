import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:job_mate/core/network/network_info.dart';
import 'package:job_mate/features/auth/domain/usecases/login.dart';
import 'package:job_mate/features/auth/domain/usecases/logout.dart';
import 'package:job_mate/features/auth/domain/usecases/refresh_token.dart';
import 'package:job_mate/features/auth/domain/usecases/register.dart';
import 'package:job_mate/features/auth/domain/usecases/request_otp.dart';
import 'package:job_mate/features/auth/presentation/bloc/auth_bloc.dart';

// CV feature imports
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_mate/features/cv/data/datasources/local/profile_local_data_source_impl.dart';
import 'package:job_mate/features/cv/data/datasources/remote/cv_remote_data_source_impl.dart';
import 'package:job_mate/features/cv/data/repositories/cv_repository_impl.dart';
import 'package:job_mate/features/cv/domain/usecases/analyze_cv.dart';
import 'package:job_mate/features/cv/domain/usecases/upload_cv.dart';
import 'package:job_mate/features/cv/presentation/bloc/cv_bloc.dart';

final sl = GetIt.instance;

// network connection
Future<void> init() async {
  // Use the named constructor to create an instance of InternetConnectionChecker
  // core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(InternetConnectionChecker.createInstance()),
  );

  // Register other dependencies here later
  // Auth

  // bloc
  sl.registerFactory(
    () => AuthBloc(
      register: sl<Register>(),
      login: sl<Login>(),
      logout: sl<Logout>(),
      requestOtp: sl<RequestOtp>(),
      refreshToken: sl<Refreshtoken>(),
    ),
  );

  sl.registerLazySingleton(() => RequestOtp(sl()));
  sl.registerLazySingleton(() => Register(sl()));
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => Refreshtoken(sl()));

  // CV Feature Dependencies

  // SharedPreferences for local data source
  final prefs = await SharedPreferences.getInstance();
  final local = ProfileLocalDataSourceImpl(prefs);
  final remote = CvRemoteDataSourceImpl();
  final repository = CvRepositoryImpl(remote: remote, local: local);

  // CV use cases
  sl.registerLazySingleton(() => UploadCv(repository));
  sl.registerLazySingleton(() => AnalyzeCv(repository));

  // CV Bloc
  sl.registerFactory(
    () => CvBloc(uploadCv: sl<UploadCv>(), analyzeCv: sl<AnalyzeCv>()),
  );
}
