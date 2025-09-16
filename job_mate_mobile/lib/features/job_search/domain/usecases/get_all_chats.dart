import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/job_search/domain/entities/chat.dart';
import 'package:job_mate/features/job_search/domain/repositories/job_chat_repository.dart';

class GetAllChats {
  final JobChatRepository repository;

  GetAllChats(this.repository);

  Future<Either<Failure, List<Chat>>> call() {
    return repository.getAllChats();
  }
}