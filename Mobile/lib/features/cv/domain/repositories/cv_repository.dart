import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';

import 'package:job_mate/features/cv/domain/entities/cv_details.dart';
import 'package:job_mate/features/cv/domain/entities/cv_feedback.dart';
import 'package:job_mate/features/cv/domain/entities/suggestion.dart';

abstract class CvRepository {
  Future<Either<Failure,CvDetails>> uploadCv(String userId, String? rawText, String? filePath);
  Future<Either<Failure,CvFeedback>> analyzeCv(String cvId);
  Future<Either<Failure, Suggestion>> getSuggestions();


}