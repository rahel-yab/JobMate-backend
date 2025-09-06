import 'package:job_mate/features/auth/data/models/auth_token_model.dart';
import 'package:job_mate/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {

  Future<Map<String, dynamic>> login(String email, String password);
  Future<UserModel> register(String email, String password, String otp);

  Future<void> logout();
  Future<void> requestOtp(String email);
  Future<AuthTokenModel> refreshToken();
  Future<Map<String, dynamic>> googleLogin();
}