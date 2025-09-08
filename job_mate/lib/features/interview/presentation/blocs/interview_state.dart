import 'package:equatable/equatable.dart';
import 'package:job_mate/features/interview/domain/entities/interview_message.dart';
import 'package:job_mate/features/interview/domain/entities/interview_session.dart';

abstract class InterviewState extends Equatable {
  const InterviewState();

  @override
  List<Object?> get props => [];
}

class InterviewInitial extends InterviewState {
  const InterviewInitial();
}

class InterviewLoading extends InterviewState {
  const InterviewLoading();
}

class InterviewLoaded extends InterviewState {
  final List<InterviewMessage> messages;
  final InterviewSession? session;

  const InterviewLoaded(this.messages, {this.session});

  @override
  List<Object?> get props => [messages, session];
}

class InterviewError extends InterviewState {
  final String message;

  const InterviewError(this.message);

  @override
  List<Object?> get props => [message];
}

class UserChatsLoaded extends InterviewState {
  final List<InterviewSession> sessions;

  const UserChatsLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}
