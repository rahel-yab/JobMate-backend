import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/cv/domain/entities/chat_message.dart';
import 'package:job_mate/features/cv/domain/repositories/cv_chat_repository.dart';

class SendChatMessage {
  final CvChatRepository repository;

  SendChatMessage(this.repository);

  Future<Either<Failure, ChatMessage>> call(String chatId, String message, String? cvId) async {
    return await repository.sendChatMessage(chatId, message, cvId);
  }
}