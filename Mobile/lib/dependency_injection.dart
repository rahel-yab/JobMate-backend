import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:job_mate/core/network/network_info.dart';
import 'package:job_mate/core/network/auth_interceptor.dart';
import 'package:job_mate/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:job_mate/features/auth/data/datasources/auth_local_data_source_impl.dart';
import 'package:job_mate/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:job_mate/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:job_mate/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:job_mate/features/auth/domain/repositories/auth_repository.dart';
import 'package:job_mate/features/auth/domain/usecases/google_login.dart';
import 'package:job_mate/features/auth/domain/usecases/login.dart';
import 'package:job_mate/features/auth/domain/usecases/logout.dart';
import 'package:job_mate/features/auth/domain/usecases/refresh_token.dart';
import 'package:job_mate/features/auth/domain/usecases/register.dart';
import 'package:job_mate/features/auth/domain/usecases/request_otp.dart';
import 'package:job_mate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:job_mate/features/cv/data/datasources/local/profile_local_data_source.dart';
import 'package:job_mate/features/cv/data/datasources/local/profile_local_data_source_impl.dart';
import 'package:job_mate/features/cv/data/datasources/remote/cv_chat_remote_data_source.dart';
import 'package:job_mate/features/cv/data/datasources/remote/cv_chat_remote_data_source_impl.dart';
import 'package:job_mate/features/cv/data/datasources/remote/cv_remote_data_source.dart';
import 'package:job_mate/features/cv/data/datasources/remote/cv_remote_data_source_impl.dart';
import 'package:job_mate/features/cv/data/repositories/cv_chat_repository_impl.dart';
import 'package:job_mate/features/cv/data/repositories/cv_repository_impl.dart';
import 'package:job_mate/features/cv/domain/repositories/cv_chat_repository.dart';
import 'package:job_mate/features/cv/domain/repositories/cv_repository.dart';
import 'package:job_mate/features/cv/domain/usecases/analyze_cv.dart';
import 'package:job_mate/features/cv/domain/usecases/create_chat_session.dart';
import 'package:job_mate/features/cv/domain/usecases/get_all_chat_sessions.dart';
import 'package:job_mate/features/cv/domain/usecases/get_chat_history.dart';
import 'package:job_mate/features/cv/domain/usecases/get_suggestions.dart';
import 'package:job_mate/features/cv/domain/usecases/send_chat_message.dart';
import 'package:job_mate/features/cv/domain/usecases/upload_cv.dart';
import 'package:job_mate/features/cv/presentation/bloc/cv/cv_bloc.dart';
import 'package:job_mate/features/cv/presentation/bloc/cv_chat/cv_chat_bloc.dart';
import 'package:job_mate/features/interview/data/datasources/interview_local_data_source.dart';
import 'package:job_mate/features/interview/data/datasources/interview_local_data_source_impl.dart';
import 'package:job_mate/features/interview/data/datasources/interview_remote_data_source.dart';
import 'package:job_mate/features/interview/data/datasources/interview_remote_data_source_impl.dart';
import 'package:job_mate/features/interview/data/repositories/interview_repository_impl.dart';
import 'package:job_mate/features/interview/domain/repositories/interview_repository.dart';
import 'package:job_mate/features/interview/domain/usecases/continue_structured_session.dart';
import 'package:job_mate/features/interview/domain/usecases/get_freeform_history.dart';
import 'package:job_mate/features/interview/domain/usecases/get_structured_history.dart';
import 'package:job_mate/features/interview/domain/usecases/get_user_freeform_chats.dart';
import 'package:job_mate/features/interview/domain/usecases/get_user_structured_chats.dart';
import 'package:job_mate/features/interview/domain/usecases/send_freeform_message.dart';
import 'package:job_mate/features/interview/domain/usecases/send_structured_answer.dart';
import 'package:job_mate/features/interview/domain/usecases/start_freeform_session.dart';
import 'package:job_mate/features/interview/domain/usecases/start_structured_session.dart';
import 'package:job_mate/features/interview/presentation/blocs/interview_bloc.dart';
import 'package:job_mate/features/job_search/data/datasource/remote/job_chat_remote_data_source.dart';
import 'package:job_mate/features/job_search/data/datasource/remote/job_chat_remote_data_source_impl.dart';
import 'package:job_mate/features/job_search/data/repositories/job_chat_repository_impl.dart';
import 'package:job_mate/features/job_search/domain/repositories/job_chat_repository.dart';
import 'package:job_mate/features/job_search/domain/usecases/get_all_chats.dart';
import 'package:job_mate/features/job_search/domain/usecases/get_chat_by_id.dart';
import 'package:job_mate/features/job_search/domain/usecases/send_chat_message.dart';

