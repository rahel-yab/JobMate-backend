import 'package:equatable/equatable.dart';

abstract class InterviewEvent extends Equatable {
  const InterviewEvent();

  @override
  List<Object?> get props => [];
}

class StartFreeformSession extends InterviewEvent {
  final String sessionType;

  const StartFreeformSession(this.sessionType);

  @override
  List<Object?> get props => [sessionType];
}

class StartStructuredSession extends InterviewEvent {
  final String field;

  const StartStructuredSession(this.field);

  @override
  List<Object?> get props => [field];
}

class SendFreeformMessage extends InterviewEvent {
  final String message;

  const SendFreeformMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class SendStructuredAnswer extends InterviewEvent {
  final String answer;

  const SendStructuredAnswer(this.answer);

  @override
  List<Object?> get props => [answer];
}

class LoadChatHistory extends InterviewEvent {
  final String chatId;

  const LoadChatHistory(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class LoadUserChats extends InterviewEvent {
  const LoadUserChats();
}
