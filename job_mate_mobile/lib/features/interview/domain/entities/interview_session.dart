import 'package:equatable/equatable.dart';

class InterviewSession extends Equatable {
  final String chatId;
  final String userId;
  final String mode; // "freeform" or "structured"
  final String? field; // only for structured interviews
  final String? sessionType; // "general", "technical", etc.
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? totalQuestions; // for structured interviews
  final int? currentQuestion; // for structured interviews
  final bool? isCompleted; // for structured interviews

  const InterviewSession({
    required this.chatId,
    required this.userId,
    required this.mode,
    this.field,
    this.sessionType,
    required this.createdAt,
    required this.updatedAt,
    this.totalQuestions,
    this.currentQuestion,
    this.isCompleted,
  });

  @override
  List<Object?> get props => [
    chatId,
    userId,
    mode,
    field,
    sessionType,
    createdAt,
    updatedAt,
    totalQuestions,
    currentQuestion,
    isCompleted,
  ];
}
