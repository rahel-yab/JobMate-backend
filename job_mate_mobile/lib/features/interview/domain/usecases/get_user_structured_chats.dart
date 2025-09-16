import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/interview/domain/entities/interview_session.dart';
import 'package:job_mate/features/interview/domain/repositories/interview_repository.dart';

class GetUserStructuredChats {
  final InterviewRepository repository;
  GetUserStructuredChats(this.repository);

  Future<Either<Failure, List<InterviewSession>>> call() {
    return repository.getUserStructuredChats();
  }
}


