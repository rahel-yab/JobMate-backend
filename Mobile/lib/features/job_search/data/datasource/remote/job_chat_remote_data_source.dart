
import 'package:job_mate/features/job_search/domain/entities/chat.dart';

// Update your JobChatRemoteDataSource interface
abstract class JobChatRemoteDataSource {
  Future<List<Chat>> getAllChats();
  Future<Chat> getChatById(String id);
  Future<Map<String, dynamic>> sendChatMessage(String message, {String? chatId}); // Changed return type
}