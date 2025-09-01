import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/auth/domain/entities/auth_token.dart';
import 'package:job_mate/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure,AuthToken>> refreshToken();
  Future<Either<Failure,User>> login(String email,String password);
  Future<Either<Failure,User>> register(String email, String password, String otp);
  Future<Either<Failure,void>> logout();
  Future<Either<Failure,void>> requestOtp(String email);
}