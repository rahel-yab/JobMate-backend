import 'package:job_mate/features/interview/domain/entities/interview_message.dart';

class InterviewMessageModel extends InterviewMessage {
  const InterviewMessageModel({
    required super.chatId,
    required super.sender,
    required super.content,
    required super.timestamp,
    super.id,
  });

  factory InterviewMessageModel.fromJson(Map<String, dynamic> json, String chatId) {
    final role = (json['role'] as String?)?.toLowerCase();
    final sender = role == 'assistant' ? InterviewSender.assistant : InterviewSender.user;
    return InterviewMessageModel(
      chatId: chatId,
      sender: sender,
      content: json['message'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      id: json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat_id': chatId,
      'message': content,
      'role': sender == InterviewSender.assistant ? 'assistant' : 'user',
      'timestamp': timestamp.toIso8601String(),
      if (id != null) 'id': id,
    };
  }
}


