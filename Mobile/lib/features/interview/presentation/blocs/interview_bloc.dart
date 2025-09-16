import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:job_mate/features/interview/domain/entities/interview_message.dart';
import 'package:job_mate/features/interview/domain/entities/interview_session.dart';
import 'package:job_mate/features/interview/domain/usecases/start_freeform_session.dart'
    as usecase;
import 'package:job_mate/features/interview/domain/usecases/start_structured_session.dart'
    as usecase;
import 'package:job_mate/features/interview/domain/usecases/send_freeform_message.dart'
    as usecase;
import 'package:job_mate/features/interview/domain/usecases/send_structured_answer.dart'
    as usecase;
import 'package:job_mate/features/interview/domain/usecases/get_freeform_history.dart';
import 'package:job_mate/features/interview/domain/usecases/get_structured_history.dart';
import 'package:job_mate/features/interview/domain/usecases/get_user_freeform_chats.dart';
import 'package:job_mate/features/interview/domain/usecases/get_user_structured_chats.dart';
import 'package:job_mate/features/interview/domain/usecases/continue_structured_session.dart'
    as usecase;
import 'interview_event.dart';
import 'interview_state.dart';

class InterviewBloc extends Bloc<InterviewEvent, InterviewState> {
  final usecase.StartFreeformSession startFreeformSession;
  final usecase.StartStructuredSession startStructuredSession;
  final usecase.SendFreeformMessage sendFreeformMessage;
  final usecase.SendStructuredAnswer sendStructuredAnswer;
  final GetFreeformHistory getFreeformHistory;
  final GetStructuredHistory getStructuredHistory;
  final GetUserFreeformChats getUserFreeformChats;
  final GetUserStructuredChats getUserStructuredChats;
  final usecase.ContinueStructuredSession continueStructuredSession;

  String? _chatId;
  String? _currentMode;
  List<InterviewMessage> _messages = [];
  InterviewSession? _currentSession;

