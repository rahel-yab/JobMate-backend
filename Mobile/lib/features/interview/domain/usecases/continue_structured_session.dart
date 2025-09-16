import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/interview/domain/entities/interview_message.dart';
import 'package:job_mate/features/interview/domain/repositories/interview_repository.dart';

class ContinueStructuredSession {
  final InterviewRepository repository;

  ContinueStructuredSession(this.repository);

  Future<Either<Failure, InterviewMessage>> call(String chatId) async {
    return await repository.continueStructuredInterview(chatId);
  }
}
