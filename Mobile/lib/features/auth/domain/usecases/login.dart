import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/auth/domain/entities/user.dart';
import 'package:job_mate/features/auth/domain/repositories/auth_repository.dart';

class Login {
  final AuthRepository repository;
  Login(this.repository);

  Future<Either<Failure,User>> call(String email,String password) async{
    return await repository.login(email, password);
  }
}