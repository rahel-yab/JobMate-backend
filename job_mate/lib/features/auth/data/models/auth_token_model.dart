import 'package:job_mate/features/auth/domain/entities/auth_token.dart';

class AuthTokenModel extends AuthToken {
    const AuthTokenModel({required String accessToken, required int expiresIn})
    : super(accessToken: accessToken, expiresIn: expiresIn);
  /// Factory constructor to create AuthTokenModel from JSON
  /// Handles both login response (acces_token) and refresh response (access_token)
    factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    return AuthTokenModel(
      accessToken:
          json['acces_token'] as String? ?? json['access_token'] as String,
      expiresIn: json['expires_in'] as int,
    );
  }

  /// Convert AuthTokenModel to JSON
   Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'expires_in': expiresIn,
    };
  }

  /// Create AuthTokenModel from domain entity
   factory AuthTokenModel.fromEntity(AuthToken authToken) {
    return AuthTokenModel(
      accessToken: authToken.accessToken,
      expiresIn: authToken.expiresIn,
    );
  }
}
