
import 'package:job_mate/features/job_search/domain/entities/chat.dart';

abstract class JobChatRemoteDataSource {
  Future<List<Chat>> getAllChats();
  Future<Chat> getChatById(String id);
  // Future<Chat> sendChatMessage(String message, {String? chatId});
  Future<Map<String, dynamic>> sendChatMessage(String message, {String? chatId}) ;
}