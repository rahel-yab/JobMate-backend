import 'package:equatable/equatable.dart';

class InterviewMessage extends Equatable {
  final String? id;
  final String chatId;
  final String role; // "user" or "assistant"
  final String content;
  final DateTime timestamp;
  final int? questionIndex; // for structured interviews

  const InterviewMessage({
    this.id,
    required this.chatId,
    required this.role,
    required this.content,
    required this.timestamp,
    this.questionIndex,
  });

  @override
  List<Object?> get props => [
    id,
    chatId,
    role,
    content,
    timestamp,
    questionIndex,
  ];
}
