import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/interview/domain/entities/interview_session.dart';
import 'package:job_mate/features/interview/domain/repositories/interview_repository.dart';

class StartFreeformSession {
  final InterviewRepository repository;
  StartFreeformSession(this.repository);

  Future<Either<Failure, InterviewSession>> call(String sessionType) {
    return repository.startFreeformSession(sessionType);
  }
}


