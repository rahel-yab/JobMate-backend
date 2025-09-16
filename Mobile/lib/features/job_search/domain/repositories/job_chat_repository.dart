import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';

import 'package:job_mate/features/job_search/domain/entities/chat.dart';


abstract class JobChatRepository {
  Future<Either<Failure, List<Chat>>> getAllChats();
  Future<Either<Failure, Chat>> getChatById(String id);
  // Future<Either<Failure, Chat>> sendChatMessage(String message, {String? chatId});
  Future<Either<Failure, Map<String, dynamic>>> sendChatMessage(String message, {String? chatId});
}