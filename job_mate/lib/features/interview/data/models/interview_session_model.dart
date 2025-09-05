import 'package:job_mate/features/interview/domain/entities/interview_session.dart';

class InterviewSessionModel extends InterviewSession {
  const InterviewSessionModel({
    required super.chatId,
    required super.mode,
    super.field,
    required super.createdAt,
  });

  /// Factory for freeform session responses
  factory InterviewSessionModel.fromFreeformJson(Map<String, dynamic> json) {
    return InterviewSessionModel(
      chatId: json['chat_id'] as String,
      mode: 'freeform',
      field: null,
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'] as String) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  /// Factory for structured session responses
  factory InterviewSessionModel.fromStructuredJson(Map<String, dynamic> json, {required String field}) {
    return InterviewSessionModel(
      chatId: json['chat_id'] as String,
      mode: 'structured',
      field: field,
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'] as String) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat_id': chatId,
      'mode': mode,
      if (field != null) 'field': field,
      'created_at': createdAt.toIso8601String(),
    };
  }
}


