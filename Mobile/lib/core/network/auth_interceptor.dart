// import 'package:dio/dio.dart';
// import 'package:job_mate/features/auth/data/datasources/auth_local_data_source.dart';
// import 'package:job_mate/features/auth/data/models/auth_token_model.dart';
// import 'package:job_mate/features/auth/domain/repositories/auth_repository.dart';

// class AuthInterceptor extends Interceptor {
//   final AuthRepository authRepository;
//   final AuthLocalDataSource localDataSource;
//   final Dio dio; // Needed to retry failed request

//   AuthInterceptor({
//     required this.authRepository,
//     required this.localDataSource,
//     required this.dio,
//   });

//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
//     // Ensure valid token before request
//     final isExpired = await localDataSource.isTokenExpired();
//     if (isExpired) {
//       final result = await authRepository.refreshToken();
//       result.fold((_) {
//         // do nothing, will fail naturally
//       }, (newToken) async {
//         final accessToken = (newToken as AuthTokenModel).accessToken;
//         options.headers['Authorization'] = 'Bearer $accessToken';
//       });
//     } else {
//       final token = await localDataSource.getAccessToken();
//       if (token != null) {
//         options.headers['Authorization'] = 'Bearer $token';
//       }
//     }
//     super.onRequest(options, handler);
//   }

//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) async {
//     // If unauthorized, try refreshing and retrying
//     if (err.response?.statusCode == 401) {
//       final result = await authRepository.refreshToken();
//       return await result.fold(
//         (_) {
//           // Refresh failed -> forward error
//           handler.next(err);
//         },
//         (newToken) async {
//           final accessToken = (newToken as AuthTokenModel).accessToken;

//           final requestOptions = err.requestOptions;
//           requestOptions.headers['Authorization'] = 'Bearer $accessToken';

//           try {
//             final response = await dio.fetch(requestOptions);
//             return handler.resolve(response);
//           } catch (e) {
//             return handler.next(err);
//           }
//         },
//       );
//     }
//     super.onError(err, handler);
//   }
// }
// import 'package:dio/dio.dart';
// import 'package:job_mate/features/auth/data/datasources/auth_local_data_source.dart';

// class AuthInterceptor extends Interceptor {
//   final AuthLocalDataSource localDataSource;

//   AuthInterceptor({required this.localDataSource});

//   @override
//   void onRequest(
//     RequestOptions options,
//     RequestInterceptorHandler handler,
//   ) async {
//     print('AuthInterceptor: Processing request to ${options.path}');

//     // Skip auth for login, register, and refresh endpoints
//     if (options.path.contains('/auth/login') ||
//         options.path.contains('/auth/register') ||
//         options.path.contains('/auth/refresh') ||
//         options.path.contains('/auth/request-otp')) {
//       print('AuthInterceptor: Skipping auth for endpoint: ${options.path}');
//       return super.onRequest(options, handler);
//     }

//     final token = await localDataSource.getAccessToken();
//     print(
//       'AuthInterceptor: Retrieved token: ${token != null ? "EXISTS (${token.substring(0, 20)}...)" : "NULL"}',
//     );

//     if (token != null) {
//       options.headers['Authorization'] = 'Bearer $token';
//       print('AuthInterceptor: Added Authorization header');
//     } else {
//       print('AuthInterceptor: No token found, proceeding without auth header');
//     }

//     print('AuthInterceptor: Final headers: ${options.headers}');
//     super.onRequest(options, handler);
//   }

//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) async {
//     // Skip refresh for auth endpoints to prevent infinite loops
//     if (err.requestOptions.path.contains('/auth/login') ||
//         err.requestOptions.path.contains('/auth/register') ||
//         err.requestOptions.path.contains('/auth/refresh') ||
//         err.requestOptions.path.contains('/auth/request-otp')) {
//       return super.onError(err, handler);
//     }

//     // For 401 errors, just pass through - token refresh will be handled elsewhere
//  super.onError(err, handler);
//   }
// }
import 'package:dio/dio.dart';
import 'package:job_mate/features/auth/data/datasources/auth_local_data_source.dart';

class AuthInterceptor extends Interceptor {
  final AuthLocalDataSource localDataSource;

  AuthInterceptor({required this.localDataSource});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    print('AuthInterceptor: Processing request to ${options.path}');

    // Skip auth for login, register, and refresh endpoints
    if (options.path.contains('/auth/login') ||
        options.path.contains('/auth/register') ||
        options.path.contains('/auth/refresh') ||
        options.path.contains('/auth/request-otp')) {
      print('AuthInterceptor: Skipping auth for endpoint: ${options.path}');
      return super.onRequest(options, handler);
    }

    final token = await localDataSource.getAccessToken();
    print(
      'AuthInterceptor: Retrieved token: ${token != null ? "EXISTS (${token.substring(0, 20)}...)" : "NULL"}',
    );

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      print('AuthInterceptor: Added Authorization header');
    } else {
      print('AuthInterceptor: No token found, proceeding without auth header');
    }

    print('AuthInterceptor: Final headers: ${options.headers}');
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Skip refresh for auth endpoints to prevent infinite loops
    if (err.requestOptions.path.contains('/auth/login') ||
        err.requestOptions.path.contains('/auth/register') ||
        err.requestOptions.path.contains('/auth/refresh') ||
        err.requestOptions.path.contains('/auth/request-otp')) {
      return super.onError(err, handler);
    }

    // For 401 errors, just pass through - token refresh will be handled elsewhere
    super.onError(err, handler);
  }
}