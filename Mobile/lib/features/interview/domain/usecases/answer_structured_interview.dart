import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/interview/domain/entities/interview_message.dart';
import 'package:job_mate/features/interview/domain/repositories/interview_repository.dart';

class AnswerStructuredInterview {
  final InterviewRepository repository;
  AnswerStructuredInterview(this.repository);

  Future<Either<Failure, InterviewMessage>> call(String chatId, String answer) {
    return repository.answerStructuredInterview(chatId, answer);
  }
}


