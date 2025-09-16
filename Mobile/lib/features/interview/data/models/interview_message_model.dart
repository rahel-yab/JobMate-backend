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
    // Support both wrapped and flat payloads
    final data = json['data'] ?? json;
    return InterviewMessageModel(
      id: json['id']?.toString(),
      chatId: data['chat_id'] ?? json['chat_id'] ?? '',
      role: data['role'] ?? json['role'] ?? 'assistant',
      content: data['content'] ?? json['content'] ?? '',
      timestamp:
          (data['timestamp'] ?? json['timestamp']) != null
              ? DateTime.parse((data['timestamp'] ?? json['timestamp']))
              : DateTime.now(),
      questionIndex: data['question_index'] ?? json['question_index'],
    );
  }

  // For structured interview responses
  factory InterviewMessageModel.fromStructuredResponse(
    Map<String, dynamic> json,
  ) {
    final String? feedback = json['feedback'] as String?;
    final String? nextQuestion = json['next_question'] as String?;
    final String? question = json['question'] as String?;
    final int? current = json['current_question'] as int?;
    final int? total = json['total_questions'] as int?;

    // Build a friendly content string that always has something to display
    String builtContent = '';
    if (feedback != null && feedback.trim().isNotEmpty) {
      builtContent = feedback.trim();
      if ((nextQuestion ?? question)?.trim().isNotEmpty == true) {
        final qText = (nextQuestion ?? question)!.trim();
        final counter = (current != null && total != null)
            ? ' (${current}/${total})'
            : '';
        builtContent =
            '$builtContent\n\nNext Question$counter:\n$qText';
      }
    } else {
      builtContent =
          (nextQuestion ?? question ?? json['content'] ?? '').toString();
    }

    return InterviewMessageModel(
      id: json['id']?.toString(),
      chatId: json['chat_id'] ?? '',
      role: 'assistant',
      content: builtContent,
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
