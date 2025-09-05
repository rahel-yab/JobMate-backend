import 'package:job_mate/features/cv/data/models/chat_message_model.dart';
import 'package:job_mate/features/cv/domain/entities/chat_session.dart';
import 'package:job_mate/features/cv/domain/entities/chat_message.dart';

class ChatSessionModel extends ChatSession {
  ChatSessionModel({
    required String chatId,
    required String userId,
    String? cvId,
    List<ChatMessage>? messages,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          chatId: chatId,
          userId: userId,
          cvId: cvId,
          messages: messages,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      chatId: json['chat_id'],
      userId: json['user_id'],
      cvId: json['cv_id'],
      messages: (json['messages'] as List?)?.map((e) => ChatMessageModel.fromJson(e)).toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat_id': chatId,
      'user_id': userId,
      'cv_id': cvId,
      'messages': messages?.map((e) => (e as ChatMessageModel).toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}