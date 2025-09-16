import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/interview/domain/entities/interview_message.dart';
import 'package:job_mate/features/interview/domain/repositories/interview_repository.dart';

class SendStructuredAnswer {
  final InterviewRepository repository;

  SendStructuredAnswer(this.repository);

  Future<Either<Failure, InterviewMessage>> call(
    String chatId,
    String answer,
  ) async {
    return await repository.answerStructuredInterview(chatId, answer);
  }
}
