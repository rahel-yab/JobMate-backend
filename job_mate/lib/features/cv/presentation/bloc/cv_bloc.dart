import 'package:flutter_bloc/flutter_bloc.dart';
import 'cv_event.dart';
import 'cv_state.dart';
import 'package:job_mate/features/cv/domain/usecases/upload_cv.dart';
import 'package:job_mate/features/cv/domain/usecases/analyze_cv.dart';

class CvBloc extends Bloc<CvEvent, CvState> {
  final UploadCv uploadCv;
  final AnalyzeCv analyzeCv;

  CvBloc({required this.uploadCv, required this.analyzeCv})
    : super(CvInitial()) {
    on<UploadCvEvent>((event, emit) async {
      emit(CvLoading());
      final result = await uploadCv(
        event.userId,
        event.rawText,
        event.filePath,
      );
      result.fold(
        (failure) => emit(CvError(failure.message)),
        (cvDetails) => emit(CvUploaded(cvDetails)),
      );
    });

    on<AnalyzeCvEvent>((event, emit) async {
      emit(CvLoading());
      final result = await analyzeCv(event.cvId);
      result.fold(
        (failure) => emit(CvError(failure.message)),
        (feedback) => emit(CvAnalyzed(feedback)),
      );
    });
  }
}
