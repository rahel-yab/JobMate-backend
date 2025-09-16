import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:job_mate/features/cv/domain/usecases/get_suggestions.dart';
import 'cv_event.dart';
import 'cv_state.dart';
import 'package:job_mate/features/cv/domain/usecases/upload_cv.dart';
import 'package:job_mate/features/cv/domain/usecases/analyze_cv.dart';
class CvBloc extends Bloc<CvEvent, CvState> {
  final UploadCv uploadCv;
  final AnalyzeCv analyzeCv;
  final GetSuggestions getSuggestions;

  CvBloc({
    required this.uploadCv,
    required this.analyzeCv,
    required this.getSuggestions,
  }) : super(CvInitial()) {
    on<UploadCvEvent>(_onUploadCv);
    on<AnalyzeCvEvent>(_onAnalyzeCv);
    on<GetSuggestionsEvent>(_onGetSuggestions);
  }

  void _onUploadCv(UploadCvEvent event, Emitter<CvState> emit) async {
    emit(CvLoading());
    final result = await uploadCv(
      event.userId,  event.rawText,  event.filePath,
    );
    result.fold(
      (failure) => emit(CvError(failure.message)),
      (details) => emit(CvUploaded(details)),
    );
  }

  void _onAnalyzeCv(AnalyzeCvEvent event, Emitter<CvState> emit) async {
    emit(CvLoading());
    final result = await analyzeCv(event.cvId);
    result.fold(
      (failure) => emit(CvError(failure.message)),
      (feedback) => emit(CvAnalyzed(feedback)),
    );
  }

  void _onGetSuggestions(GetSuggestionsEvent event, Emitter<CvState> emit) async {
    emit(CvLoading());
    final result = await getSuggestions();
    result.fold(
      (failure) => emit(CvError(failure.message)),
      (suggestions) => emit(CvSuggestionsLoaded(suggestions)),
    );
  }
}