  InterviewBloc({
    required this.startFreeformSession,
    required this.startStructuredSession,
    required this.sendFreeformMessage,
    required this.sendStructuredAnswer,
    required this.getFreeformHistory,
    required this.getStructuredHistory,
    required this.getUserFreeformChats,
    required this.getUserStructuredChats,
    required this.continueStructuredSession,
  }) : super(const InterviewInitial()) {
    // Start Freeform Session
    on<StartFreeformSession>((event, emit) async {
      emit(const InterviewLoading());

      final result = await startFreeformSession(event.sessionType);
      result.fold(
        (failure) => emit(
          InterviewError("Could not start session: ${failure.toString()}"),
        ),
        (session) async {
          _chatId = session.chatId;
          _currentMode = 'freeform';
          _currentSession = session;
          _messages = [];

          emit(InterviewLoaded(List<InterviewMessage>.from(_messages), session: session));
          add(LoadChatHistory(_chatId!));
        },
      );
    });

    // Start Structured Session
    on<StartStructuredSession>((event, emit) async {
      emit(const InterviewLoading());

      final result = await startStructuredSession(event.field);
      await result.fold(
        (failure) async => emit(
          InterviewError("Could not start session: ${failure.toString()}"),
        ),
        (session) async {
          _chatId = session.chatId;
          _currentMode = 'structured';
          _currentSession = session;
          _messages = [];

          // Emit initial state and immediately load history to get first question
          emit(InterviewLoaded(List<InterviewMessage>.from(_messages), session: session));

          // For structured interviews, the first question might be available immediately
          // Try to get it from history or make a continue call
          final historyResult = await getStructuredHistory(_chatId!);
          await historyResult.fold(
            (failure) async {
              // If no history, try to continue the interview to get first question
              print('DEBUG: No history found, trying continue endpoint');
              final continueResult = await continueStructuredSession(_chatId!);
              await continueResult.fold(
                (failure) async =>
                    print('DEBUG: Continue failed: ${failure.toString()}'),
                (firstQuestion) async {
                  if (!emit.isDone) {
                    // Always include a synthetic session-start message so the chat opens consistently
                    final intro = InterviewMessage(
                      chatId: session.chatId,
                      role: 'assistant',
                      content:
                          'INTERVIEW SESSION STARTED\n\nField: ${session.field ?? 'software_engineering'}\nTotal Questions: ${session.totalQuestions ?? 6}\n\nLet\'s begin with the first question:',
                      timestamp: DateTime.now(),
                    );
                    _messages = [intro, firstQuestion];
                    emit(InterviewLoaded(List<InterviewMessage>.from(_messages), session: session));
                  }
                },
              );
            },
            (history) async {
              if (history.isNotEmpty) {
                if (!emit.isDone) {
                  // Ensure we own a List<InterviewMessage> not a covariant List<InterviewMessageModel>
                  _messages = List<InterviewMessage>.from(history);
                  emit(InterviewLoaded(List<InterviewMessage>.from(_messages), session: session));
                }
              } else {
                print('DEBUG: History is empty, trying continue endpoint');
                final continueResult = await continueStructuredSession(
                  _chatId!,
                );
                await continueResult.fold(
                  (failure) async =>
                      print('DEBUG: Continue failed: ${failure.toString()}'),
                  (firstQuestion) async {
                    if (!emit.isDone) {
                      final intro = InterviewMessage(
                        chatId: session.chatId,
                        role: 'assistant',
                        content:
                            'INTERVIEW SESSION STARTED\n\nField: ${session.field ?? 'software_engineering'}\nTotal Questions: ${session.totalQuestions ?? 6}\n\nLet\'s begin with the first question:',
                        timestamp: DateTime.now(),
                      );
                      _messages = [intro, firstQuestion];
                      emit(InterviewLoaded(List<InterviewMessage>.from(_messages), session: session));
                    }
                  },
                );
              }
            },
          );
        },
      );
    });

    // Send Freeform Message
    on<SendFreeformMessage>((event, emit) async {
      if (_chatId == null) {
        emit(const InterviewError("No active chat session"));
        return;
      }

      // Add user message immediately
      final userMessage = InterviewMessage(
        chatId: _chatId!,
        role: 'user',
        content: event.message,
        timestamp: DateTime.now(),
      );
      _messages.add(userMessage);
      // Emit a new list instance so UI rebuilds
      emit(InterviewLoaded(List<InterviewMessage>.from(_messages), session: _currentSession));

      final result = await sendFreeformMessage(_chatId!, event.message);
      result.fold(
        (failure) => emit(
          InterviewError("Could not send message: ${failure.toString()}"),
        ),
        (response) {
          _messages.add(response);
          emit(InterviewLoaded(List<InterviewMessage>.from(_messages), session: _currentSession));
        },
      );
    });

    // Send Structured Answer
    on<SendStructuredAnswer>((event, emit) async {
      if (_chatId == null) {
        emit(const InterviewError("No active chat session"));
        return;
      }

      // Add user answer immediately
      final userMessage = InterviewMessage(
        chatId: _chatId!,
        role: 'user',
        content: event.answer,
        timestamp: DateTime.now(),
      );
      _messages.add(userMessage);
      emit(InterviewLoaded(List<InterviewMessage>.from(_messages), session: _currentSession));

      final result = await sendStructuredAnswer(_chatId!, event.answer);
      result.fold(
        (failure) => emit(
          InterviewError("Could not send answer: ${failure.toString()}"),
        ),
        (response) {
          _messages.add(response);
          emit(InterviewLoaded(List<InterviewMessage>.from(_messages), session: _currentSession));
        },
      );
    });

    // Load Chat History
    on<LoadChatHistory>((event, emit) async {
      if (_currentMode == null) return;

      if (_currentMode == 'freeform') {
        final result = await getFreeformHistory(event.chatId);
        result.fold(
          (failure) => {}, // Ignore history loading errors
          (history) {
            // Copy into a fresh List<InterviewMessage> to avoid covariant list runtime errors
            _messages = List<InterviewMessage>.from(history);
            emit(InterviewLoaded(List<InterviewMessage>.from(_messages), session: _currentSession));
          },
        );
      } else if (_currentMode == 'structured') {
        final result = await getStructuredHistory(event.chatId);
        result.fold(
          (failure) => {}, // Ignore history loading errors
          (history) {
            // Copy into a fresh List<InterviewMessage> to avoid covariant list runtime errors
            _messages = List<InterviewMessage>.from(history);
            emit(InterviewLoaded(List<InterviewMessage>.from(_messages), session: _currentSession));
          },
        );
      }
    });

    // Load User Chats
    on<LoadUserChats>((event, emit) async {
      emit(const InterviewLoading());

      final freeformResult = await getUserFreeformChats();
      final structuredResult = await getUserStructuredChats();

      List<InterviewSession> allSessions = [];

      freeformResult.fold(
        (failure) => {},
        (sessions) => allSessions.addAll(sessions),
      );

      structuredResult.fold(
        (failure) => {},
        (sessions) => allSessions.addAll(sessions),
      );

      emit(UserChatsLoaded(allSessions));
    });
  }
}
