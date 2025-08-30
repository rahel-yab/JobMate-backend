import 'package:job_mate/features/cv/domain/entities/cv_details.dart';
import 'package:job_mate/features/cv/domain/entities/cv_feedback.dart';

abstract class CvRemoteDataSource {
  Future<CvDetails> uploadCv(String userId, String? rawText, String? filePath);
  Future<CvFeedback> analyzeCv(String cvId);
}