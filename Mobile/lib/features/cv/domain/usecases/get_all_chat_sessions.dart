import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/cv/domain/entities/chat_session.dart';
import 'package:job_mate/features/cv/domain/repositories/cv_chat_repository.dart';


class GetAllChatSessions {
  final CvChatRepository repository;

  GetAllChatSessions(this.repository);

  Future<Either<Failure, List<ChatSession>>> call() async {
    return await repository.getAllChatSessions();
  }
}