import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/cv/domain/repositories/cv_chat_repository.dart';



class CreateChatSession {
  final CvChatRepository repository;

  CreateChatSession(this.repository);

  Future<Either<Failure, String>> call(String? cvId) async {
    return await repository.createChatSession(cvId);
  }
}