import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/auth/domain/entities/user.dart';
import 'package:job_mate/features/auth/domain/repositories/auth_repository.dart';

class Register {
  final AuthRepository repository;

  Register(this.repository);

  Future<Either<Failure,User>> call( String email, String password, String otp)async{
    return await repository.register(email, password, otp);
  }
}