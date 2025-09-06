import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/interview/domain/entities/interview_session.dart';
import 'package:job_mate/features/interview/domain/repositories/interview_repository.dart';

class GetUserFreeformChats {
  final InterviewRepository repository;
  GetUserFreeformChats(this.repository);

  Future<Either<Failure, List<InterviewSession>>> call() {
    return repository.getUserFreeformChats();
  }
}


