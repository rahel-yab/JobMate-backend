import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/auth/domain/repositories/auth_repository.dart';

class RequestOtp {
  final AuthRepository repository;

  RequestOtp(this.repository);

  Future<Either<Failure,void>> call(String email) async{
    return await repository.requestOtp(email);
  }
}