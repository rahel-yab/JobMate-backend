import 'package:equatable/equatable.dart';
import 'package:job_mate/features/cv/domain/entities/cv_details.dart';
import 'package:job_mate/features/cv/domain/entities/cv_feedback.dart';

abstract class CvState extends Equatable {
  const CvState();
  @override
  List<Object?> get props => [];
}

class CvInitial extends CvState {}

class CvLoading extends CvState {}

class CvUploaded extends CvState {
  final CvDetails details;
  const CvUploaded(this.details);
}

class CvAnalyzed extends CvState {
  final CvFeedback feedback;
  const CvAnalyzed(this.feedback);
}

class CvError extends CvState {
  final String message;
  const CvError(this.message);
}
