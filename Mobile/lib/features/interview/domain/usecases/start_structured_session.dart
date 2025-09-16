import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/interview/domain/entities/interview_session.dart';
import 'package:job_mate/features/interview/domain/repositories/interview_repository.dart';

class StartStructuredSession {
  final InterviewRepository repository;

  StartStructuredSession(this.repository);

  Future<Either<Failure, InterviewSession>> call(String field) async {
    return await repository.startStructuredInterview(field);
  }
}
