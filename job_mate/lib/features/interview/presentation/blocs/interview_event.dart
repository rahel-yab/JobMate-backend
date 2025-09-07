// import 'package:equatable/equatable.dart';

// abstract class InterviewEvent extends Equatable {
//   @override
//   List<Object?> get props => [];
// }

// class StartInterviewSession extends InterviewEvent {}

// class SendMessage extends InterviewEvent {
//   final String message;
//   SendMessage(this.message);

//   @override
//   List<Object?> get props => [message];
// }

// class LoadChatHistory extends InterviewEvent {
//   final String chatId;
//   LoadChatHistory(this.chatId);

//   @override
//   List<Object?> get props => [chatId];
// }

import 'package:equatable/equatable.dart';

abstract class InterviewEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StartInterviewSession extends InterviewEvent {}

class StartStructuredSession extends InterviewEvent {
  final String field;
  StartStructuredSession(this.field);

  @override
  List<Object?> get props => [field];
}

class SendMessage extends InterviewEvent {
  final String message;
  SendMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class AnswerStructuredQuestion extends InterviewEvent {
  final String answer;
  AnswerStructuredQuestion(this.answer);

  @override
  List<Object?> get props => [answer];
}

class LoadChatHistory extends InterviewEvent {
  final String chatId;
  LoadChatHistory(this.chatId);

  @override
  List<Object?> get props => [chatId];
}