import 'package:job_mate/features/job_search/presentation/bloc/job_search_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';


final sl = GetIt.instance;

Future<void> init() async {
  // === External Dependencies ===
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Dio
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    // dio.options.baseUrl = 'https://jobmate-api-3wuo.onrender.com';
    // dio.options.baseUrl = 'https://jobmate-api-0d1l.onrender.com';
    // dio.options.baseUrl = 'https://g6-jobmate-3.onrender.com';
    dio.options.baseUrl = 'https://jobmate-api-0d1l.onrender.com';
    // dio.options.baseUrl = 'https://g6-jobmate-3.onrender.com';
    // dio.options.connectTimeout = const Duration(seconds: 60);R
    // dio.options.receiveTimeout = const Duration(seconds: 60);
    // dio.options.sendTimeout = const Duration(seconds: 60);
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
  // AuthInterceptor (registered after AuthLocalDataSource)
  sl.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(localDataSource: sl<AuthLocalDataSource>()),
  );

  // Add AuthInterceptor to Dio after both are registered
  sl<Dio>().interceptors.add(sl<AuthInterceptor>());

  // Attach AuthInterceptor **after repository is ready**
  // sl<Dio>().interceptors.add(
  //   AuthInterceptor(
  //     authRepository: sl<AuthRepository>(),
  //     localDataSource: sl<AuthLocalDataSource>(),
  //     dio: sl<Dio>(),
  //   ),
  // );

  // Auth Usecases
  sl.registerLazySingleton<RequestOtp>(() => RequestOtp(sl<AuthRepository>()));
  sl.registerLazySingleton<Register>(() => Register(sl<AuthRepository>()));
  sl.registerLazySingleton<Login>(() => Login(sl<AuthRepository>()));
  sl.registerLazySingleton<Logout>(() => Logout(sl<AuthRepository>()));
  sl.registerLazySingleton<Refreshtoken>(
    () => Refreshtoken(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GoogleLogin>(
    () => GoogleLogin(sl<AuthRepository>()),
  );

  // Auth Bloc
  sl.registerFactory(
    () => AuthBloc(
      register: sl<Register>(),
      login: sl<Login>(),
      logout: sl<Logout>(),
      requestOtp: sl<RequestOtp>(),
      refreshToken: sl<Refreshtoken>(),
      googleLogin: sl<GoogleLogin>(),
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
      authLocalDataSource: sl<AuthLocalDataSource>(),
    ),
  );

  // CV Repository
  sl.registerLazySingleton<CvRepository>(
    () => CvRepositoryImpl(
      remoteDataSource: sl<CvRemoteDataSource>(),
      localDataSource: sl<ProfileLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // CV Usecases
  sl.registerLazySingleton<AnalyzeCv>(() => AnalyzeCv(sl<CvRepository>()));
  sl.registerLazySingleton<UploadCv>(() => UploadCv(sl<CvRepository>()));
  sl.registerLazySingleton<GetSuggestions>(
    () => GetSuggestions(sl<CvRepository>()),
  );

  // CV Bloc
  sl.registerFactory(
    () => CvBloc(
      uploadCv: sl<UploadCv>(),
      analyzeCv: sl<AnalyzeCv>(),
      getSuggestions: sl<GetSuggestions>(),
    ),
  );
  //cv chat
  sl.registerLazySingleton<CvChatRemoteDataSource>(
    () => CvChatRemoteDataSourceImpl(
      dio: sl<Dio>(),
      authLocalDataSource: sl<AuthLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<CvChatRepository>(
    () => CvChatRepositoryImpl(
      remoteDataSource: sl<CvChatRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  sl.registerLazySingleton<CreateChatSession>(
    () => CreateChatSession(sl<CvChatRepository>()),
  );

  sl.registerLazySingleton<SendChatMessage>(
    () => SendChatMessage(sl<CvChatRepository>()),
  );

  sl.registerLazySingleton<GetChatHistory>(
    () => GetChatHistory(sl<CvChatRepository>()),
  );

  sl.registerLazySingleton<GetAllChatSessions>(
    () => GetAllChatSessions(sl<CvChatRepository>()),
  );

  sl.registerFactory(
    () => CvChatBloc(
      createChatSession: sl<CreateChatSession>(),
      sendChatMessage: sl<SendChatMessage>(),
      getChatHistory: sl<GetChatHistory>(),
      getAllChatSessions: sl<GetAllChatSessions>(),
    ),
  );

  // === Interview Feature ===
   // === Interview Feature ===
  // Local Data Source
  sl.registerLazySingleton<InterviewLocalDataSource>(
    () => InterviewLocalDataSourceImpl(sl<SharedPreferences>()),
  );

  // Remote Data Source
  sl.registerLazySingleton<InterviewRemoteDataSource>(
    () => InterviewRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Repository
  sl.registerLazySingleton<InterviewRepository>(
    () => InterviewRepositoryImpl(
      localDataSource: sl<InterviewLocalDataSource>(),
      remoteDataSource: sl<InterviewRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Usecases
  sl.registerLazySingleton<StartFreeformSession>(
    () => StartFreeformSession(sl<InterviewRepository>()),
  );
  sl.registerLazySingleton<StartStructuredSession>(
    () => StartStructuredSession(sl<InterviewRepository>()),
  );
  sl.registerLazySingleton<SendFreeformMessage>(
    () => SendFreeformMessage(sl<InterviewRepository>()),
  );
  sl.registerLazySingleton<SendStructuredAnswer>(
    () => SendStructuredAnswer(sl<InterviewRepository>()),
  );
  sl.registerLazySingleton<GetFreeformHistory>(
    () => GetFreeformHistory(sl<InterviewRepository>()),
  );
  sl.registerLazySingleton<GetStructuredHistory>(
    () => GetStructuredHistory(sl<InterviewRepository>()),
  );
  sl.registerLazySingleton<GetUserFreeformChats>(
    () => GetUserFreeformChats(sl<InterviewRepository>()),
  );
  sl.registerLazySingleton<GetUserStructuredChats>(
    () => GetUserStructuredChats(sl<InterviewRepository>()),
  );
  sl.registerLazySingleton<ContinueStructuredSession>(
    () => ContinueStructuredSession(sl<InterviewRepository>()),
  );

  // Bloc
  sl.registerFactory(
    () => InterviewBloc(
      startFreeformSession: sl<StartFreeformSession>(),
      startStructuredSession: sl<StartStructuredSession>(),
      sendFreeformMessage: sl<SendFreeformMessage>(),
      sendStructuredAnswer: sl<SendStructuredAnswer>(),
      getFreeformHistory: sl<GetFreeformHistory>(),
      getStructuredHistory: sl<GetStructuredHistory>(),
      getUserFreeformChats: sl<GetUserFreeformChats>(),
      getUserStructuredChats: sl<GetUserStructuredChats>(),
      continueStructuredSession: sl<ContinueStructuredSession>(),
    ),
  );

  

  // === Job Search Feature ===
  // ... (previous registrations remain)

sl.registerLazySingleton<JobChatRemoteDataSource>(
  () => JobChatRemoteDataSourceImpl(
    dio: sl<Dio>(),
    authLocalDataSource: sl<AuthLocalDataSource>(),
  ),
);

sl.registerLazySingleton<JobChatRepository>(
  () => JobChatRepositoryImpl(
    remoteDataSource: sl<JobChatRemoteDataSource>(),
    networkInfo: sl<NetworkInfo>(),
  ),
);

sl.registerLazySingleton<GetAllChats>(() => GetAllChats(sl<JobChatRepository>()));
sl.registerLazySingleton<GetChatById>(() => GetChatById(sl<JobChatRepository>()));
sl.registerLazySingleton<SendJobChatMessage>(() => SendJobChatMessage(sl<JobChatRepository>()));

sl.registerFactory(
  () => JobChatBloc(
    getAllChats: sl<GetAllChats>(),
    getChatById: sl<GetChatById>(),
    // sendChatMessage: sl<SendChatMessage>(),
    sendChatMessage: sl<SendJobChatMessage>(),
  ),
);
}
