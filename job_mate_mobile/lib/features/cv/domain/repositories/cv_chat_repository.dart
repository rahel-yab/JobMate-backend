import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/cv/domain/entities/chat_message.dart';
import 'package:job_mate/features/cv/domain/entities/chat_session.dart';

abstract class CvChatRepository {
  Future<Either<Failure,String>> createChatSession(String? cvId);
  Future<Either<Failure,ChatMessage>> sendChatMessage(String chatId, String message, String? cvId);
  Future<Either<Failure,ChatSession>> getChatHistory(String cvId);
  Future<Either<Failure,List<ChatSession>>> getAllChatSessions();

}