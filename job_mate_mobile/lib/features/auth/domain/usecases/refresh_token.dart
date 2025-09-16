import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/auth/domain/entities/auth_token.dart';
import 'package:job_mate/features/auth/domain/repositories/auth_repository.dart';

class Refreshtoken {
  final AuthRepository repository;

  Refreshtoken(this.repository);

  Future<Either<Failure,AuthToken>> call() async{
    return await repository.refreshToken();
  }
  
}