import 'package:job_mate/features/auth/data/models/auth_token_model.dart';
import 'package:job_mate/features/auth/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheAuthToken(AuthTokenModel authToken);
  Future<AuthTokenModel?> getCachedAuthToken();
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearAuthData();
  Future<bool> isUserLoggedIn();
  Future<bool> isTokenExpired();
  Future<String?> getAccessToken();
}