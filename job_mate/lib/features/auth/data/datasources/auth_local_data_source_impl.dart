import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_mate/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:job_mate/features/auth/data/models/auth_token_model.dart';
import 'package:job_mate/features/auth/data/models/user_model.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  // Keys for SharedPreferences storage
  static const String _authTokenKey = 'auth_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  @override
  Future<void> cacheAuthToken(AuthTokenModel authToken) async {
    // Store the access token and expiry time
    await sharedPreferences.setString(_authTokenKey, authToken.accessToken);
    await sharedPreferences.setInt(_tokenExpiryKey, authToken.expiresIn);
    await sharedPreferences.setBool(_isLoggedInKey, true);
  }

  @override
  Future<AuthTokenModel?> getCachedAuthToken() async {
    final token = sharedPreferences.getString(_authTokenKey);
    final expiry = sharedPreferences.getInt(_tokenExpiryKey);

    if (token != null && expiry != null) {
      return AuthTokenModel(
        accessToken: token,
        expiresIn: expiry,
      );
    }
    return null;
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    // Convert user model to JSON string and store
    final userJson = user.toJson();
    final userJsonString = jsonEncode(userJson);
    await sharedPreferences.setString(_userKey, userJsonString);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final userString = sharedPreferences.getString(_userKey);
    if (userString != null && userString.isNotEmpty) {
      try {
        // Parse JSON string back to Map
        final userJson = jsonDecode(userString) as Map<String, dynamic>;
        // Create UserModel from parsed JSON
        return UserModel.fromJson(userJson);
      } catch (e) {
        // If parsing fails, clear the corrupted data and return null
        await sharedPreferences.remove(_userKey);
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> clearAuthData() async {
    // Remove all authentication-related data
    await sharedPreferences.remove(_authTokenKey);
    await sharedPreferences.remove(_tokenExpiryKey);
    await sharedPreferences.remove(_userKey);
    await sharedPreferences.setBool(_isLoggedInKey, false);
  }

  @override
  Future<bool> isUserLoggedIn() async {
    final isLoggedIn = sharedPreferences.getBool(_isLoggedInKey) ?? false;
    final token = sharedPreferences.getString(_authTokenKey);
    
    // Check if user is marked as logged in and has a valid token
    return isLoggedIn && token != null;
  }

  @override
  Future<bool> isTokenExpired() async {
    final token = await getCachedAuthToken();
    if (token == null) return true;

    // Get the current timestamp
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return currentTime >= token.expiresIn;
  }

  @override
  Future<String?> getAccessToken() async {
    return sharedPreferences.getString(_authTokenKey);
  }
}
