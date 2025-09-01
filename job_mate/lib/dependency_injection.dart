import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:job_mate/core/network/network_info.dart';
import 'package:job_mate/features/auth/domain/usecases/login.dart';
import 'package:job_mate/features/auth/domain/usecases/logout.dart';
import 'package:job_mate/features/auth/domain/usecases/refresh_token.dart';
import 'package:job_mate/features/auth/domain/usecases/register.dart';
import 'package:job_mate/features/auth/domain/usecases/request_otp.dart';
import 'package:job_mate/features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

// network connection
Future<void> init() async {
  // Use the named constructor to create an instance of InternetConnectionChecker
  // core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(InternetConnectionChecker.createInstance()));
  // Register other dependencies here later
  //Auth

  //bloc
  sl.registerFactory(()=>AuthBloc(
    register: sl<Register>(), 
    login: sl<Login>(), 
    logout: sl<Logout>(), 
    requestOtp: sl<RequestOtp>(), 
    refreshToken: sl<Refreshtoken>()));

  //usecases will add auth repository once the data layer is done

  sl.registerLazySingleton(()=> RequestOtp(sl()));
  sl.registerLazySingleton(()=> Register(sl()));
  sl.registerLazySingleton(()=> Login(sl()));
  sl.registerLazySingleton(()=> Logout(sl()));
  sl.registerLazySingleton(()=> Refreshtoken(sl()));
  
}
