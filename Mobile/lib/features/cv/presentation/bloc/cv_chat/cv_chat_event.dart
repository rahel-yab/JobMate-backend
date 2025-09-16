import 'package:equatable/equatable.dart';

abstract class CvChatEvent extends Equatable {
  const CvChatEvent();
  @override
  List<Object?> get props => [];
}

class CreateCvChatSessionEvent extends CvChatEvent {
  final String? cvId;

  const CreateCvChatSessionEvent(this.cvId);

  @override
  List<Object?> get props => [cvId];
}

class SendCvChatMessageEvent extends CvChatEvent {
  final String chatId;
  final String message;
  final String? cvId;

  const SendCvChatMessageEvent({
    required this.chatId,
    required this.message,
    this.cvId,
  });

  @override
  List<Object?> get props => [chatId, message, cvId];
}

class GetCvChatHistoryEvent extends CvChatEvent {
  final String chatId;

  const GetCvChatHistoryEvent(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class GetAllCvChatSessionsEvent extends CvChatEvent {}