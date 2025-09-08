import 'package:bloc/bloc.dart';
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
          emit(JobChatEmpty());
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
      (response) {
        // Handle the raw response containing both message and jobs
        final currentState = state;
        if (currentState is JobChatLoaded) {
          emit(JobChatResponseReceived(currentState.chats, response));
        } else {
          emit(JobChatResponseReceived([], response));
        }
      },
    );
  }

  void _onClearChats(ClearChatsEvent event, Emitter<JobChatState> emit) {
    emit(JobChatEmpty());
  }
}