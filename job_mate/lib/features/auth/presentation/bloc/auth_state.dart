part of 'auth_bloc.dart';


abstract class AuthState {}

final class AuthInitial extends AuthState {}
final class AuthLoading extends AuthState {
  final String? message;
  AuthLoading([this.message]);
}
final class AuthSuccess extends AuthState {
  final String message;
  final dynamic data;
  AuthSuccess(this.message, [this.data]);
}
final class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
