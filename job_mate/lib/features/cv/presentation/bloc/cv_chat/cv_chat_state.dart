import 'package:equatable/equatable.dart';
import 'package:job_mate/features/cv/domain/entities/chat_session.dart';
import 'package:job_mate/features/cv/domain/entities/chat_message.dart';

abstract class CvChatState extends Equatable {
  const CvChatState();
  @override
  List<Object?> get props => [];
}

class CvChatInitial extends CvChatState {}

class CvChatLoading extends CvChatState {}

class CvChatSessionCreated extends CvChatState {
  final String chatId;

  const CvChatSessionCreated(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class CvChatMessageSent extends CvChatState {
  final ChatMessage message;

  const CvChatMessageSent(this.message);

  @override
  List<Object?> get props => [message];
}

class CvChatHistoryLoaded extends CvChatState {
  final ChatSession history;

  const CvChatHistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}

class CvChatSessionsLoaded extends CvChatState {
  final List<ChatSession> sessions;

  const CvChatSessionsLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

class CvChatError extends CvChatState {
  final String message;

  const CvChatError(this.message);

  @override
  List<Object?> get props => [message];
}