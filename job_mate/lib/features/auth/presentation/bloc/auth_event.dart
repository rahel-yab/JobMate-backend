part of 'auth_bloc.dart';


abstract class AuthEvent {}

class RequestOtpEvent extends AuthEvent{
  final String email;
  RequestOtpEvent(this.email);
}
class RegisterEvent extends AuthEvent{
  final String email;
  final String password;
  final String otp;

  RegisterEvent(this.email,this.password,this.otp);
}
class LoginEvent extends AuthEvent{
  final String email;
  final String password;
  LoginEvent(this.email,this.password);
}
class LogoutEvent extends AuthEvent{}
class RefreshTokenEvent extends AuthEvent{}