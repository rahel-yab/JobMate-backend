import 'package:equatable/equatable.dart';
import 'package:job_mate/features/cv/domain/entities/chat_message.dart';

class ChatSession extends Equatable{
  final String chatId;
  final String userId;
  final String? cvId;
  final List<ChatMessage>? messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatSession({
    required this.chatId,
    required this.userId,
    this.cvId,
    this.messages,
    required this.createdAt,
    required this.updatedAt,
  });
  
  @override
  // TODO: implement props
  List<Object?> get props => [chatId,userId,cvId,messages,createdAt,updatedAt];
}