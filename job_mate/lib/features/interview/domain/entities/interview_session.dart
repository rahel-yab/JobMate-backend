import 'package:equatable/equatable.dart';

class InterviewSession extends Equatable {
  final String chatId;
  final String mode; // "freeform" or "structured"
  final String? field; // only for structured interviews
  final DateTime createdAt;

  const InterviewSession({
    required this.chatId,
    required this.mode,
    this.field,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [chatId, mode, field, createdAt];
}


