import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/interview/domain/entities/interview_message.dart';
import 'package:job_mate/features/interview/domain/repositories/interview_repository.dart';

class SendFreeformMessage {
  final InterviewRepository repository;
  SendFreeformMessage(this.repository);

  Future<Either<Failure, InterviewMessage>> call(String chatId, String message) {
    return repository.sendFreeformMessage(chatId, message);
  }
}


