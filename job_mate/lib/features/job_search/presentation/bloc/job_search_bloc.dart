import 'package:bloc/bloc.dart';
import 'package:job_mate/features/job_search/data/models/job_model.dart';
import 'package:job_mate/features/job_search/domain/entities/chat.dart';
import 'package:job_mate/features/job_search/domain/entities/job_chat_message.dart';
import 'package:job_mate/features/job_search/domain/usecases/get_all_chats.dart';
import 'package:job_mate/features/job_search/domain/usecases/get_chat_by_id.dart';
import 'package:job_mate/features/job_search/domain/usecases/send_chat_message.dart';
import 'package:job_mate/features/job_search/presentation/bloc/job_search_event.dart';
import 'package:job_mate/features/job_search/presentation/bloc/job_search_state.dart';

class JobChatBloc extends Bloc<JobChatEvent, JobChatState> {
  final GetAllChats getAllChats;
  final GetChatById getChatById;
  final SendJobChatMessage sendChatMessage;

  JobChatBloc({
    required this.getAllChats,
    required this.getChatById,
    required this.sendChatMessage,
  }) : super(JobChatInitial()) {
    on<GetAllChatsEvent>(_onGetAllChats);
    on<GetChatByIdEvent>(_onGetChatById);
    on<SendChatMessageEvent>(_onSendChatMessage);
    on<ClearChatsEvent>(_onClearChats);
  }

  void _onGetAllChats(GetAllChatsEvent event, Emitter<JobChatState> emit) async {
  emit(JobChatLoading());
  final result = await getAllChats();
  result.fold(
    (failure) => emit(JobChatError(failure.message)),
    (chats) {
      if (chats.isEmpty) {
        emit(JobChatEmpty()); // Add a new state for empty chats
      } else {
        emit(JobChatLoaded(chats));
      }
    },
  );
}

  void _onGetChatById(GetChatByIdEvent event, Emitter<JobChatState> emit) async {
    emit(JobChatLoading());
    final result = await getChatById(event.id);
    result.fold(
      (failure) => emit(JobChatError(failure.message)),
      (chat) {
        final currentState = state as JobChatLoaded;
        emit(JobChatLoaded(currentState.chats, chat));
      },
    );
  }

  void _onSendChatMessage(SendChatMessageEvent event, Emitter<JobChatState> emit) async {
  emit(JobChatLoading());

  final result = await sendChatMessage(event.message, chatId: event.chatId);

  result.fold(
    (failure) => emit(JobChatError(failure.message)),
    (data) {
      // data is Map<String, dynamic> from remote impl
      final aiMessage = JobChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: "assistant",
        content: data['message'],
        timeStamp: DateTime.now(),
      );

      final jobs = (data['jobs'] as List<dynamic>?)
              ?.map((j) => JobModel.fromJson(j))
              .toList() ??
          [];

      final chatId = data['chat_id'] as String;

      // Append AI message to the existing chat if present
      if (state is JobChatLoaded) {
        final currentState = state as JobChatLoaded;
        final updatedChat = Chat(
          id: chatId,
          userId: "current_user", // replace with real userId if available
          messages: [...currentState.selectedChat?.messages ?? [], aiMessage],
          jobSearchQuery: {},
          jobResults: jobs,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        emit(JobChatLoaded(currentState.chats, updatedChat));
      } else {
        // If no previous chat state, create new
        final newChat = Chat(
          id: chatId,
          userId: "current_user",
          messages: [aiMessage],
          jobSearchQuery: {},
          jobResults: jobs,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        emit(JobChatLoaded([], newChat));
      }
    },
  );
}


void _onClearChats(ClearChatsEvent event, Emitter<JobChatState> emit) {
  emit(JobChatEmpty());
}
}