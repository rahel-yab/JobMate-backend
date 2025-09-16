import 'package:job_mate/features/interview/data/models/interview_message_model.dart';
import 'package:job_mate/features/interview/domain/entities/interview_session.dart';
import 'package:job_mate/features/interview/domain/entities/interview_message.dart';

class InterviewSessionModel extends InterviewSession {
  const InterviewSessionModel({
    required String chatId,
    required String userId,
    required String mode,
    String? field,
    String? sessionType,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? totalQuestions,
    int? currentQuestion,
    bool? isCompleted,
  }) : super(
         chatId: chatId,
         userId: userId,
         mode: mode,
         field: field,
         sessionType: sessionType,
         createdAt: createdAt,
         updatedAt: updatedAt,
         totalQuestions: totalQuestions,
         currentQuestion: currentQuestion,
         isCompleted: isCompleted,
       );

  // For freeform session creation response
  factory InterviewSessionModel.fromFreeformJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return InterviewSessionModel(
      chatId: data['chat_id'] ?? '',
      userId: data['user_id'] ?? '',
      mode: 'freeform',
      sessionType: data['session_type'] ?? 'general',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // For structured session creation response
  factory InterviewSessionModel.fromStructuredJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return InterviewSessionModel(
      chatId: data['chat_id'] ?? '',
      userId: data['user_id'] ?? '',
      mode: 'structured',
      field: data['field'] ?? data['preferred_language'],
      totalQuestions: data['total_questions'] ?? 6,
      currentQuestion: data['current_question'] ?? 1,
      isCompleted: data['is_completed'] ?? false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Extract first question from structured start response if present
  static InterviewMessageModel? extractFirstQuestion(
    Map<String, dynamic> json,
  ) {
    final data = json['data'] ?? json;
    print('DEBUG: Checking for first question in response data: $data');

    // Try multiple possible field names for the question
    final question =
        data['question'] ??
        data['current_question_text'] ??
        data['current_question'] ??
        data['first_question'] ??
        data['message'] ??
        data['content'];

    print('DEBUG: Extracted question value: $question');

    if (question != null && question.toString().isNotEmpty) {
      final messageModel = InterviewMessageModel(
        id: '1',
        role: 'assistant',
        content: question.toString(),
        timestamp: DateTime.now(),
        chatId: data['chat_id'] ?? '',
      );
      print('DEBUG: Created first question message: ${messageModel.content}');
      return messageModel;
    }

    print('DEBUG: No first question found in any expected fields');
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'chat_id': chatId,
      'user_id': userId,
      'mode': mode,
      'field': field,
      'session_type': sessionType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'total_questions': totalQuestions,
      'current_question': currentQuestion,
      'is_completed': isCompleted,
    };
  }
}
