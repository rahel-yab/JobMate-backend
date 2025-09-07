import 'package:equatable/equatable.dart';
import '../../domain/entities/interview_message.dart';

abstract class InterviewState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InterviewInitial extends InterviewState {}

class InterviewLoading extends InterviewState {}

class InterviewLoaded extends InterviewState {
  final List<InterviewMessage> messages;

  InterviewLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class InterviewError extends InterviewState {
  final String message;
  InterviewError(this.message);

  @override
  List<Object?> get props => [message];
}
