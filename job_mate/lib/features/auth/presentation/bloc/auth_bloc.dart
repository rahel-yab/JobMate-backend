import 'package:bloc/bloc.dart';
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
  AuthBloc(
    {
    required this.register, 
    required this.login, 
    required this.logout, 
    required this.requestOtp, 
    required this.refreshToken}) : super(AuthInitial()) {
    // on<AuthEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
    on<RequestOtpEvent>(_onRequestOtp);
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<RefreshTokenEvent>(_onRefreshToken);
  }
  void _onRequestOtp(RequestOtpEvent event, Emitter<AuthState> emit) async{
    emit(AuthLoading('Requesting an OTP'));
    final result= await requestOtp(event.email);
    result.fold(
      (failue)=>emit(AuthError(failue.toString())), 
      (_)=> emit(AuthSuccess('Otp sent to your email')));
  }
  void _onRegister(RegisterEvent event,Emitter<AuthState> emit) async{
    emit(AuthLoading('Registring'));
    final result= await register(event.email,event.otp,event.password);
    result.fold(
      (failure)=> emit(AuthError(failure.toString())), 
      (user)=>emit(AuthSuccess('User registered successfully',user)));
  }
  void _onLogin(LoginEvent event,Emitter<AuthState> emit) async{
    emit(AuthLoading('Logging in'));
    final result= await login(event.email,event.password);
    result.fold(
      (failure)=> emit(AuthError(failure.toString())), 
      (user)=>emit(AuthSuccess('User logged in successfully',user)));
  }
  void _onLogout(LogoutEvent event,Emitter<AuthState> emit) async{
    emit(AuthLoading('Logging out'));
    final result= await logout();
    result.fold(
      (failure)=> emit(AuthError(failure.toString())), 
      (_)=>emit(AuthSuccess('User logged out successfully')));

  }
  void _onRefreshToken(RefreshTokenEvent event,Emitter<AuthState> emit) async{
    emit(AuthLoading('Refreshing your token'));
    final result= await refreshToken();
    result.fold(
      (failure)=> emit(AuthError(failure.toString())), 
      (token)=>emit(AuthSuccess('Token refreshed successfully',token)));
  }
}
