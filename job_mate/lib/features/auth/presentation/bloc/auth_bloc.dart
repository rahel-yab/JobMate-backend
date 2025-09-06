// features/auth/presentation/bloc/auth_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:job_mate/features/auth/domain/usecases/google_login.dart';
import 'package:job_mate/features/auth/domain/usecases/login.dart';
import 'package:job_mate/features/auth/domain/usecases/logout.dart';
import 'package:job_mate/features/auth/domain/usecases/refresh_token.dart';
import 'package:job_mate/features/auth/domain/usecases/register.dart';
import 'package:job_mate/features/auth/domain/usecases/request_otp.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Register register;
  final Login login;
  final Logout logout;
  final RequestOtp requestOtp;
  final Refreshtoken refreshToken;
  final GoogleLogin googleLogin;
  

  AuthBloc({
    required this.register,
    required this.login,
    required this.logout,
    required this.requestOtp,
    required this.refreshToken,
    required this.googleLogin,
  }) : super(AuthInitial()) {
    on<RequestOtpEvent>(_onRequestOtp);
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<RefreshTokenEvent>(_onRefreshToken);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus); // New handler
    on<GoogleLoginEvent>(_onGoogleLogin);
  }

  void _onRequestOtp(RequestOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading('Requesting an OTP'));
    final result = await requestOtp(event.email);
    result.fold(
      (failure) => emit(AuthError(failure.toString())),
      (_) => emit(AuthSuccess('OTP sent to your email', type: 'otp')),
    );
  }

  void _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading('Registering'));
    print('Registering with email: ${event.email}, otp: ${event.otp}, password: ${event.password}');
    final result = await register(event.email, event.password, event.otp);
    print('Registration result: $result');
    result.fold(
      (failure) => emit(AuthError(failure.toString())),
      (user) => emit(AuthSuccess('User registered successfully', data: user, type: 'register')),
    );
  }

  void _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading('Logging in'));
    final result = await login(event.email, event.password);
    result.fold(
      (failure) => emit(AuthError(failure.toString())),
      (user) => emit(AuthSuccess('User logged in successfully', data: user, type: 'login')),
    );
  }

  void _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading('Logging out'));
    final result = await logout();
    result.fold(
      (failure) => emit(AuthError(failure.toString())),
      (_) => emit(AuthSuccess('User logged out successfully', type: 'logout')),
    );
  }

  void _onRefreshToken(RefreshTokenEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading('Refreshing your token'));
    final result = await refreshToken();
    result.fold(
      (failure) => emit(AuthError(failure.toString())),
      (token) => emit(AuthSuccess('Token refreshed successfully', data: token, type: 'refresh')),
    );
  }

  void _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading('Checking authentication status'));
    final result = await refreshToken(); // Assuming refreshToken checks validity and returns user data
    result.fold(
      (failure) => emit(AuthChecked(false)), // Not authenticated
      (data) => emit(AuthChecked(true, data: data)), // Authenticated with data
    );
  }
 void _onGoogleLogin(GoogleLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading('Initiating Google OAuth login'));
    final result = await googleLogin(); // Use googleLogin instead of login.googleLogin()
    result.fold(
      (failure) => emit(AuthError(failure.toString())),
      (user) => emit(AuthSuccess('Google login successful', data: user, type: 'google_login')),
    );
  }
}