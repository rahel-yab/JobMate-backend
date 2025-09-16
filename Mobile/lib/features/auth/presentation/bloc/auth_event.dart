part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class RequestOtpEvent extends AuthEvent {
  final String email;
  
  const RequestOtpEvent(this.email);

  @override
  List<Object> get props => [email];
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String otp;

  const RegisterEvent(this.email, this.password, this.otp);

  @override
  List<Object> get props => [email, password, otp];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  
  const LoginEvent(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class LogoutEvent extends AuthEvent {}

class RefreshTokenEvent extends AuthEvent {}

// class CheckAuthStatusEvent extends AuthEvent {}

class GoogleLoginEvent extends AuthEvent {
  final String token; // Add token parameter
  
  const GoogleLoginEvent({required this.token});

  @override
  List<Object> get props => [token];
}

// // NEW: Add an event for initiating the OAuth flow
// class InitiateGoogleOAuthEvent extends AuthEvent {
//   final String redirectUrl;
  
//   const InitiateGoogleOAuthEvent({required this.redirectUrl});

//   @override
//   List<Object> get props => [redirectUrl];
// }

// // NEW: Add an event for handling the OAuth callback
// class HandleOAuthCallbackEvent extends AuthEvent {
//   final String callbackUrl;
  
//   const HandleOAuthCallbackEvent({required this.callbackUrl});

//   @override
//   List<Object> get props => [callbackUrl];
// }