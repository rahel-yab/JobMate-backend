import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:job_mate/core/network/network_info.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Use the named constructor to create an instance of InternetConnectionChecker
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(InternetConnectionChecker.createInstance()));
  // Register other dependencies here later
}