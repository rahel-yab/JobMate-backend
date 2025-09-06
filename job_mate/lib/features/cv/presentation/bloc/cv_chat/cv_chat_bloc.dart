import 'package:bloc/bloc.dart';
import 'package:job_mate/features/cv/domain/usecases/create_chat_session.dart';
import 'package:job_mate/features/cv/domain/usecases/send_chat_message.dart';
import 'package:job_mate/features/cv/domain/usecases/get_chat_history.dart';
import 'package:job_mate/features/cv/domain/usecases/get_all_chat_sessions.dart';
import 'package:job_mate/features/cv/presentation/bloc/cv_chat/cv_chat_event.dart';
import 'package:job_mate/features/cv/presentation/bloc/cv_chat/cv_chat_state.dart';



class CvChatBloc extends Bloc<CvChatEvent, CvChatState> {
  final CreateChatSession createChatSession;
  final SendChatMessage sendChatMessage;
  final GetChatHistory getChatHistory;
  final GetAllChatSessions getAllChatSessions;

  CvChatBloc({
    required this.createChatSession,
    required this.sendChatMessage,
    required this.getChatHistory,
    required this.getAllChatSessions,
  }) : super(CvChatInitial()) {
    on<CreateCvChatSessionEvent>(_onCreateChatSession);
    on<SendCvChatMessageEvent>(_onSendChatMessage);
    on<GetCvChatHistoryEvent>(_onGetChatHistory);
    on<GetAllCvChatSessionsEvent>(_onGetAllChatSessions);
  }

  void _onCreateChatSession(CreateCvChatSessionEvent event, Emitter<CvChatState> emit) async {
    emit(CvChatLoading());
    final result = await createChatSession(event.cvId);
    result.fold(
      (failure) => emit(CvChatError(failure.message)),
      (chatId) => emit(CvChatSessionCreated(chatId)),
    );
  }

  void _onSendChatMessage(SendCvChatMessageEvent event, Emitter<CvChatState> emit) async {
    emit(CvChatLoading());
    final result = await sendChatMessage(event.chatId, event.message, event.cvId);
    result.fold(
      (failure) => emit(CvChatError(failure.message)),
      (message) => emit(CvChatMessageSent(message)),
    );
  }

  void _onGetChatHistory(GetCvChatHistoryEvent event, Emitter<CvChatState> emit) async {
    emit(CvChatLoading());
    final result = await getChatHistory(event.chatId);
    result.fold(
      (failure) => emit(CvChatError(failure.message)),
      (history) => emit(CvChatHistoryLoaded(history)),
    );
  }

  void _onGetAllChatSessions(GetAllCvChatSessionsEvent event, Emitter<CvChatState> emit) async {
    emit(CvChatLoading());
    final result = await getAllChatSessions();
    result.fold(
      (failure) => emit(CvChatError(failure.message)),
      (sessions) => emit(CvChatSessionsLoaded(sessions)),
    );
  }
}