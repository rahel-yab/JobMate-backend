// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'interview_event.dart';
// import 'interview_state.dart';
// import '../../domain/entities/interview_message.dart';
// import '../../domain/usecases/send_freeform_message.dart';
// import '../../domain/usecases/start_freeform_session.dart';

// class InterviewBloc extends Bloc<InterviewEvent, InterviewState> {
//   final StartFreeformSession startFreeformSession;
//   final SendFreeformMessage sendFreeformMessage;

//   List<InterviewMessage> _messages = [];
//   String? _chatId;

//   InterviewBloc({
//     required this.startFreeformSession,
//     required this.sendFreeformMessage,
//   }) : super(InterviewInitial()) {
//     on<StartInterviewSession>((event, emit) async {
//       emit(InterviewLoading());
//       final result = await startFreeformSession("freeform");
//       result.fold(
//         (failure) => emit(InterviewError("Could not start session")),
//         (session) {
//           _chatId = session.chatId;
//           emit(InterviewLoaded(_messages));
//         },
//       );
//     });

//     on<SendMessage>((event, emit) async {
//       if (_chatId == null) return;
//       final result = await sendFreeformMessage(_chatId!, event.message);
//       result.fold((failure) => emit(InterviewError("Could not send message")), (
//         msg,
//       ) {
//         _messages = List.from(_messages)..add(msg);
//         emit(InterviewLoaded(_messages));
//       });
//     });
//   }
// }

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/interview_message.dart';
import '../../domain/usecases/answer_structured_interview.dart';
import '../../domain/usecases/get_freeform_history.dart';
import '../../domain/usecases/get_structured_history.dart';
import '../../domain/usecases/get_user_freeform_chats.dart';
import '../../domain/usecases/get_user_structured_chats.dart';
import '../../domain/usecases/send_freeform_message.dart';
import '../../domain/usecases/start_freeform_session.dart';
import '../../domain/usecases/start_structured_interview.dart';
import 'interview_event.dart';
import 'interview_state.dart';

class InterviewBloc extends Bloc<InterviewEvent, InterviewState> {
  final StartFreeformSession startFreeformSession;
  final SendFreeformMessage sendFreeformMessage;
  final GetFreeformHistory getFreeformHistory;
  final StartStructuredInterview startStructuredInterview;
  final AnswerStructuredInterview answerStructuredInterview;
  final GetStructuredHistory getStructuredHistory;

  List<InterviewMessage> _messages = [];
  String? _chatId;
  InterviewSender? _currentMode;

  InterviewBloc({
    required this.startFreeformSession,
    required this.sendFreeformMessage,
    required this.getFreeformHistory,
    required this.startStructuredInterview,
    required this.answerStructuredInterview,
    required this.getStructuredHistory,
  }) : super(InterviewInitial()) {
    // Start Freeform Session
    on<StartInterviewSession>((event, emit) async {
      emit(InterviewLoading());
      final result = await startFreeformSession("freeform");
      result.fold(
        (failure) => emit(InterviewError("Could not start session")),
        (session) async {
          _chatId = session.chatId;
          _currentMode = InterviewSender.user;
          // Load history if exists
          add(LoadChatHistory(_chatId!));
        },
      );
    });

    // Start Structured Session
    on<StartStructuredSession>((event, emit) async {
      emit(InterviewLoading());
      final result = await startStructuredInterview(event.field);
      result.fold(
        (failure) =>
            emit(InterviewError("Could not start structured interview")),
        (session) async {
          _chatId = session.chatId;
          _currentMode =
              InterviewSender.assistant; // structured assistant-driven
          add(LoadChatHistory(_chatId!));
        },
      );
    });

    // Send Freeform Message
    on<SendMessage>((event, emit) async {
      if (_chatId == null || _currentMode == null) return;

      emit(InterviewLoading());
      final result = await sendFreeformMessage(_chatId!, event.message);
      result.fold((failure) => emit(InterviewError("Could not send message")), (
        msg,
      ) {
        _messages = List.from(_messages)..add(msg);
        emit(InterviewLoaded(_messages));
      });
    });

    // Answer Structured Interview
    on<AnswerStructuredQuestion>((event, emit) async {
      if (_chatId == null) return;

      emit(InterviewLoading());
      final result = await answerStructuredInterview(_chatId!, event.answer);
      result.fold(
        (failure) => emit(InterviewError("Could not submit answer")),
        (msg) {
          _messages = List.from(_messages)..add(msg);
          emit(InterviewLoaded(_messages));
        },
      );
    });

    // Load chat history
    on<LoadChatHistory>((event, emit) async {
      emit(InterviewLoading());
      final result =
          _currentMode == InterviewSender.user
              ? await getFreeformHistory(event.chatId)
              : await getStructuredHistory(event.chatId);

      result.fold((failure) => emit(InterviewError("Could not load history")), (
        history,
      ) {
        _messages = history;
        emit(InterviewLoaded(_messages));
      });
    });
  }
}
