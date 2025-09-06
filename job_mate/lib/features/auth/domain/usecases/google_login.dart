import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/auth/domain/entities/user.dart';
import 'package:job_mate/features/auth/domain/repositories/auth_repository.dart';

class GoogleLogin {
  final AuthRepository repository;

  GoogleLogin(this.repository);

  Future<Either<Failure, User>> call() async {
    return await repository.googleLogin();
  }
}