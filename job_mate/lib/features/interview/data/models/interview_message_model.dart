import 'package:job_mate/features/interview/domain/entities/interview_message.dart';

class InterviewMessageModel extends InterviewMessage {
  const InterviewMessageModel({
    super.id,
    required super.chatId,
    required super.role,
    required super.content,
    required DateTime timestamp,
    super.questionIndex,
  }) : super(timestamp: timestamp);

  factory InterviewMessageModel.fromJson(Map<String, dynamic> json) {
    return InterviewMessageModel(
      id: json['id']?.toString(),
      chatId: json['chat_id'] ?? '',
      role: json['role'] ?? 'assistant',
      content: json['content'] ?? '',
      timestamp:
          json['timestamp'] != null
              ? DateTime.parse(json['timestamp'])
              : DateTime.now(),
      questionIndex: json['question_index'],
    );
  }

  // For structured interview responses
  factory InterviewMessageModel.fromStructuredResponse(
    Map<String, dynamic> json,
  ) {
    return InterviewMessageModel(
      id: json['id']?.toString(),
      chatId: json['chat_id'] ?? '',
      role: 'assistant',
      content:
          json['next_question'] ?? json['question'] ?? json['content'] ?? '',
      timestamp: DateTime.now(),
      questionIndex: json['current_question'] ?? json['question_index'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      if (questionIndex != null) 'question_index': questionIndex,
    };
  }
}
