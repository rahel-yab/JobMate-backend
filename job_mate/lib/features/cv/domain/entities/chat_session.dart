import 'package:equatable/equatable.dart';
import 'package:job_mate/features/cv/domain/entities/chat_message.dart';

// Update your ChatSession model
class ChatSession extends Equatable {
  final String chatId;
  final String userId;
  final String? cvId;
  final List<ChatMessage> messages; // Changed from nullable to non-nullable
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatSession({
    required this.chatId,
    required this.userId,
    this.cvId,
    required this.messages, // Now required
    required this.createdAt,
    required this.updatedAt,
  });
  
  @override
  List<Object?> get props => [chatId, userId, cvId, messages, createdAt, updatedAt];
}