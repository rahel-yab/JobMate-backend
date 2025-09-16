import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/cv/domain/entities/chat_session.dart';
import 'package:job_mate/features/cv/domain/repositories/cv_chat_repository.dart';



class GetChatHistory {
  final CvChatRepository repository;

  GetChatHistory(this.repository);

  Future<Either<Failure, ChatSession>> call(String chatId) async {
    return await repository.getChatHistory(chatId);
  }
}