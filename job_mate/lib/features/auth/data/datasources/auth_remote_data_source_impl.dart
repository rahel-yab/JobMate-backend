import 'package:dio/dio.dart';
import 'package:job_mate/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:job_mate/features/auth/data/models/auth_token_model.dart';
import 'package:job_mate/features/auth/data/models/user_model.dart';


class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      print('Received registration response: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        final user = UserModel.fromJson(userData); // Map to UserModel first
        final authToken = AuthTokenModel(
          accessToken: userData['acces_token'],
          expiresIn: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600, // Example: 1 hour expiry
        );
        return {
          'user': user,
          'authToken': authToken,
        };
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Login failed with status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          message: 'Invalid email or password',
        );
      }
      rethrow;
    }
  }

  @override
Future<UserModel> register(String email, String password, String otp) async {
  try {
    print('Sending registration request to ${dio.options.baseUrl}/auth/register with email: $email, password: $password, otp: $otp');
    final response = await dio.post(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'otp': otp,
      },
    );
    print('Received registration response: ${response.statusCode} - ${response.data}');

    if (response.statusCode == 201) {
      return UserModel.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Registration failed with status code: ${response.statusCode}',
      );
    }
  } on DioException catch (e) {
    print('DioException during registration: ${e.type} - ${e.message} - Status: ${e.response?.statusCode} - Data: ${e.response?.data}');
    if (e.response?.statusCode == 400) {
      throw DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        message: 'Invalid registration data or OTP',
      );
    }
    rethrow;
  }
}

  @override
  Future<void> logout() async {
    try {
      final response = await dio.post('/auth/logout');

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Logout failed with status code: ${response.statusCode}',
        );
      }
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> requestOtp(String email) async {
    try {
      print('Sending OTP request to ${dio.options.baseUrl}/auth/request-otp with email: $email');
      final response = await dio.post(
        '/auth/request-otp',
        data: {
          'email': email,
        },
      );
      print('Received response: ${response.statusCode} - ${response.data}');

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'OTP request failed with status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Handle specific error cases
      print('DioException: ${e.type} - ${e.message} - Status: ${e.response?.statusCode}');
      if (e.response?.statusCode == 400) {
        throw DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          message: 'Invalid email address',
        );
      }
      rethrow;
    }
  }

  @override
  Future<AuthTokenModel> refreshToken() async {
    try {
      final response = await dio.post('/auth/refresh');

      if (response.statusCode == 200) {
        return AuthTokenModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Token refresh failed with status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Handle specific error cases
      if (e.response?.statusCode == 401) {
        throw DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          message: 'Invalid or expired refresh token',
        );
      }
      rethrow;
    }
  }
  @override
  Future<Map<String, dynamic>> googleLogin() async {
    try {
      // The backend redirects to Google's OAuth page, so we initiate the request
      final response = await dio.get('/oauth/google/login');

      // Since the backend handles the callback, we expect the response from the callback endpoint
      // However, in practice, the browser handles the redirect, so this is more about initiating the flow
      // We'll handle the actual response in the UI via a redirect handler
      print('Google OAuth login response: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        final user = UserModel.fromJson(userData);
        final authToken = AuthTokenModel(
          accessToken: userData['auth_token'] ?? '', // Backend sets auth_token in cookies
          expiresIn: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600,
        );
        return {
          'user': user,
          'authToken': authToken,
        };
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Google OAuth login failed with status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('DioException during Google OAuth login: ${e.message}');
      throw DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        message: 'Google OAuth login failed: ${e.message}',
      );
    }
  }
}
