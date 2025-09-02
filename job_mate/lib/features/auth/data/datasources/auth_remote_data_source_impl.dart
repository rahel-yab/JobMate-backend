import 'package:dio/dio.dart';
import 'package:job_mate/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:job_mate/features/auth/data/models/auth_token_model.dart';
import 'package:job_mate/features/auth/data/models/user_model.dart';


class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Login failed with status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Handle specific error cases
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
      final response = await dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'otp': otp,
        },
      );

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
      // Handle specific error cases
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
      final response = await dio.post(
        '/auth/request-otp',
        data: {
          'email': email,
        },
      );

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'OTP request failed with status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Handle specific error cases
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
}
