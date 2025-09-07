import 'package:equatable/equatable.dart';

abstract class JobChatEvent extends Equatable {
  const JobChatEvent();
  @override
  List<Object?> get props => [];
}

class GetAllChatsEvent extends JobChatEvent {}

class GetChatByIdEvent extends JobChatEvent {
  final String id;
  const GetChatByIdEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class SendChatMessageEvent extends JobChatEvent {
  final String message;
  final String? chatId;
  const SendChatMessageEvent({required this.message, this.chatId});
  @override
  List<Object?> get props => [message, chatId];
}
// Add this to your job_search_event.dart file
class ClearChatsEvent extends JobChatEvent {}