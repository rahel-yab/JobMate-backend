import 'package:equatable/equatable.dart';

enum InterviewSender { user, assistant }

class InterviewMessage extends Equatable {
  final String chatId;
  final InterviewSender sender;
  final String content;
  final DateTime timestamp;
  final String? id;

  const InterviewMessage({
    required this.chatId,
    required this.sender,
    required this.content,
    required this.timestamp,
    this.id,
  });

  @override
  List<Object?> get props => [chatId, sender, content, timestamp, id];
}


