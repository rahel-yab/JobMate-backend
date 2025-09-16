import 'package:job_mate/features/cv/domain/entities/chat_message.dart';
import 'package:job_mate/features/cv/domain/entities/chat_session.dart';


abstract class CvChatRemoteDataSource {
  Future<String> createChatSession(String? cvId);
  Future<ChatMessage> sendChatMessage(String chatId, String message, String? cvId);
  Future<ChatSession> getChatHistory(String chatId);
  Future<List<ChatSession>> getAllChatSessions();

}