import 'package:equatable/equatable.dart';

abstract class CvEvent extends Equatable {
  const CvEvent();
  @override
  List<Object?> get props => [];
}

class UploadCvEvent extends CvEvent {
  final String userId;
  final String? rawText;
  final String? filePath;

  const UploadCvEvent({
    required this.userId,
    this.rawText,
    this.filePath,
  });

  @override
  List<Object?> get props => [userId, rawText, filePath];
}

class AnalyzeCvEvent extends CvEvent {
  final String cvId;

  const AnalyzeCvEvent(this.cvId);

  @override
  List<Object?> get props => [cvId];
}

class GetSuggestionsEvent extends CvEvent {}