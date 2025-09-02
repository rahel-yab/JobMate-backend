import 'package:job_mate/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required String userId,
    required String email,
    String? firstName,
    String? lastName,
    required String provider,
  }) : super(
         userId: userId,
         email: email,
         firstName: firstName,
         lastName: lastName,
         provider: provider,
       );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle nested user object from login response
    if (json.containsKey('user') && json['user'] is Map<String, dynamic>) {
      final userJson = json['user'] as Map<String, dynamic>;
      return UserModel(
        userId: userJson['user_id'] as String,
        email: userJson['email'] as String,
        firstName: userJson['firstName'] as String?,
        lastName: userJson['lastName'] as String?,
        provider: userJson['provider'] ?? '',
      );
    }
    
    // Handle direct user JSON (for registration response)
    return UserModel(
      userId: json['user_id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      provider: json['provider'] ?? '',
    );
  }

  /// Convert UserModel to JSON 
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'provider': provider,
    };
  }

  /// Create UserModel from domain entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      userId: user.userId,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      provider: user.provider,
    );
  }
}
