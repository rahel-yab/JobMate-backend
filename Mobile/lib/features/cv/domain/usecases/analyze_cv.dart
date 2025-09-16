import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/cv/domain/entities/cv_feedback.dart';
import 'package:job_mate/features/cv/domain/repositories/cv_repository.dart';

class AnalyzeCv {
  final CvRepository repository;
  AnalyzeCv(this.repository);

  Future<Either<Failure,CvFeedback>> call(String cvId) async{
    return await repository.analyzeCv(cvId);
  }
}