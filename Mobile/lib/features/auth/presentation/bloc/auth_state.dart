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
  final String type; // Required named parameter with default value

  AuthSuccess(this.message, {this.data, this.type = 'default'});
}
final class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
// final class AuthChecked extends AuthState { // New state
//   final bool isAuthenticated;
//   final dynamic data; // Can hold user data or token if authenticated

//   AuthChecked(this.isAuthenticated, {this.data});
// }