import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/interview/domain/entities/interview_message.dart';
import 'package:job_mate/features/interview/domain/repositories/interview_repository.dart';

class GetFreeformHistory {
  final InterviewRepository repository;
  GetFreeformHistory(this.repository);

  Future<Either<Failure, List<InterviewMessage>>> call(String chatId) {
    return repository.getFreeformHistory(chatId);
  }
}


