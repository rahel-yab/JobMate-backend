import 'package:job_mate/features/cv/domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    super.id,
    required super.role,
    required super.content,
    required DateTime timestamp,
  }) : super(
          timeStamp: timestamp,
        );

  // factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
  //   return ChatMessageModel(
  //     id: json['id'],
  //     role: json['role'],
  //     content: json['content'],
  //     timestamp: DateTime.parse(json['timestamp']),
  //   );
  // }
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
  return ChatMessageModel(
    id: json['id'] ?? '',
    role: json['role'] ?? 'assistant',
    content: json['content'] ?? '',
     timestamp: json['timestamp'] != null 
        ? DateTime.parse(json['timestamp'])
        : DateTime.now(), // or parse from json if provided
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'timestamp': timeStamp.toIso8601String(),
    };
  }
}