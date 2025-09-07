import 'package:job_mate/features/job_search/domain/entities/chat.dart';

abstract class JobChatState {}

class JobChatInitial extends JobChatState {}

class JobChatLoading extends JobChatState {}

class JobChatLoaded extends JobChatState {
  final List<Chat> chats;
  final Chat? selectedChat;
  JobChatLoaded(this.chats, [this.selectedChat]);
}

class JobChatError extends JobChatState {
  final String message;
  JobChatError(this.message);
}
class JobChatEmpty extends JobChatState {}