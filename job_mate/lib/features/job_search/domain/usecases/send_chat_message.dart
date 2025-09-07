import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/job_search/domain/entities/chat.dart';
import 'package:job_mate/features/job_search/domain/repositories/job_chat_repository.dart';

class SendJobChatMessage {
  final JobChatRepository repository;

  SendJobChatMessage(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String message, {String? chatId}) {
    return repository.sendChatMessage(message, chatId: chatId);
  }
}
